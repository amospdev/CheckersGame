import 'package:flutter/material.dart';

class GradientStrokePainter extends CustomPainter {
  final double strokeWidth;
  final Gradient gradient;
  final BorderRadius borderRadius;

  GradientStrokePainter({
    required this.strokeWidth,
    required this.gradient,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(Rect.fromPoints(
        const Offset(0, 0),
        Offset(size.width, size.height),
      ));

    final Rect rect = Rect.fromPoints(
      Offset(strokeWidth / 2, strokeWidth / 2),
      Offset(size.width - strokeWidth / 2, size.height - strokeWidth / 2),
    );

    final RRect roundedRect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    canvas.drawRRect(roundedRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
