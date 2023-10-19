import 'package:flutter/material.dart';

class CheckersKingPainter extends CustomPainter {
  final Color color;

  CheckersKingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Draw the main piece
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    // Draw the crown.svg using a Path
    final crownPath = Path();
    crownPath.moveTo(size.width * 0.2, size.height * 0.4);
    crownPath.lineTo(size.width * 0.4, size.height * 0.4);
    crownPath.lineTo(size.width * 0.5, size.height * 0.2);
    crownPath.lineTo(size.width * 0.6, size.height * 0.4);
    crownPath.lineTo(size.width * 0.8, size.height * 0.4);
    crownPath.lineTo(size.width * 0.7, size.height * 0.6);
    crownPath.lineTo(size.width * 0.8, size.height * 0.8);
    crownPath.lineTo(size.width * 0.2, size.height * 0.8);
    crownPath.lineTo(size.width * 0.3, size.height * 0.6);
    crownPath.close();

    paint.color = Colors.yellow;
    canvas.drawPath(crownPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
