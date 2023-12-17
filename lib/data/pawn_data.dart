import 'package:flutter/material.dart';

class PawnData {
  final Offset offset;
  final bool isKilled;
  final bool isAnimating;
  final int indexKilled;
  final bool hasCapture;

  PawnData({
    required this.offset,
    required this.hasCapture,
    required this.isKilled,
    required this.isAnimating,
    required this.indexKilled,
  });

  static PawnData createEmpty() => PawnData(
      offset: Offset.zero,
      isKilled: false,
      hasCapture: false,
      isAnimating: false,
      indexKilled: -1);
}
