
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';

class KMapCell extends StatelessWidget {
  final int index;

  const KMapCell({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KMapProvider>(context);
    final value = provider.gridState[index];

    String displayValue;
    switch (value) {
      case 1:
        displayValue = '1';
        break;
      case 2:
        displayValue = 'X';
        break;
      default:
        displayValue = '0';
        break;
    }

    return InkWell(
      onTap: () {
        int nextValue = (value + 1) % 3;
        provider.setGridState(index, nextValue);
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade600),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
