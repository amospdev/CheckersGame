import 'package:flutter/material.dart';

class CellPainter extends CustomPainter {
  Color color;
  final Offset offset;

  CellPainter(this.color, this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    canvas.drawRect(const Offset(0, 0) & size, paint);
  }

  @override
  bool shouldRepaint(covariant CellPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
