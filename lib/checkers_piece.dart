import 'package:flutter/material.dart';

class CheckersPiecePainter extends CustomPainter {
  final Color color;

  CheckersPiecePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final shadowPaint = Paint()
      ..color = Colors.grey.withOpacity(0.8)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.35), size.width * 0.5, shadowPaint);

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

