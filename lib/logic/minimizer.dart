
import 'package:flutter/material.dart';
import 'package:simplimap/models/implicant.dart';
import 'package:simplimap/models/kmap_group.dart';

class LogicMinimizer {
  static const List<String> _variables = ['A', 'B', 'C', 'D'];

  static List<KmapGroup> minimize(
    List<int> targetTerms,
    List<int> dontCares,
    int numVars,
    bool isSOP,
  ) {
    if (numVars < 3 || numVars > 4) {
      return const <KmapGroup>[];
    }

    final maxTerm = 1 << numVars;
    final targets = targetTerms.where((term) => term >= 0 && term < maxTerm).toSet().toList()..sort();
    if (targets.isEmpty) {
      return const <KmapGroup>[];
    }

    final dontCareSet = dontCares
        .where((term) => term >= 0 && term < maxTerm)
        .where((term) => !targets.contains(term))
        .toSet();

    final allInputTerms = <int>{...targets, ...dontCareSet}.toList()..sort();
    final primeImplicants = _findPrimeImplicants(allInputTerms, targets.toSet(), numVars);
    if (primeImplicants.isEmpty) {
      return const <KmapGroup>[];
    }

    final chart = <int, Set<int>>{};
    for (final target in targets) {
      chart[target] = <int>{};
      for (var i = 0; i < primeImplicants.length; i++) {
        if (primeImplicants[i].coveredTargets.contains(target)) {
          chart[target]!.add(i);
        }
      }
    }

    final selected = <int>{};
    final essential = <int>{};
    final remainingTargets = targets.toSet();

    for (final target in targets) {
      final covering = chart[target] ?? <int>{};
      if (covering.length == 1) {
        final piIndex = covering.first;
        selected.add(piIndex);
        essential.add(piIndex);
      }
    }

    for (final piIndex in selected) {
      remainingTargets.removeAll(primeImplicants[piIndex].coveredTargets);
    }

    if (remainingTargets.isNotEmpty) {
      final clauses = <Set<int>>[];
      for (final target in remainingTargets) {
        final covering = (chart[target] ?? <int>{}).where((index) => !selected.contains(index)).toSet();
        if (covering.isNotEmpty) {
          clauses.add(covering);
        }
      }

      if (clauses.isNotEmpty) {
        var products = <Set<int>>[<int>{}];
        for (final clause in clauses) {
          final nextProducts = <Set<int>>[];
          for (final product in products) {
            for (final piIndex in clause) {
              final merged = <int>{...product, piIndex};
              nextProducts.add(merged);
            }
          }
          products = _reduceProducts(nextProducts);
        }

        final best = _pickBestProduct(products, primeImplicants);
        selected.addAll(best);
      }
    }

    final sortedSelection = selected.toList()
      ..sort((a, b) {
        final termCompare = primeImplicants[b].coveredTargets.length.compareTo(primeImplicants[a].coveredTargets.length);
        if (termCompare != 0) {
          return termCompare;
        }
        return primeImplicants[a].pattern.compareTo(primeImplicants[b].pattern);
      });

    return sortedSelection.map((index) {
      final implicant = primeImplicants[index];
      final coveredTerms = implicant.coveredTargets.toList()..sort();
      return KmapGroup(
        minterms: coveredTerms,
        simplifiedTerm: _patternToExpression(implicant.pattern, numVars, isSOP),
        color: const Color(0x00000000),
        isEssential: essential.contains(index),
        eliminationLogic: _buildEliminationLogic(implicant.pattern, numVars),
      );
    }).toList(growable: false);
  }

