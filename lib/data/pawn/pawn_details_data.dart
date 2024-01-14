import 'package:flutter/material.dart';

class PawnDetailsData {
  final Offset offset;
  final bool isKilled;
  final bool isAnimating;
  final int indexKilled;
  final bool hasCapture;

  PawnDetailsData({
    required this.offset,
    required this.hasCapture,
    required this.isKilled,
    required this.isAnimating,
    required this.indexKilled,
  });

  static PawnDetailsData createEmpty() => PawnDetailsData(
      offset: Offset.zero,
      isKilled: false,
      hasCapture: false,
      isAnimating: false,
      indexKilled: -1);
}
