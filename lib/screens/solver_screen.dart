
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/models/implicant.dart';
import 'package:simplimap/models/kmap_group.dart';
import 'package:simplimap/state/kmap_provider.dart';
import 'package:simplimap/widgets/kmap_grid.dart';
import 'package:simplimap/widgets/minimization_result.dart';
import 'package:simplimap/widgets/step_breakdown.dart';
import 'package:simplimap/widgets/step_explanation.dart';

class SolverScreen extends StatefulWidget {
  const SolverScreen({super.key, required this.themeMode, required this.onThemeModeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SolverScreen> createState() => _SolverScreenState();
}

class _SolverScreenState extends State<SolverScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _dontCareController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _kMapSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Listen to the provider's expression changes and update the controller
    final provider = Provider.of<KMapProvider>(context, listen: false);
    _controller.text = provider.expression;
    _dontCareController.text = provider.dontCareExpression;
    provider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    Provider.of<KMapProvider>(context, listen: false).removeListener(_onProviderChange);
    _controller.dispose();
    _dontCareController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _solveAndScrollToKMap(KMapProvider provider) {
    provider.solve();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _kMapSectionKey.currentContext;
      if (targetContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
      );
    });
  }

  void _onProviderChange() {
    // When the provider's expression changes (e.g., from clearing the map),
    // update the text controller if it's different.
    final provider = Provider.of<KMapProvider>(context, listen: false);
    if (_controller.text != provider.expression) {
      _controller.text = provider.expression;
    }
    if (_dontCareController.text != provider.dontCareExpression) {
      _dontCareController.text = provider.dontCareExpression;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KMapProvider>(context);
    final groups = _buildKmapGroups(provider);
    final finalEquation = provider.showingSOP ? provider.minimizedSOP : provider.minimizedPOS;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? const Color(0xFFE8FBF5) : const Color(0xFF143A37);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpliMap'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
              ),
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.settings_suggest_rounded, size: 16),
                  tooltip: 'Use device theme',
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded, size: 16),
                  tooltip: 'Light mode',
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded, size: 16),
                  tooltip: 'Dark mode',
                ),
              ],
              selected: {widget.themeMode},
              onSelectionChanged: (selection) => widget.onThemeModeChanged(selection.first),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF061A1A), Color(0xFF0B2C2B), Color(0xFF1A2A2A)]
                : const [Color(0xFFF8FFFC), Color(0xFFE8F6F0), Color(0xFFF9F6EC)],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Karnaugh Map Solver',
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: headingColor),
                  ),
                  const SizedBox(height: 16),
                  _GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expression Input', style: textTheme.titleMedium),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            labelText: 'Boolean expression',
                            hintText: 'E.g. A\'B + C or m1 + m5 + m6',
                            prefixIcon: Icon(Icons.functions_rounded),
                          ),
                          onChanged: provider.setExpression,
                        ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _dontCareController,
                            decoration: const InputDecoration(
                              labelText: 'Don\'t care values D (optional)',
                              hintText: 'E.g. m2 + m3 + m5',
                              prefixIcon: Center(
                                widthFactor: 1,
                                child: Text(
                                  'D',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                                ),
                              ),
                            ),
                            onChanged: provider.setDontCareExpression,
                          ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 760;
                            if (isWide) {
                              return Row(
                                children: [
                                  Expanded(child: _buildVariableSelector(provider)),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    icon: const Icon(Icons.auto_fix_high_rounded),
                                    label: const Text('Solve'),
                                    onPressed: () => _solveAndScrollToKMap(provider),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Reset'),
                                    onPressed: provider.clearMap,
                                  ),
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildVariableSelector(provider),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  icon: const Icon(Icons.auto_fix_high_rounded),
                                  label: const Text('Solve'),
                                  onPressed: () => _solveAndScrollToKMap(provider),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reset'),
                                  onPressed: provider.clearMap,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _GlassPanel(
                    key: _kMapSectionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(
                            children: [
                              Text(
                                'K-Map',
                                style: textTheme.titleMedium?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: headingColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFFFFA726).withValues(alpha: 0.3) : const Color(0xFFFF9500).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '1 = Selected, D = Don\'t care',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isDark ? const Color(0xFFFFA726) : const Color(0xFFFF6F00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        const Center(child: KMapGrid()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const MinimizationResult(),
                  const SizedBox(height: 16),
                  const StepBreakdown(),
                  const SizedBox(height: 16),
                  StepExplanation(
                    groups: groups,
                    finalEquation: finalEquation,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVariableSelector(KMapProvider provider) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 3, label: Text('3 Variables')),
        ButtonSegment(value: 4, label: Text('4 Variables')),
      ],
      selected: {provider.numVariables},
      onSelectionChanged: (selection) => provider.setNumVariables(selection.first),
    );
  }

  List<int> _buildTargetTerms(KMapProvider provider) {
    final minterms = <int>[];
    final dontCares = <int>[];
    for (int i = 0; i < provider.gridState.length; i++) {
      if (provider.gridState[i] == 1) {
        minterms.add(i);
      } else if (provider.gridState[i] == 2) {
        dontCares.add(i);
      }
    }

    minterms.sort();
    dontCares.sort();

    if (provider.showingSOP) {
      return minterms;
    }

    final termCount = 1 << provider.numVariables;
    return List.generate(termCount, (i) => i)
        .where((i) => !minterms.contains(i) && !dontCares.contains(i))
        .toList();
  }

  List<int> _buildDontCares(KMapProvider provider) {
    final dontCares = <int>[];
    for (int i = 0; i < provider.gridState.length; i++) {
      if (provider.gridState[i] == 2) {
        dontCares.add(i);
      }
    }
    dontCares.sort();
    return dontCares;
  }

  List<KmapGroup> _buildKmapGroups(KMapProvider provider) {
    final minterms = <int>[];
    final dontCares = <int>[];
    for (int i = 0; i < provider.gridState.length; i++) {
      if (provider.gridState[i] == 1) {
        minterms.add(i);
      } else if (provider.gridState[i] == 2) {
        dontCares.add(i);
      }
    }

    minterms.sort();
    dontCares.sort();

    final activeTerms = provider.showingSOP
        ? minterms
        : List.generate(1 << provider.numVariables, (i) => i)
            .where((i) => !minterms.contains(i) && !dontCares.contains(i))
            .toList();

    if (activeTerms.isEmpty) {
      return const [];
    }

    final implicants = provider.minimizer.findPrimeImplicants(
      activeTerms,
      provider.numVariables,
      dontCares,
    );
    if (implicants.isEmpty) {
      return const [];
    }

    final targetTerms = activeTerms.toSet();
    final variables = ['A', 'B', 'C', 'D'].sublist(0, provider.numVariables);

    final coverageCount = <int, int>{};
    for (final term in targetTerms) {
      int count = 0;
      for (final implicant in implicants) {
        if (implicant.covers(term)) {
          count++;
        }
      }
      coverageCount[term] = count;
    }

    return List.generate(implicants.length, (index) {
      final implicant = implicants[index];
      final essential = targetTerms.any((term) =>
          implicant.covers(term) && (coverageCount[term] ?? 0) == 1);

      final simplifiedTerm = provider.showingSOP
          ? provider.minimizer.implicantToTerm(implicant, variables)
          : provider.minimizer.implicantToPosClause(implicant, variables);

      return KmapGroup(
        minterms: implicant.minterms,
        simplifiedTerm: simplifiedTerm,
        color: _groupColor(index),
        isEssential: essential,
        eliminationLogic: _buildEliminationLogic(implicant, variables),
      );
    });
  }

  String _buildEliminationLogic(Implicant implicant, List<String> variables) {
    final eliminated = <String>[];
    final fixed = <String>[];

    for (int i = 0; i < implicant.binaryRepresentation.length; i++) {
      final bit = implicant.binaryRepresentation[i];
      if (bit == '-') {
        eliminated.add(variables[i]);
      } else {
        fixed.add('${variables[i]}=${bit == '1' ? '1' : '0'}');
      }
    }

    if (eliminated.isEmpty) {
      return 'No variables are eliminated in this grouping, so all literals remain in the simplified term.';
    }

    final eliminationText = eliminated.join(' and ');
    final fixedText = fixed.isEmpty ? '' : ' Remaining fixed states: ${fixed.join(', ')}.';
    return '$eliminationText change across the grouped cells, so they are eliminated.$fixedText';
  }

  Color _groupColor(int index) {
    const palette = [
      Color(0xFF4DD0E1),
      Color(0xFFFFB74D),
      Color(0xFF81C784),
      Color(0xFFE57373),
      Color(0xFF9575CD),
      Color(0xFF4DB6AC),
      Color(0xFFA1887F),
      Color(0xFFF06292),
    ];
    return palette[index % palette.length];
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF103232).withValues(alpha: 0.76) : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF3E746C).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF113230)).withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

