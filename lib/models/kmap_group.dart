import 'package:flutter/material.dart';

class KmapGroup {
  final List<int> minterms;
  final String simplifiedTerm;
  final Color color;
  final bool isEssential;
  final String eliminationLogic;

  const KmapGroup({
    required this.minterms,
    required this.simplifiedTerm,
    required this.color,
    required this.isEssential,
    required this.eliminationLogic,
  });
}

@Deprecated('Use KmapGroup instead.')
class KMapGroup extends KmapGroup {
  KMapGroup({required List<int> minterms, required String term})
      : super(
          minterms: minterms,
          simplifiedTerm: term,
          color: const Color(0xFF4DB6AC),
          isEssential: false,
          eliminationLogic: 'Variables that changed across the grouping are eliminated.',
        );

  String get term => simplifiedTerm;
}