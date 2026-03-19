
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/models/implicant.dart';
import 'package:simplimap/state/kmap_provider.dart';

class KMapGrid extends StatelessWidget {
  const KMapGrid({super.key});

  // Correct Gray Code ordering for 4 variables
  static const List<int> _fourVarColOrder = [0, 1, 3, 2];
  static const List<int> _fourVarRowOrder = [0, 1, 3, 2];

  // Correct Gray Code ordering for 3 variables
  static const List<int> _threeVarColOrder = [0, 1, 3, 2];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KMapProvider>(context);
    final is3Var = provider.numVariables == 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int rows = is3Var ? 2 : 4;
    final int cols = is3Var ? 4 : 4;
    const panelPadding = 12.0;
    const cellGap = 4.0;
    final totalColumns = cols + 1;

    final textTheme = Theme.of(context).textTheme;

    // Labels for the grid
    final List<String> rowLabels = is3Var ? ['A', ' '] : ['AB', '00', '01', '11', '10'];
    final List<String> colLabels = is3Var ? ['BC', '00', '01', '11', '10'] : ['CD', '00', '01', '11', '10'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final usableWidth = constraints.maxWidth - (panelPadding * 2);
        final totalGapWidth = (totalColumns - 1) * cellGap;
        final rawCellSize = (usableWidth - totalGapWidth) / totalColumns;
        final cellSize = rawCellSize.clamp(24.0, 72.0);
        final headerColor = isDark ? const Color(0xFFC8F7E9) : const Color(0xFF1B534D);
        final gridBgColor = isDark ? const Color(0xFF0A2F2B) : const Color(0xFFDDF4EE);
        final cellOnColor = isDark ? const Color(0xFF19B394) : const Color(0xFF12A58A);
        final cellOffColor = isDark ? const Color(0xFF0F3C37) : const Color(0xFFF4FFFB);
        final borderColor = isDark ? const Color(0xFF59B8A1) : const Color(0xFF77BCAA);
        final valueOnColor = Colors.white;
        final valueOffColor = isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF2F5B56);
        final mintermColor = isDark ? Colors.white.withValues(alpha: 0.62) : const Color(0xFF4D6F69);

