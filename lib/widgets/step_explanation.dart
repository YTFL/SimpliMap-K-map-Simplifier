import 'package:flutter/material.dart';
import 'package:simplimap/models/kmap_group.dart';

class StepExplanation extends StatelessWidget {
  const StepExplanation({
    super.key,
    required this.groups,
    required this.finalEquation,
  });

  final List<KmapGroup> groups;
  final String finalEquation;

  List<KmapGroup> _displayGroups() {
    if (groups.isNotEmpty) {
      return groups;
    }

    final eq = finalEquation.trim();
    if (eq.isEmpty || eq == '-' || eq == '0' || eq == '1') {
      return const [];
    }

    final parts = _extractEquationTerms(eq);
    if (parts.isEmpty) {
      return const [];
    }

    return List.generate(parts.length, (index) {
      return KmapGroup(
        minterms: const [],
        simplifiedTerm: parts[index],
        color: _fallbackColor(index),
        isEssential: false,
        eliminationLogic:
            'Derived from the minimized equation output. Solve once more to sync detailed minterm coverage text.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFE8FBF5) : const Color(0xFF153D38);
    final cardColor = isDark ? const Color(0xFF0F2424) : const Color(0xFFFDFDFD);
    final borderColor = isDark ? const Color(0xFF2E5651) : const Color(0xFFD5E9E4);

    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1D4D46) : const Color(0xFFE7F8F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: isDark ? const Color(0xFF8EF5DC) : const Color(0xFF0F8B8D),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Step-by-Step Explanation',
                    style: textTheme.titleMedium?.copyWith(color: titleColor),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSetupSection(context),
              const SizedBox(height: 16),
              _buildGroupingSection(context),
              const SizedBox(height: 16),
              _buildEpiSection(context),
              const SizedBox(height: 20),
              _buildFinalEquationSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor = isDark ? const Color(0xFF122E2E) : const Color(0xFFF6FBF9);
    final sectionBorder = isDark ? const Color(0xFF2C4D4A) : const Color(0xFFD8ECE7);

    return _sectionShell(
      context: context,
      title: '1. Problem Setup',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sectionColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sectionBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Variables: ${_selectedVariables().isEmpty ? '-' : _selectedVariables().join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFFD4EFE8) : const Color(0xFF2A504D),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Original Target Minterms/Maxterms: ${_targetTerms().isEmpty ? 'None' : _targetTerms().join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFFD4EFE8) : const Color(0xFF2A504D),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupingSection(BuildContext context) {
    final displayGroups = _displayGroups();

    return _sectionShell(
      context: context,
      title: '2. Groupings & Simplification',
      child: displayGroups.isEmpty
          ? _emptyState(
              context,
              'No extracted groups yet. Solve the K-Map to see linked group explanations.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < displayGroups.length; i++) ...[
                  _groupCard(context, displayGroups[i]),
                  if (i < displayGroups.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }

  Widget _buildEpiSection(BuildContext context) {
    final essentialGroups = groups.where((g) => g.isEssential).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (essentialGroups.isEmpty) {
      return _sectionShell(
        context: context,
        title: '3. Essential Prime Implicants',
        child: _supportingTextBlock(
          context,
          'No essential prime implicants were identified for this solution. Coverage can be completed using interchangeable group combinations.',
        ),
      );
    }

    return _sectionShell(
      context: context,
      title: '3. Essential Prime Implicants',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF122E2E) : const Color(0xFFF6FBF9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF2C4D4A) : const Color(0xFFD8ECE7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The following groups are essential because each uniquely covers at least one target term:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFFD4EFE8) : const Color(0xFF2A504D),
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < essentialGroups.length; i++) ...[
              _essentialGroupLine(context, essentialGroups[i]),
              if (i < essentialGroups.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _essentialGroupLine(BuildContext context, KmapGroup group) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverageText = group.minterms.isEmpty
        ? 'coverage terms unavailable'
        : 'covers m(${group.minterms.join(', ')})';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: group.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFFD4EFE8) : const Color(0xFF2A504D),
                  ),
              children: [
                TextSpan(
                  text: group.simplifiedTerm,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                ),
                TextSpan(text: ' - $coverageText'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalEquationSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _sectionShell(
      context: context,
      title: '4. Final Minimized Equation',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF153833) : const Color(0xFFE8F9F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF4B9186) : const Color(0xFF9ED4C8),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF1E6155)).withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SelectableText(
          finalEquation.trim().isEmpty ? '-' : finalEquation,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                color: isDark ? const Color(0xFFE8FBF5) : const Color(0xFF103A34),
              ),
        ),
      ),
    );
  }

  Widget _groupCard(BuildContext context, KmapGroup group) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF122B2B) : const Color(0xFFFAFEFC);
    final borderColor = isDark ? const Color(0xFF2A4A49) : const Color(0xFFD9ECE8);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: group.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: group.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? const Color(0xFFD5EEE8) : const Color(0xFF2C534F),
                                  ),
                              children: [
                                TextSpan(
                                  text: '${_groupType(group.minterms.length)} ',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: group.minterms.isEmpty
                                      ? 'derived from simplified equation'
                                      : 'covering m(${group.minterms.join(', ')})',
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (group.isEssential)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF25493C) : const Color(0xFFDDF4EA),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Essential',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isDark ? const Color(0xFFAEEBD2) : const Color(0xFF1B6A4C),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      group.simplifiedTerm,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            color: isDark ? const Color(0xFFE8FBF5) : const Color(0xFF123936),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      group.eliminationLogic,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFF9DC2BC) : const Color(0xFF647D79),
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionShell({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFDDF6EF) : const Color(0xFF1F4A45),
              ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _supportingTextBlock(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF122E2E) : const Color(0xFFF6FBF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF2C4D4A) : const Color(0xFFD8ECE7)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFFD4EFE8) : const Color(0xFF2A504D),
              height: 1.35,
            ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF122E2E) : const Color(0xFFF6FBF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF2C4D4A) : const Color(0xFFD8ECE7)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFFA3C7C0) : const Color(0xFF627B77),
            ),
      ),
    );
  }

  String _groupType(int size) {
    if (size >= 8) return 'Octet';
    if (size == 4) return 'Quad';
    if (size == 2) return 'Pair';
    return 'Single';
  }

  List<String> _extractEquationTerms(String equation) {
    if (equation.contains('(') && equation.contains(')')) {
      final clauses = RegExp(r'\([^)]*\)')
          .allMatches(equation)
          .map((m) => m.group(0)?.trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (clauses.isNotEmpty) {
        return clauses;
      }
    }

    return equation
        .split('+')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  Color _fallbackColor(int index) {
    const palette = [
      Color(0xFF4DD0E1),
      Color(0xFFFFB74D),
      Color(0xFF81C784),
      Color(0xFFE57373),
      Color(0xFF9575CD),
      Color(0xFF4DB6AC),
    ];
    return palette[index % palette.length];
  }

  List<String> _selectedVariables() {
    final found = <String>{};
    final regex = RegExp(r'[A-D]');
    for (final group in groups) {
      for (final match in regex.allMatches(group.simplifiedTerm)) {
        found.add(match.group(0)!);
      }
    }

    final ordered = found.toList()
      ..sort((a, b) => a.compareTo(b));
    return ordered;
  }

  List<int> _targetTerms() {
    final terms = <int>{};
    for (final group in groups) {
      terms.addAll(group.minterms);
    }
    final sorted = terms.toList()..sort();
    return sorted;
  }
}

