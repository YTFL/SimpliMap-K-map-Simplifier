import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';
import 'package:simplimap/models/implicant.dart';

class StepBreakdown extends StatelessWidget {
  const StepBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KMapProvider>();
    final primeImplicants = provider.primeImplicants;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textTheme = Theme.of(context).textTheme;
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
                    color: isDark ? const Color(0xFF47381D) : const Color(0xFFFFF1D8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    color: isDark ? const Color(0xFFFFC97F) : const Color(0xFFC77D1A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text('Prime Implicants', style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            if (primeImplicants.isEmpty)
              Text(
                'No prime implicants available yet. Tap Solve to generate a breakdown.',
                style: textTheme.bodyMedium?.copyWith(
                  color: isDark ? const Color(0xFFAACFC7) : const Color(0xFF55716E),
                ),
              )
            else
              _buildPIList(primeImplicants, provider.numVariables, context),
          ],
        ),
      ),
    );
  }

  Widget _buildPIList(List<Implicant> primeImplicants, int numVariables, BuildContext context) {
    final variables = ['A', 'B', 'C', 'D'].sublist(0, numVariables);
    final minimizer = context.read<KMapProvider>().minimizer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 12.0,
      runSpacing: 8.0,
      children: primeImplicants.map((pi) {
        return Chip(
          label: Text(
            minimizer.implicantToTerm(pi, variables),
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFDDFFF5) : const Color(0xFF083B37),
            ),
          ),
          avatar: Icon(
            Icons.circle,
            size: 10,
            color: isDark ? const Color(0xFF8EF5DC) : const Color(0xFF0F8B8D),
          ),
          backgroundColor: isDark ? const Color(0xFF18413D) : const Color(0xFFE7F8F3),
          side: BorderSide(color: isDark ? const Color(0xFF3A7A72) : Colors.teal.shade200),
        );
      }).toList(),
    );
  }
}
