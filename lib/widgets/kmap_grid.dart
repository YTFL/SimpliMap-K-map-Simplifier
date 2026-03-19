
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';

class KMapGrid extends StatelessWidget {
  // Correct Gray Code ordering for 4 variables
  final List<int> _fourVarColOrder = [0, 1, 3, 2];
  final List<int> _fourVarRowOrder = [0, 1, 3, 2];

  // Correct Gray Code ordering for 3 variables
  final List<int> _threeVarColOrder = [0, 1, 3, 2];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KMapProvider>(context);
    final is3Var = provider.numVariables == 3;

    final int rows = is3Var ? 2 : 4;
    final int cols = is3Var ? 4 : 4;

    // Labels for the grid
    final List<String> rowLabels = is3Var ? ['A', ' '] : ['AB', '00', '01', '11', '10'];
    final List<String> colLabels = is3Var ? ['BC', '00', '01', '11', '10'] : ['CD', '00', '01', '11', '10'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cols + 1, (index) {
            return Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                index == 0 ? (is3Var ? 'A\\BC' : 'AB\\CD') : colLabels[index],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),
        for (int i = 0; i < rows; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  is3Var ? (i == 0 ? '0' : '1') : rowLabels[i + 1],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              for (int j = 0; j < cols; j++) _buildGridCell(context, provider, i, j, is3Var),
            ],
          ),
      ],
    );
  }

  Widget _buildGridCell(BuildContext context, KMapProvider provider, int row, int col, bool is3Var) {
    final int minterm = _getMintermIndex(row, col, is3Var);

    final bool isSelected = minterm < provider.gridState.length && provider.gridState[minterm] == 1;

    return GestureDetector(
      onTap: () {
        if (minterm < provider.gridState.length) {
          final currentVal = provider.gridState[minterm];
          provider.setGridState(minterm, 1 - currentVal); // Toggle between 0 and 1
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: isSelected ? Colors.lightBlue.withOpacity(0.5) : Colors.transparent,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  minterm.toString(),
                  style: TextStyle(fontSize: 10, color: Colors.white54),
                ),
              ),
            ),
            Center(
              child: Text(
                isSelected ? '1' : '0',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getMintermIndex(int row, int col, bool is3Var) {
    if (is3Var) {
      // 3-variable map (2 rows, 4 cols)
      final logicalCol = _threeVarColOrder[col];
      return (row * 4) + logicalCol;
    } else {
      // 4-variable map (4 rows, 4 cols)
      final logicalRow = _fourVarRowOrder[row];
      final logicalCol = _fourVarColOrder[col];
      return (logicalRow * 4) + logicalCol;
    }
  }
}
