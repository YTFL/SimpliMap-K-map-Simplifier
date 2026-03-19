
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';
import 'package:simplimap/widgets/kmap_grid.dart';
import 'package:simplimap/widgets/minimization_result.dart';
import 'package:simplimap/widgets/step_breakdown.dart';

class SolverScreen extends StatefulWidget {
  const SolverScreen({super.key, required this.isDarkMode, required this.onToggleTheme});

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<SolverScreen> createState() => _SolverScreenState();
}

class _SolverScreenState extends State<SolverScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to the provider's expression changes and update the controller
    _controller.text = Provider.of<KMapProvider>(context, listen: false).expression;
    Provider.of<KMapProvider>(context, listen: false).addListener(_onProviderChange);
  }

  @override
  void dispose() {
    Provider.of<KMapProvider>(context, listen: false).removeListener(_onProviderChange);
    _controller.dispose();
    super.dispose();
  }

  void _onProviderChange() {
    // When the provider's expression changes (e.g., from clearing the map),
    // update the text controller if it's different.
    if (_controller.text != Provider.of<KMapProvider>(context, listen: false).expression) {
      _controller.text = Provider.of<KMapProvider>(context, listen: false).expression;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KMapProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? const Color(0xFFE8FBF5) : const Color(0xFF143A37);
    final subtitleColor = isDark ? const Color(0xFFB7DCD1) : const Color(0xFF32514E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpliMap'),
        actions: [
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
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
                  const SizedBox(height: 6),
                  Text(
                    'Build, toggle, and simplify expressions with a cleaner visual workflow.',
                    style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
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
                            hintText: 'Example: A\'B + C',
                            prefixIcon: Icon(Icons.functions_rounded),
                          ),
                          onChanged: provider.setExpression,
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
                                  Expanded(child: _buildMapTypeSelector(provider)),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    icon: const Icon(Icons.auto_fix_high_rounded),
                                    label: const Text('Solve'),
                                    onPressed: provider.solve,
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
                                _buildMapTypeSelector(provider),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  icon: const Icon(Icons.auto_fix_high_rounded),
                                  label: const Text('Solve'),
                                  onPressed: provider.solve,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'K-Map',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: headingColor,
                          ),
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

  Widget _buildMapTypeSelector(KMapProvider provider) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: true, label: Text('SOP')),
        ButtonSegment(value: false, label: Text('POS')),
      ],
      selected: {provider.isSOP},
      onSelectionChanged: (selection) => provider.setIsSOP(selection.first),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

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

