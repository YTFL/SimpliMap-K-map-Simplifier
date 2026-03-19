
import 'dart:math';

class BooleanParser {
  List<int> parse(String expression, int numVariables) {
    if (expression.trim().isEmpty) {
      return [];
    }

    final variables = numVariables == 3 ? ['A', 'B', 'C'] : ['A', 'B', 'C', 'D'];
    final minterms = <int>{};

    // Split by '+' to handle Sum of Products
    final terms = expression.split('+').map((t) => t.trim()).toList();

    for (final term in terms) {
      if (term.isEmpty) continue;

      final termMinterms = _getMintermsForTerm(term, variables);
      minterms.addAll(termMinterms);
    }

    return minterms.toList();
  }

  Set<int> _getMintermsForTerm(String term, List<String> variables) {
    final termMinterms = <int>{};

    // Map variable to its state in the term: 1 (normal), 0 (negated), -1 (absent)
    final termValues = <String, int>{};
    for (int i = 0; i < term.length; i++) {
      final char = term[i];
      if (variables.contains(char)) {
        if (i + 1 < term.length && (term[i + 1] == '\'' || term[i + 1] == '’')) {
          termValues[char] = 0; // Negated
          i++; // Skip the apostrophe
        } else {
          termValues[char] = 1; // Normal
        }
      }
    }

    final absentVars = variables.where((v) => !termValues.containsKey(v)).toList();
    final numAbsent = absentVars.length;

    // If a term contains all variables, it corresponds to one minterm
    if (numAbsent == 0) {
      String binaryString = variables.map((v) => termValues[v].toString()).join('');
      termMinterms.add(int.parse(binaryString, radix: 2));
    } else {
      // If variables are absent, the term represents a group of minterms
      final numCombinations = pow(2, numAbsent);
      for (int i = 0; i < numCombinations; i++) {
        String iBinary = i.toRadixString(2).padLeft(numAbsent, '0');
        final tempValues = Map<String, int>.from(termValues);
        for (int j = 0; j < numAbsent; j++) {
          tempValues[absentVars[j]] = int.parse(iBinary[j]);
        }

        String binaryString = variables.map((v) => tempValues[v].toString()).join('');
        termMinterms.add(int.parse(binaryString, radix: 2));
      }
    }

    return termMinterms;
  }
}
