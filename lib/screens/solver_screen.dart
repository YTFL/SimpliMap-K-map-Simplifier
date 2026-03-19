
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';
import '../widgets/kmap_grid.dart';
import '../widgets/minimization_result.dart';
import '../widgets/step_breakdown.dart';

class SolverScreen extends StatefulWidget {
  const SolverScreen({super.key});

  @override
  _SolverScreenState createState() => _SolverScreenState();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karnaugh Map Simplifier'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input and Controls
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Enter Boolean Expression (SOP)',
                        hintText: 'e.g., A\'B + C',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => provider.setExpression(value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildVariableSelector(provider),
                        _buildMapTypeSelector(provider),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear'),
                          onPressed: () {
                            provider.clearMap();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // K-Map Visualization
            Center(
              child: KMapGrid(),
            ),
            const SizedBox(height: 20),

            // Results
            const Text('Result', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const MinimizationResult(),
            const SizedBox(height: 20),

            const Text('Step-by-Step Breakdown', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const StepBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableSelector(KMapProvider provider) {
    return DropdownButton<int>(
      value: provider.numVariables,
      onChanged: (value) {
        if (value != null) {
          provider.setNumVariables(value);
        }
      },
      items: const [
        DropdownMenuItem(value: 3, child: Text('3 Variables')),
        DropdownMenuItem(value: 4, child: Text('4 Variables')),
      ],
    );
  }

  Widget _buildMapTypeSelector(KMapProvider provider) {
    return DropdownButton<bool>(
      value: provider.isSOP,
      onChanged: (value) {
        if (value != null) {
          provider.setIsSOP(value);
        }
      },
      items: const [
        DropdownMenuItem(value: true, child: Text('SOP')),
        DropdownMenuItem(value: false, child: Text('POS')),
      ],
    );
  }
}
