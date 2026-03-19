
import 'package:simplimap/models/implicant.dart';

class Minimizer {
  String minimize(List<int> mintermValues, int numVariables, [List<int> dontCares = const []]) {
    return minimizeSOP(mintermValues, numVariables, dontCares);
  }

  String minimizeSOP(List<int> mintermValues, int numVariables, [List<int> dontCares = const []]) {
    final maxTerms = 1 << numVariables;
    final required = mintermValues.where((m) => m >= 0 && m < maxTerms).toSet()..toList().sort();
    final optional = dontCares.where((m) => m >= 0 && m < maxTerms && !required.contains(m)).toSet();

    if (required.isEmpty) return '0';
    if (required.length == maxTerms) return '1';

    final pis = _generatePrimeImplicants(required, optional, numVariables);
    final selected = _selectWithPetrick(pis, required.toList());
    return _cubesToSop(selected, numVariables);
  }

  String minimizePOS(List<int> zeroValues, int numVariables, [List<int> dontCares = const []]) {
    final maxTerms = 1 << numVariables;
    final requiredZeros = zeroValues.where((m) => m >= 0 && m < maxTerms).toSet();
    final optional = dontCares.where((m) => m >= 0 && m < maxTerms && !requiredZeros.contains(m)).toSet();

    if (requiredZeros.isEmpty) return '1';
    if (requiredZeros.length == maxTerms) return '0';

    final pis = _generatePrimeImplicants(requiredZeros, optional, numVariables);
    final selected = _selectWithPetrick(pis, requiredZeros.toList());
    return _cubesToPos(selected, numVariables);
  }

  List<Implicant> findPrimeImplicants(List<int> mintermValues, int numVariables, [List<int> dontCares = const []]) {
    final maxTerms = 1 << numVariables;
    final required = mintermValues.where((m) => m >= 0 && m < maxTerms).toSet();
    final optional = dontCares.where((m) => m >= 0 && m < maxTerms && !required.contains(m)).toSet();
    if (required.isEmpty) return [];

    final pis = _generatePrimeImplicants(required, optional, numVariables);
    return pis.map((cube) => _cubeToImplicant(cube, numVariables)).toList();
  }

  String implicantToTerm(Implicant implicant, List<String> variables) {
    String term = '';
    for (int i = 0; i < implicant.binaryRepresentation.length; i++) {
      if (implicant.binaryRepresentation[i] == '1') {
        term += variables[i];
      } else if (implicant.binaryRepresentation[i] == '0') {
        term += "${variables[i]}'";
      }
    }
    return term.isEmpty ? '1' : term;
  }

  String implicantToPosClause(Implicant implicant, List<String> variables) {
    final literals = <String>[];
    for (int i = 0; i < implicant.binaryRepresentation.length; i++) {
      final bit = implicant.binaryRepresentation[i];
      if (bit == '-') {
        continue;
      }
      literals.add(bit == '1' ? "${variables[i]}'" : variables[i]);
    }
    if (literals.isEmpty) {
      return '(0)';
    }
    return '(${literals.join(' + ')})';
  }

  List<_Cube> _generatePrimeImplicants(Set<int> requiredTerms, Set<int> optionalTerms, int numVariables) {
    final allTerms = <int>{...requiredTerms, ...optionalTerms};
    final fullMask = (1 << numVariables) - 1;

    var current = allTerms
        .map((m) => _Cube(
              bits: m,
              mask: fullMask,
              coveredRequired: requiredTerms.contains(m) ? {m} : <int>{},
            ))
        .toList();

    final primeMap = <String, _Cube>{};

    while (true) {
      final next = <String, _Cube>{};
      final used = List<bool>.filled(current.length, false);

      for (int i = 0; i < current.length; i++) {
        for (int j = i + 1; j < current.length; j++) {
          final combined = _combineCubes(current[i], current[j]);
          if (combined == null) {
            continue;
          }

          used[i] = true;
          used[j] = true;

          final key = combined.key;
          final existing = next[key];
          if (existing == null) {
            next[key] = combined;
          } else {
            existing.coveredRequired.addAll(combined.coveredRequired);
          }
        }
      }

      for (int i = 0; i < current.length; i++) {
        if (!used[i]) {
          final key = current[i].key;
          final existing = primeMap[key];
          if (existing == null) {
            primeMap[key] = current[i].copy();
          } else {
            existing.coveredRequired.addAll(current[i].coveredRequired);
          }
        }
      }

      if (next.isEmpty) {
        break;
      }
      current = next.values.toList();
    }

    return primeMap.values.where((cube) => cube.coveredRequired.isNotEmpty).toList();
  }

  _Cube? _combineCubes(_Cube a, _Cube b) {
    if (a.mask != b.mask) {
      return null;
    }

    final diff = (a.bits ^ b.bits) & a.mask;
    if (diff == 0 || (diff & (diff - 1)) != 0) {
      return null;
    }

    final newMask = a.mask & ~diff;
    final newBits = a.bits & newMask;

    return _Cube(
      bits: newBits,
      mask: newMask,
      coveredRequired: {...a.coveredRequired, ...b.coveredRequired},
    );
  }

