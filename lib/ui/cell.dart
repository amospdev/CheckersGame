import 'package:flutter/material.dart';

class CellPainter extends CustomPainter {
  Color color;

  CellPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    canvas.drawRect(const Offset(0, 0) & size, paint);
  }

  @override
  bool shouldRepaint(covariant CellPainter oldDelegate) {
    bool shouldRepaintByColor = color.value != oldDelegate.color.value;

    return shouldRepaintByColor;
  }
}
