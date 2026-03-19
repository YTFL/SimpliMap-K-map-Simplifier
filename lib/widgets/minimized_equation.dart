import 'package:flutter/material.dart';

class MinimizedEquation extends StatelessWidget {
  const MinimizedEquation({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder content
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'F = A\'B\'C\'D\' + A\'B\'CD + A\'BC\'D + ...',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