        return Container(
          decoration: BoxDecoration(
            color: gridBgColor.withValues(alpha: isDark ? 0.93 : 0.98),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFF2D625A)).withValues(alpha: isDark ? 0.18 : 0.14),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(panelPadding),
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int index = 0; index < cols + 1; index++) ...[
                        if (index > 0) const SizedBox(width: cellGap),
                        SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: Center(
                            child: Text(
                              index == 0 ? (is3Var ? 'A\\BC' : 'AB\\CD') : colLabels[index],
                              style: textTheme.bodySmall?.copyWith(color: headerColor, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  for (int i = 0; i < rows; i++) ...[
                    if (i > 0) const SizedBox(height: cellGap),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: Center(
                            child: Text(
                              is3Var ? (i == 0 ? '0' : '1') : rowLabels[i + 1],
                              style: textTheme.bodySmall?.copyWith(color: headerColor, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        for (int j = 0; j < cols; j++) ...[
                          if (j > 0) const SizedBox(width: cellGap),
                          _buildGridCell(
                            context,
                            provider,
                            i,
                            j,
                            is3Var,
                            cellSize,
                            cellOnColor,
                            cellOffColor,
                            borderColor,
                            valueOnColor,
                            valueOffColor,
                            mintermColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _KMapOverlayPainter(
                      implicants: provider.primeImplicants,
                      is3Var: is3Var,
                      rows: rows,
                      cols: cols,
                      cellSize: cellSize,
                      cellGap: cellGap,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridCell(
    BuildContext context,
    KMapProvider provider,
    int row,
    int col,
    bool is3Var,
    double cellSize,
    Color cellOnColor,
    Color cellOffColor,
    Color borderColor,
    Color valueOnColor,
    Color valueOffColor,
    Color mintermColor,
  ) {
    final int minterm = _getMintermIndex(row, col, is3Var);

    final bool isSelected = minterm < provider.gridState.length && provider.gridState[minterm] == 1;

    return GestureDetector(
      onTap: () {
        if (minterm < provider.gridState.length) {
          final currentVal = provider.gridState[minterm];
          provider.setGridState(minterm, 1 - currentVal);
        }
      },
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
          color: isSelected ? cellOnColor.withValues(alpha: 0.92) : cellOffColor,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  minterm.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mintermColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                isSelected ? '1' : '0',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? valueOnColor : valueOffColor,
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

class _KMapOverlayPainter extends CustomPainter {
  _KMapOverlayPainter({
    required this.implicants,
    required this.is3Var,
    required this.rows,
    required this.cols,
    required this.cellSize,
    required this.cellGap,
    required this.isDark,
  });

  final List<Implicant> implicants;
  final bool is3Var;
  final int rows;
  final int cols;
  final double cellSize;
  final double cellGap;
  final bool isDark;

  static const List<int> _fourVarColOrder = [0, 1, 3, 2];
  static const List<int> _fourVarRowOrder = [0, 1, 3, 2];
  static const List<int> _threeVarColOrder = [0, 1, 3, 2];

  @override
  void paint(Canvas canvas, Size size) {
    if (implicants.isEmpty) {
      return;
    }

    final palette = isDark
        ? <Color>[
            const Color(0xFFF9A825),
            const Color(0xFF26C6DA),
            const Color(0xFFA5D6A7),
            const Color(0xFFEF9A9A),
            const Color(0xFFCE93D8),
            const Color(0xFFFFCC80),
          ]
        : <Color>[
            const Color(0xFFE65100),
            const Color(0xFF006064),
            const Color(0xFF2E7D32),
            const Color(0xFFC62828),
            const Color(0xFF6A1B9A),
            const Color(0xFFAD1457),
          ];

    final sortedImplicants = [...implicants]..sort((a, b) => b.minterms.length.compareTo(a.minterms.length));

    for (var i = 0; i < sortedImplicants.length; i++) {
      final group = sortedImplicants[i];
      final color = palette[i % palette.length];
      final strokeWidth = 2.0;
      final inset = 2.0 + (i % 3) * 2.0;

      final paint = Paint()
        ..color = color.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      final coords = <(int, int)>[];
      for (final minterm in group.minterms) {
        final coord = _mintermToDisplayCell(minterm, is3Var);
        if (coord != null) {
          coords.add(coord);
        }
      }

      if (coords.isEmpty) {
        continue;
      }

      final rowSet = coords.map((c) => c.$1).toSet();
      final colSet = coords.map((c) => c.$2).toSet();

      final rowRanges = _findCyclicRanges(rowSet, rows);
      final colRanges = _findCyclicRanges(colSet, cols);

      // Typical K-map groups are Cartesian products of row and column selections.
      final isCartesian = coords.length == rowSet.length * colSet.length;

      if (!isCartesian || rowRanges.isEmpty || colRanges.isEmpty) {
        for (final coord in coords) {
          _drawLoopRect(canvas, paint, inset, coord.$1, coord.$1, coord.$2, coord.$2);
        }
        continue;
      }

      for (final rowRange in rowRanges) {
        for (final colRange in colRanges) {
          _drawLoopRect(canvas, paint, inset, rowRange.$1, rowRange.$2, colRange.$1, colRange.$2);
        }
      }
    }
  }

  void _drawLoopRect(
    Canvas canvas,
    Paint paint,
    double inset,
    int rowStart,
    int rowEnd,
    int colStart,
    int colEnd,
  ) {
    final x = cellSize + colStart * (cellSize + cellGap);
    final y = cellSize + rowStart * (cellSize + cellGap);

    final colCount = colEnd - colStart + 1;
    final rowCount = rowEnd - rowStart + 1;

    final width = colCount * cellSize + (colCount - 1) * cellGap;
    final height = rowCount * cellSize + (rowCount - 1) * cellGap;

    final rect = Rect.fromLTWH(
      x + inset,
      y + inset,
      (width - inset * 2).clamp(6, width),
      (height - inset * 2).clamp(6, height),
    );

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), paint);
  }

  List<(int, int)> _findCyclicRanges(Set<int> indexSet, int dimensionSize) {
    if (indexSet.isEmpty) {
      return [];
    }

    final sorted = indexSet.toList()..sort();
    final k = sorted.length;

    if (k == dimensionSize) {
      return [(0, dimensionSize - 1)];
    }

    for (int start = 0; start < dimensionSize; start++) {
      final interval = <int>{};
      for (int offset = 0; offset < k; offset++) {
        interval.add((start + offset) % dimensionSize);
      }

      if (_sameSet(interval, indexSet)) {
        final end = start + k - 1;
        if (end < dimensionSize) {
          return [(start, end)];
        }

        final wrappedEnd = end % dimensionSize;
        return [
          (0, wrappedEnd),
          (start, dimensionSize - 1),
        ];
      }
    }

    // Fallback for non-contiguous selection: draw each index as a separate 1-cell range.
    return sorted.map((value) => (value, value)).toList();
  }

  bool _sameSet(Set<int> a, Set<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
  }

  (int, int)? _mintermToDisplayCell(int minterm, bool is3Var) {
    if (is3Var) {
      final row = minterm ~/ 4;
      final logicalCol = minterm % 4;
      final col = _threeVarColOrder.indexOf(logicalCol);
      if (col == -1) {
        return null;
      }
      return (row, col);
    }

    final logicalRow = minterm ~/ 4;
    final logicalCol = minterm % 4;
    final row = _fourVarRowOrder.indexOf(logicalRow);
    final col = _fourVarColOrder.indexOf(logicalCol);

    if (row == -1 || col == -1) {
      return null;
    }
    return (row, col);
  }

  @override
  bool shouldRepaint(covariant _KMapOverlayPainter oldDelegate) {
    return oldDelegate.implicants != implicants ||
        oldDelegate.is3Var != is3Var ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.cellGap != cellGap ||
        oldDelegate.isDark != isDark;
  }
}
