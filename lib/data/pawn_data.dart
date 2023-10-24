import 'package:flutter/material.dart';

class PawnData {
  final Offset offset;
  final bool isKilled;

  PawnData({
    required this.offset,
    required this.isKilled,
  });

  static PawnData createEmpty() => PawnData(offset: Offset.zero, isKilled: false);


}
