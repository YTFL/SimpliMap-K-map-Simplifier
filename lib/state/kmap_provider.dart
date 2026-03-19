import 'package:flutter/foundation.dart';
import 'package:simplimap/logic/boolean_parser.dart';
import 'package:simplimap/logic/minimizer.dart';
import 'package:simplimap/models/implicant.dart';

class KMapProvider with ChangeNotifier {
  String _expression = '';
  String _dontCareExpression = '';
  int _numVariables = 3;
  bool _showingSOP = true;
  // State values: 0 = unselected/off, 1 = selected/on, 2 = don't care
  List<int> _gridState = List.filled(16, 0);
  String _minimizedSOP = '';
  String _minimizedPOS = '';
  List<Implicant> _sopPrimeImplicants = [];
  List<Implicant> _posPrimeImplicants = [];

  final BooleanParser _parser = BooleanParser();
  final Minimizer _minimizer = Minimizer();

  String get expression => _expression;
  String get dontCareExpression => _dontCareExpression;
  int get numVariables => _numVariables;
  bool get showingSOP => _showingSOP;
  List<int> get gridState => _gridState;
  String get minimizedSOP => _minimizedSOP;
  String get minimizedPOS => _minimizedPOS;
  List<Implicant> get primeImplicants => _showingSOP ? _sopPrimeImplicants : _posPrimeImplicants;
  List<Implicant> get sopPrimeImplicants => _sopPrimeImplicants;
  List<Implicant> get posPrimeImplicants => _posPrimeImplicants;
  Minimizer get minimizer => _minimizer;

  void setExpression(String value) {
    _expression = value;
    _updateGridFromExpression();
    notifyListeners();
  }

  void setDontCareExpression(String value) {
    _dontCareExpression = value;
    _updateGridFromDontCareExpression();
    notifyListeners();
  }

  void setNumVariables(int value) {
    _numVariables = value;
    _gridState = List.filled(pow(2, value).toInt(), 0);
    _updateGridFromExpression(); // Re-evaluate expression with new variable count
    _updateGridFromDontCareExpression(); // Re-evaluate don't cares
    notifyListeners();
  }

  void setShowingSOP(bool value) {
    _showingSOP = value;
    notifyListeners();
  }

  void setGridState(int index, int value) {
    if (index < _gridState.length) {
      _gridState[index] = value;
      _updateExpressionFromGrid();
      _sopPrimeImplicants = [];
      _posPrimeImplicants = [];
      _minimizedSOP = '';
      _minimizedPOS = '';
      notifyListeners();
    }
  }

  void cycleCellState(int index) {
    if (index < _gridState.length) {
      // Cycle through states: 0 -> 1 -> 2 -> 0
      _gridState[index] = (_gridState[index] + 1) % 3;
      _updateExpressionFromGrid();
      _sopPrimeImplicants = [];
      _posPrimeImplicants = [];
      _minimizedSOP = '';
      _minimizedPOS = '';
      notifyListeners();
    }
  }

  void clearMap() {
    _gridState = List.filled(pow(2, _numVariables).toInt(), 0);
    _expression = '';
    _dontCareExpression = '';
    _minimizedSOP = '';
    _minimizedPOS = '';
    _sopPrimeImplicants = [];
    _posPrimeImplicants = [];
    notifyListeners();
  }

  void solve() {
    final minterms = _getMintermsFromGrid()..sort();
    final dontCares = _getDontCaresFromGrid()..sort();
    
    // Calculate SOP prime implicants from minterms with don't cares as optional
    _sopPrimeImplicants = _minimizer.findPrimeImplicants(minterms, _numVariables, dontCares);
    _minimizedSOP = _minimizer.minimizeSOP(minterms, _numVariables, dontCares);
    
    // For POS, minimize the zeros (maxterms) excluding don't cares
    final maxMinterms = pow(2, _numVariables).toInt();
    final zeroMinterms = List.generate(maxMinterms, (i) => i)
                            .where((i) => !minterms.contains(i) && !dontCares.contains(i))
                            .toList();
                            
    // POS is solved directly from zero cells using the same bit-mask QMC core.
    _posPrimeImplicants = _minimizer.findPrimeImplicants(zeroMinterms, _numVariables, dontCares);
    _minimizedPOS = _minimizer.minimizePOS(zeroMinterms, _numVariables, dontCares);

    notifyListeners();
  }

  void _updateGridFromExpression() {
    try {
      final minterms = _parser.parse(_expression, _numVariables);
      // Clear only the 1s, preserve don't cares (2s)
      for (int i = 0; i < _gridState.length; i++) {
        if (_gridState[i] == 1) {
          _gridState[i] = 0;
        }
      }
      for (var minterm in minterms) {
        if (minterm < _gridState.length && _gridState[minterm] != 2) {
          _gridState[minterm] = 1;
        }
      }
    } catch (e) {
      // Handle parsing errors
      if (kDebugMode) {
        print("Parsing error: $e");
      }
    }
  }

  void _updateGridFromDontCareExpression() {
    try {
      final dontCares = _parser.parse(_dontCareExpression, _numVariables);
      // Clear only the 2s (don't cares), preserve 1s
      for (int i = 0; i < _gridState.length; i++) {
        if (_gridState[i] == 2) {
          _gridState[i] = 0;
        }
      }
      for (var dontCare in dontCares) {
        if (dontCare < _gridState.length && _gridState[dontCare] != 1) {
          _gridState[dontCare] = 2;
        }
      }
    } catch (e) {
      // Handle parsing errors
      if (kDebugMode) {
        print("Parsing error: $e");
      }
    }
  }

  void _updateExpressionFromGrid() {
      final minterms = _getMintermsFromGrid();
      final dontCares = _getDontCaresFromGrid();
      // Reflect current grid states back into input fields.
      _expression = minterms.map((m) => 'm$m').join(' + ');
      _dontCareExpression = dontCares.map((m) => 'm$m').join(' + ');
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

  List<int> _getDontCaresFromGrid() {
      final dontCares = <int>[];
      for (int i = 0; i < _gridState.length; i++) {
          if (_gridState[i] == 2) {
              dontCares.add(i);
          }
      }
      return dontCares;
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