  static List<_PrimeImplicant> _findPrimeImplicants(
    List<int> allTerms,
    Set<int> targetSet,
    int numVars,
  ) {
    var current = allTerms
        .map(
          (term) => _QmNode(
            pattern: term.toRadixString(2).padLeft(numVars, '0'),
            coveredAllTerms: <int>{term},
          ),
        )
        .toList(growable: false);

    final primeMap = <String, Set<int>>{};

    while (current.isNotEmpty) {
      final groups = <int, List<int>>{};
      for (var i = 0; i < current.length; i++) {
        final ones = _countOnes(current[i].pattern);
        groups.putIfAbsent(ones, () => <int>[]).add(i);
      }

      final used = List<bool>.filled(current.length, false);
      final nextMap = <String, Set<int>>{};
      final groupKeys = groups.keys.toList()..sort();

      for (final key in groupKeys) {
        final thisGroup = groups[key] ?? const <int>[];
        final nextGroup = groups[key + 1] ?? const <int>[];
        if (thisGroup.isEmpty || nextGroup.isEmpty) {
          continue;
        }

        for (final leftIndex in thisGroup) {
          for (final rightIndex in nextGroup) {
            final combined = _combinePatterns(current[leftIndex].pattern, current[rightIndex].pattern);
            if (combined == null) {
              continue;
            }
            used[leftIndex] = true;
            used[rightIndex] = true;
            nextMap.putIfAbsent(combined, () => <int>{}).addAll(current[leftIndex].coveredAllTerms);
            nextMap[combined]!.addAll(current[rightIndex].coveredAllTerms);
          }
        }
      }

      for (var i = 0; i < current.length; i++) {
        if (!used[i]) {
          primeMap.putIfAbsent(current[i].pattern, () => <int>{}).addAll(current[i].coveredAllTerms);
        }
      }

      current = nextMap.entries
          .map((entry) => _QmNode(pattern: entry.key, coveredAllTerms: entry.value))
          .toList(growable: false);
    }

    final primes = <_PrimeImplicant>[];
    for (final entry in primeMap.entries) {
      final coveredTargets = entry.value.where(targetSet.contains).toSet();
      if (coveredTargets.isEmpty) {
        continue;
      }
      primes.add(
        _PrimeImplicant(
          pattern: entry.key,
          coveredTargets: coveredTargets,
          literalCount: _literalCount(entry.key),
        ),
      );
    }

    primes.sort((a, b) {
      final c1 = b.coveredTargets.length.compareTo(a.coveredTargets.length);
      if (c1 != 0) {
        return c1;
      }
      final c2 = a.literalCount.compareTo(b.literalCount);
      if (c2 != 0) {
        return c2;
      }
      return a.pattern.compareTo(b.pattern);
    });

    return primes;
  }

  static int _countOnes(String pattern) {
    var count = 0;
    for (var i = 0; i < pattern.length; i++) {
      if (pattern[i] == '1') {
        count++;
      }
    }
    return count;
  }

  static String? _combinePatterns(String a, String b) {
    if (a.length != b.length) {
      return null;
    }

    var diff = 0;
    final buffer = StringBuffer();
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left == right) {
        buffer.write(left);
        continue;
      }
      if (left == '-' || right == '-') {
        return null;
      }
      diff++;
      if (diff > 1) {
        return null;
      }
      buffer.write('-');
    }

    return diff == 1 ? buffer.toString() : null;
  }

  static List<Set<int>> _reduceProducts(List<Set<int>> products) {
    final unique = <String, Set<int>>{};
    for (final product in products) {
      final normalized = product.toList()..sort();
      unique[normalized.join(',')] = product;
    }

    final values = unique.values.toList(growable: false);
    final keep = List<bool>.filled(values.length, true);

    for (var i = 0; i < values.length; i++) {
      if (!keep[i]) {
        continue;
      }
      for (var j = 0; j < values.length; j++) {
        if (i == j || !keep[j]) {
          continue;
        }
        if (_isSubset(values[i], values[j])) {
          keep[j] = false;
        }
      }
    }

    final reduced = <Set<int>>[];
    for (var i = 0; i < values.length; i++) {
      if (keep[i]) {
        reduced.add(values[i]);
      }
    }
    return reduced;
  }

  static bool _isSubset(Set<int> left, Set<int> right) {
    if (left.length > right.length) {
      return false;
    }
    for (final value in left) {
      if (!right.contains(value)) {
        return false;
      }
    }
    return true;
  }

  static Set<int> _pickBestProduct(List<Set<int>> products, List<_PrimeImplicant> implicants) {
    if (products.isEmpty) {
      return <int>{};
    }

    Set<int>? best;
    var bestPiCount = 1 << 30;
    var bestLiteralCount = 1 << 30;
    String? bestSignature;

    for (final product in products) {
      final piCount = product.length;
      final literalCount = product.fold<int>(0, (sum, index) => sum + implicants[index].literalCount);
      final signatureList = product.toList()..sort();
      final signature = signatureList.join(',');

      final better = piCount < bestPiCount ||
          (piCount == bestPiCount && literalCount < bestLiteralCount) ||
          (piCount == bestPiCount && literalCount == bestLiteralCount &&
              (bestSignature == null || signature.compareTo(bestSignature) < 0));

      if (better) {
        best = product;
        bestPiCount = piCount;
        bestLiteralCount = literalCount;
        bestSignature = signature;
      }
    }

    return best ?? <int>{};
  }

  static int _literalCount(String pattern) {
    var count = 0;
    for (var i = 0; i < pattern.length; i++) {
      if (pattern[i] != '-') {
        count++;
      }
    }
    return count;
  }

  static String _patternToExpression(String pattern, int numVars, bool isSOP) {
    final literals = <String>[];
    for (var i = 0; i < numVars; i++) {
      final bit = pattern[i];
      if (bit == '-') {
        continue;
      }
      final variable = _variables[i];
      if (isSOP) {
        literals.add(bit == '1' ? variable : "$variable'");
      } else {
        literals.add(bit == '0' ? variable : "$variable'");
      }
    }

    if (isSOP) {
      return literals.isEmpty ? '1' : literals.join();
    }
    return literals.isEmpty ? '(0)' : '(${literals.join('+')})';
  }

  static String _buildEliminationLogic(String pattern, int numVars) {
    final eliminated = <String>[];
    final fixed = <String>[];

    for (var i = 0; i < numVars; i++) {
      final variable = _variables[i];
      final bit = pattern[i];
      if (bit == '-') {
        eliminated.add('Dash at index $i means variable $variable changed state and was eliminated.');
      } else {
        fixed.add('$variable=$bit');
      }
    }

    if (eliminated.isEmpty) {
      return 'No dash positions were introduced, so no variables were eliminated. Fixed states: ${fixed.join(', ')}.';
    }

    final base = eliminated.join(' ');
    if (fixed.isEmpty) {
      return base;
    }
    return '$base Fixed variable states: ${fixed.join(', ')}.';
  }
}

