
import 'dart:collection';
import 'dart:math';
import 'package:simplimap/models/implicant.dart';

class Minimizer {

  String minimize(List<int> mintermValues, int numVariables) {
    if (mintermValues.isEmpty) return '0';
    if (mintermValues.length == pow(2, numVariables)) return '1';

    final primeImplicants = findPrimeImplicants(mintermValues, numVariables);
    final chart = _buildPrimeImplicantChart(primeImplicants, mintermValues);
    
    final essentialPIs = _selectEssentialPrimeImplicants(chart);
    
    final solutionPIs = <Implicant>{...essentialPIs};
    var uncoveredMinterms = SplayTreeSet<int>.from(mintermValues);

    for (final pi in essentialPIs) {
      for (final m in pi.minterms) {
        uncoveredMinterms.remove(m);
      }
    }

    // Use a greedy approach to cover remaining minterms (Petrick's method is more exact but complex)
    var remainingPIs = primeImplicants.where((pi) => !essentialPIs.contains(pi)).toList();

    while (uncoveredMinterms.isNotEmpty) {
        if (remainingPIs.isEmpty) break; // Should not happen in normal cases

        // Find the PI that covers the most uncovered minterms
        remainingPIs.sort((a, b) {
            final aCovers = a.minterms.where((m) => uncoveredMinterms.contains(m)).length;
            final bCovers = b.minterms.where((m) => uncoveredMinterms.contains(m)).length;
            return bCovers.compareTo(aCovers);
        });

        final bestPI = remainingPIs.first;
        solutionPIs.add(bestPI);
        remainingPIs.remove(bestPI);

        for (final m in bestPI.minterms) {
            uncoveredMinterms.remove(m);
        }
    }

    return _implicantsToSOP(solutionPIs.toList(), numVariables);
  }

  List<Implicant> findPrimeImplicants(List<int> mintermValues, int numVariables) {
    if (mintermValues.isEmpty) return [];

    var implicants = mintermValues
        .map((m) => Implicant([m], _toBinary(m, numVariables)))
        .toList();
    
    List<Implicant> primeImplicants = [];

    while (true) {
        var nextImplicants = <String, Implicant>{}; // Use a map to handle duplicates

        implicants.sort((a, b) => _countOnes(a.binaryRepresentation).compareTo(_countOnes(b.binaryRepresentation)));

        for (int i = 0; i < implicants.length; i++) {
            for (int j = i + 1; j < implicants.length; j++) {
                if (_countOnes(implicants[j].binaryRepresentation) - _countOnes(implicants[i].binaryRepresentation) > 1) {
                    break;
                }
                if (_canCombine(implicants[i], implicants[j])) {
                    final combined = _combine(implicants[i], implicants[j]);
                    nextImplicants[combined.binaryRepresentation] = combined;
                    implicants[i].isPrime = false;
                    implicants[j].isPrime = false;
                }
            }
        }

        for (final imp in implicants) {
            if (imp.isPrime) {
                primeImplicants.add(imp);
            }
        }

        if (nextImplicants.isEmpty) break;
        
        implicants = nextImplicants.values.toList();
    }

    // Remove duplicate PIs that might have been added
    final uniquePIMap = {for (var pi in primeImplicants) pi.binaryRepresentation: pi};

    return uniquePIMap.values.toList();
  }

  Map<int, List<Implicant>> _buildPrimeImplicantChart(List<Implicant> primeImplicants, List<int> minterms) {
    final chart = <int, List<Implicant>>{};
    for (final minterm in minterms) {
      chart[minterm] = [];
      for (final pi in primeImplicants) {
        if (pi.covers(minterm)) {
          chart[minterm]!.add(pi);
        }
      }
    }
    return chart;
  }

  List<Implicant> _selectEssentialPrimeImplicants(Map<int, List<Implicant>> chart) {
    final essentialPIs = <Implicant>{};
    chart.forEach((minterm, implicants) {
      if (implicants.length == 1) {
        essentialPIs.add(implicants.first);
      }
    });
    return essentialPIs.toList();
  }

    String _implicantsToSOP(List<Implicant> implicants, int numVariables) {
      if (implicants.isEmpty) return "0";
      final variables = ['A', 'B', 'C', 'D'].sublist(0, numVariables);
      return implicants.map((imp) => implicantToTerm(imp, variables)).join(' + ');
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
      return term.isEmpty ? "1" : term;
  }

  String _toBinary(int n, int bits) {
    return n.toRadixString(2).padLeft(bits, '0');
  }

  int _countOnes(String binaryString) {
    return binaryString.split('').where((char) => char == '1').length;
  }

  bool _canCombine(Implicant imp1, Implicant imp2) {
    int diff = 0;
    for (int i = 0; i < imp1.binaryRepresentation.length; i++) {
      if (imp1.binaryRepresentation[i] != imp2.binaryRepresentation[i]) {
        diff++;
      }
    }
    return diff == 1;
  }

  Implicant _combine(Implicant imp1, Implicant imp2) {
    String combinedBinary = '';
    for (int i = 0; i < imp1.binaryRepresentation.length; i++) {
      if (imp1.binaryRepresentation[i] == imp2.binaryRepresentation[i]) {
        combinedBinary += imp1.binaryRepresentation[i];
      } else {
        combinedBinary += '-';
      }
    }
    var combinedMinterms = SplayTreeSet<int>.from(imp1.minterms)..addAll(imp2.minterms);
    return Implicant(combinedMinterms.toList(), combinedBinary);
  }
}
