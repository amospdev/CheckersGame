import 'package:flutter/material.dart';

class PawnData {
  final Offset offset;
  final bool isKilled;
  final bool isAnimating;
  final int indexKilled;

  PawnData({
    required this.offset,
    required this.isKilled,
    required this.isAnimating,
    required this.indexKilled,
  });

  static PawnData createEmpty() => PawnData(
      offset: Offset.zero,
      isKilled: false,
      isAnimating: false,
      indexKilled: -1);
}
