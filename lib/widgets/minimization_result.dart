import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';

class MinimizationResult extends StatelessWidget {
  const MinimizationResult({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KMapProvider>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Minimized Expressions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildResultRow('SOP', provider.minimizedSOP),
            const Divider(height: 20),
            _buildResultRow('POS', provider.minimizedPOS),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String type, String expression) {
    return Row(
      children: [
        Text('$type: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
        Expanded(
          child: SelectableText(
            expression.isEmpty ? '-' : expression,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