  List<_Cube> _selectWithPetrick(List<_Cube> primeImplicants, List<int> requiredTerms) {
    final coveredBy = <int, List<int>>{};
    for (int t in requiredTerms) {
      coveredBy[t] = [];
      for (int i = 0; i < primeImplicants.length; i++) {
        if (primeImplicants[i].covers(t)) {
          coveredBy[t]!.add(i);
        }
      }
    }

    final essentials = <int>{};
    for (final entry in coveredBy.entries) {
      if (entry.value.length == 1) {
        essentials.add(entry.value.first);
      }
    }

    final remaining = requiredTerms.where((t) {
      for (final e in essentials) {
        if (primeImplicants[e].covers(t)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (remaining.isEmpty) {
      return essentials.map((i) => primeImplicants[i]).toList();
    }

    var products = <Set<int>>[<int>{}];
    for (final t in remaining) {
      final clause = coveredBy[t]!.toSet();
      final nextProducts = <Set<int>>[];

      for (final product in products) {
        for (final idx in clause) {
          final merged = <int>{...product, idx};
          nextProducts.add(merged);
        }
      }

      products = _reduceDominatedProducts(nextProducts);
    }

    Set<int>? best;
    int bestTerms = 1 << 30;
    int bestLiterals = 1 << 30;
    String? bestSignature;

    for (final candidate in products) {
      final withEssentials = <int>{...candidate, ...essentials};
      final termCount = withEssentials.length;
      final literalCount = withEssentials.fold<int>(
        0,
        (sum, idx) => sum + primeImplicants[idx].literalCount,
      );
      final signature = (withEssentials.toList()..sort()).join(',');

      final better = termCount < bestTerms ||
          (termCount == bestTerms && literalCount < bestLiterals) ||
          (termCount == bestTerms && literalCount == bestLiterals &&
              (bestSignature == null || signature.compareTo(bestSignature) < 0));

      if (better) {
        best = withEssentials;
        bestTerms = termCount;
        bestLiterals = literalCount;
        bestSignature = signature;
      }
    }

    final selected = (best ?? essentials).toList()..sort();
    return selected.map((i) => primeImplicants[i]).toList();
  }

  List<Set<int>> _reduceDominatedProducts(List<Set<int>> products) {
    final unique = <String, Set<int>>{};
    for (final p in products) {
      final key = (p.toList()..sort()).join(',');
      unique[key] = p;
    }

    final list = unique.values.toList();
    final keep = List<bool>.filled(list.length, true);

    for (int i = 0; i < list.length; i++) {
      if (!keep[i]) continue;
      for (int j = 0; j < list.length; j++) {
        if (i == j || !keep[j]) continue;

        if (_isSubset(list[i], list[j])) {
          keep[j] = false;
        }
      }
    }

    final reduced = <Set<int>>[];
    for (int i = 0; i < list.length; i++) {
      if (keep[i]) {
        reduced.add(list[i]);
      }
    }
    return reduced;
  }

  bool _isSubset(Set<int> a, Set<int> b) {
    if (a.length > b.length) return false;
    for (final v in a) {
      if (!b.contains(v)) {
        return false;
      }
    }
    return true;
  }

  String _cubesToSop(List<_Cube> cubes, int numVariables) {
    if (cubes.isEmpty) {
      return '0';
    }
    final variables = ['A', 'B', 'C', 'D'].sublist(0, numVariables);
    return cubes
        .map((c) => _cubeToSopTerm(c, variables))
        .where((t) => t.isNotEmpty)
        .join(' + ');
  }

  String _cubeToSopTerm(_Cube cube, List<String> variables) {
    final buffer = StringBuffer();
    for (int i = 0; i < variables.length; i++) {
      final bit = 1 << (variables.length - 1 - i);
      if ((cube.mask & bit) == 0) {
        continue;
      }
      if ((cube.bits & bit) != 0) {
        buffer.write(variables[i]);
      } else {
        buffer.write("${variables[i]}'");
      }
    }
    final term = buffer.toString();
    return term.isEmpty ? '1' : term;
  }

  String _cubesToPos(List<_Cube> cubes, int numVariables) {
    if (cubes.isEmpty) {
      return '1';
    }
    final variables = ['A', 'B', 'C', 'D'].sublist(0, numVariables);
    return cubes.map((c) => _cubeToPosClause(c, variables)).join('');
  }

  String _cubeToPosClause(_Cube cube, List<String> variables) {
    final literals = <String>[];
    for (int i = 0; i < variables.length; i++) {
      final bit = 1 << (variables.length - 1 - i);
      if ((cube.mask & bit) == 0) {
        continue;
      }
      literals.add((cube.bits & bit) != 0 ? "${variables[i]}'" : variables[i]);
    }
    if (literals.isEmpty) {
      return '(0)';
    }
    return '(${literals.join(' + ')})';
  }

  Implicant _cubeToImplicant(_Cube cube, int numVariables) {
    final binary = StringBuffer();
    for (int i = numVariables - 1; i >= 0; i--) {
      final bit = 1 << i;
      if ((cube.mask & bit) == 0) {
        binary.write('-');
      } else if ((cube.bits & bit) != 0) {
        binary.write('1');
      } else {
        binary.write('0');
      }
    }
    final minterms = cube.coveredRequired.toList()..sort();
    return Implicant(minterms, binary.toString());
  }
}

class _Cube {
  _Cube({
    required this.bits,
    required this.mask,
    required Set<int> coveredRequired,
  }) : coveredRequired = Set<int>.from(coveredRequired);

  final int bits;
  final int mask;
  final Set<int> coveredRequired;

  String get key => '$bits/$mask';

  int get literalCount => _popCount(mask);

  bool covers(int term) {
    return (term & mask) == (bits & mask);
  }

  _Cube copy() {
    return _Cube(bits: bits, mask: mask, coveredRequired: coveredRequired);
  }

  int _popCount(int n) {
    var v = n;
    var count = 0;
    while (v != 0) {
      v &= (v - 1);
      count++;
    }
    return count;
  }
}
