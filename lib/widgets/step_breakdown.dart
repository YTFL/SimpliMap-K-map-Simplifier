import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';
import 'package:simplimap/models/implicant.dart';
import 'package:simplimap/logic/minimizer.dart';

class StepBreakdown extends StatelessWidget {
  const StepBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KMapProvider>();
    final primeImplicants = provider.primeImplicants;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prime Implicants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (primeImplicants.isEmpty)
              const Text('No prime implicants found. Click \'Solve\' to generate them.')
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

    return Wrap(
      spacing: 12.0,
      runSpacing: 8.0,
      children: primeImplicants.map((pi) {
        return Chip(
          label: Text(
            minimizer.implicantToTerm(pi, variables),
            style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal.shade100,
          side: BorderSide(color: Colors.teal.shade300),
        );
      }).toList(),
    );
  }
}

extension on KMapProvider {
  Minimizer get minimizer => _minimizer;
}

// Extension on Minimizer to expose the private method for the widget
extension MinimizerWidgetExtension on Minimizer {
  String implicantToTerm(Implicant implicant, List<String> variables) {
    return _implicantToTerm(implicant, variables);
  }
}