class Minimizer {
  String minimize(List<int> mintermValues, int numVariables, [List<int> dontCares = const []]) {
    return minimizeSOP(mintermValues, numVariables, dontCares);
  }

  String minimizeSOP(List<int> mintermValues, int numVariables, [List<int> dontCares = const []]) {
    final groups = LogicMinimizer.minimize(mintermValues, dontCares, numVariables, true);
    if (groups.isEmpty) {
      return '0';
    }
    return groups.map((group) => group.simplifiedTerm).join(' + ');
  }

  String minimizePOS(List<int> zeroValues, int numVariables, [List<int> dontCares = const []]) {
    final groups = LogicMinimizer.minimize(zeroValues, dontCares, numVariables, false);
    if (groups.isEmpty) {
      return '1';
    }
    return groups.map((group) => group.simplifiedTerm).join();
  }

  List<Implicant> findPrimeImplicants(List<int> mintermValues, int numVariables, [List<int> dontCares = const []]) {
    if (numVariables < 3 || numVariables > 4) {
      return const <Implicant>[];
    }

    final maxTerm = 1 << numVariables;
    final targets = mintermValues.where((term) => term >= 0 && term < maxTerm).toSet().toList()..sort();
    if (targets.isEmpty) {
      return const <Implicant>[];
    }
    final dcs = dontCares
        .where((term) => term >= 0 && term < maxTerm)
        .where((term) => !targets.contains(term))
        .toSet();
    final all = <int>{...targets, ...dcs}.toList()..sort();

    final primes = LogicMinimizer._findPrimeImplicants(all, targets.toSet(), numVariables);
    return primes
        .map(
          (prime) => Implicant(
            prime.coveredTargets.toList()..sort(),
            prime.pattern,
          ),
        )
        .toList(growable: false);
  }

  String implicantToTerm(Implicant implicant, List<String> variables) {
    final buffer = StringBuffer();
    for (var i = 0; i < implicant.binaryRepresentation.length && i < variables.length; i++) {
      final bit = implicant.binaryRepresentation[i];
      if (bit == '-') {
        continue;
      }
      buffer.write(bit == '1' ? variables[i] : "${variables[i]}'");
    }
    final term = buffer.toString();
    return term.isEmpty ? '1' : term;
  }

  String implicantToPosClause(Implicant implicant, List<String> variables) {
    final literals = <String>[];
    for (var i = 0; i < implicant.binaryRepresentation.length && i < variables.length; i++) {
      final bit = implicant.binaryRepresentation[i];
      if (bit == '-') {
        continue;
      }
      literals.add(bit == '0' ? variables[i] : "${variables[i]}'");
    }
    return literals.isEmpty ? '(0)' : '(${literals.join(' + ')})';
  }
}

class _QmNode {
  const _QmNode({required this.pattern, required this.coveredAllTerms});

  final String pattern;
  final Set<int> coveredAllTerms;
}

class _PrimeImplicant {
  const _PrimeImplicant({
    required this.pattern,
    required this.coveredTargets,
    required this.literalCount,
  });

  final String pattern;
  final Set<int> coveredTargets;
  final int literalCount;
}
