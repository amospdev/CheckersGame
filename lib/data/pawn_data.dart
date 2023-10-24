import 'package:flutter/material.dart';

class PawnData {
  final Offset offset;
  final bool isKilled;
  final bool isAnimating;

  PawnData({
    required this.offset,
    required this.isKilled,
    required this.isAnimating,
  });

  static PawnData createEmpty() =>
      PawnData(offset: Offset.zero, isKilled: false, isAnimating: false);
}
