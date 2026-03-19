import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';

class MinimizationResult extends StatelessWidget {
  const MinimizationResult({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KMapProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFE8FBF5) : const Color(0xFF153D38);

    final textTheme = Theme.of(context).textTheme;
    final isShowingSOP = provider.showingSOP;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF17433E) : const Color(0xFFD9F4EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: isDark ? const Color(0xFF8EF5DC) : const Color(0xFF0F8B8D),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Minimized Expressions',
                  style: textTheme.titleMedium?.copyWith(color: titleColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // SOP/POS Toggle
            Align(
              alignment: Alignment.centerRight,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.add_rounded, size: 16),
                    label: Text('SOP'),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.close_rounded, size: 16),
                    label: Text('POS'),
                  ),
                ],
                selected: {isShowingSOP},
                onSelectionChanged: (selection) =>
                    provider.setShowingSOP(selection.first),
              ),
            ),
            const SizedBox(height: 12),
            // Display the selected expression
            if (isShowingSOP)
              _buildResultRow(context, 'SOP', provider.minimizedSOP)
            else
              _buildResultRow(context, 'POS', provider.minimizedPOS),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String type, String expression) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF133434) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF356E67) : Colors.teal.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A4A43) : const Color(0xFFE7F8F3),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF8EF5DC) : const Color(0xFF0F8B8D),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              expression.isEmpty ? '-' : expression,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFE8FBF5) : const Color(0xFF0E2E2B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
