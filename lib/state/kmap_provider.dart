import 'package:flutter/foundation.dart';
import 'package:simplimap/logic/boolean_parser.dart';
import 'package:simplimap/logic/minimizer.dart';
import 'package:simplimap/models/implicant.dart';

class KMapProvider with ChangeNotifier {
  String _expression = '';
  int _numVariables = 3;
  bool _isSOP = true;
  List<int> _gridState = List.filled(16, 0);
  String _minimizedSOP = '';
  String _minimizedPOS = '';
  List<Implicant> _primeImplicants = [];

  final BooleanParser _parser = BooleanParser();
  final Minimizer _minimizer = Minimizer();

  String get expression => _expression;
  int get numVariables => _numVariables;
  bool get isSOP => _isSOP;
  List<int> get gridState => _gridState;
  String get minimizedSOP => _minimizedSOP;
  String get minimizedPOS => _minimizedPOS;
  List<Implicant> get primeImplicants => _primeImplicants;
  Minimizer get minimizer => _minimizer;

  void setExpression(String value) {
    _expression = value;
    _updateGridFromExpression();
    notifyListeners();
  }

  void setNumVariables(int value) {
    _numVariables = value;
    _gridState = List.filled(pow(2, value).toInt(), 0);
    _updateGridFromExpression(); // Re-evaluate expression with new variable count
    notifyListeners();
  }

  void setIsSOP(bool value) {
    _isSOP = value;
    // Potentially re-evaluate or clear, for now just notify
    notifyListeners();
  }

  void setGridState(int index, int value) {
    if (index < _gridState.length) {
      _gridState[index] = value;
      _updateExpressionFromGrid();
      _primeImplicants = [];
      _minimizedSOP = '';
      _minimizedPOS = '';
      notifyListeners();
    }
  }

  void clearMap() {
    _gridState = List.filled(pow(2, _numVariables).toInt(), 0);
    _expression = '';
    _minimizedSOP = '';
    _minimizedPOS = '';
    _primeImplicants = [];
    notifyListeners();
  }

  void solve() {
    final minterms = _getMintermsFromGrid();
    _primeImplicants = _minimizer.findPrimeImplicants(minterms, _numVariables);
    _minimizedSOP = _minimizer.minimize(minterms, _numVariables);
    
    // For POS, minimize the don't cares (0s)
    final maxMinterms = pow(2, _numVariables).toInt();
    final zeroMinterms = List.generate(maxMinterms, (i) => i)
                            .where((i) => !minterms.contains(i))
                            .toList();
                            
    // The logic to get inverted POS is more complex, this is a placeholder
    String invertedSOP = _minimizer.minimize(zeroMinterms, _numVariables);
    _minimizedPOS = _convertToPOS(invertedSOP);

    notifyListeners();
  }

  void _updateGridFromExpression() {
    try {
      final minterms = _parser.parse(_expression, _numVariables);
      _gridState = List.filled(pow(2, _numVariables).toInt(), 0);
      for (var minterm in minterms) {
        if (minterm < _gridState.length) {
          _gridState[minterm] = 1;
        }
      }
    } catch (e) {
      // Handle parsing errors, maybe show an error message to the user
      if (kDebugMode) {
        print("Parsing error: $e");
      }
    }
  }

  void _updateExpressionFromGrid() {
      final minterms = _getMintermsFromGrid();
      // This is a simplification. A full conversion back to a readable expression is complex.
      // For now, let's just reflect the minterms.
      _expression = minterms.map((m) => 'm$m').join(' + ');
  }

  List<int> _getMintermsFromGrid() {
      final minterms = <int>[];
      for (int i = 0; i < _gridState.length; i++) {
          if (_gridState[i] == 1) {
              minterms.add(i);
          }
      }
      return minterms;
  }

  String _convertToPOS(String sop) {
    // This is a very simplistic placeholder for De Morgan's law application
    // It does not correctly handle the logic for complex expressions.
    if (sop == "1") return "0";
    if (sop == "0") return "1";

    // Replace + with * and vice-versa, and invert literals
    String pos = sop.replaceAll(' + ', ' * ');
    // This regex is tricky. A' becomes A, A becomes A'.
    pos = pos.split(' ').map((term) {
      if (term == '*') return '+';
      return "($term)"; // Wrap terms in parenthesis
    }).join(' ');

    // Invert literals (A -> A', B' -> B)
    pos = pos.replaceAllMapped(RegExp(r"([A-D])(')?"), (m) {
      return m.group(2) == "'" ? m.group(1)! : "${m.group(1)}'";
    });
    
    return pos;
  }

  // Helper to calculate power of 2
  int pow(int base, int exp) {
    int res = 1;
    for(int i = 0; i < exp; i++){
      res *= base;
    }
    return res;
  }

}
