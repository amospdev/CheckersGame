import 'package:flutter/material.dart';

class PawnPainter extends CustomPainter {
  final Color color;

  PawnPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double mainRadius = ((size.width / 2) * 0.75);

    // הצל
    const shadowOffset = 3.0;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center + const Offset(shadowOffset, shadowOffset),
        mainRadius, shadowPaint);

    // השחקן הראשי
    final mainCirclePaint = Paint()..color = color;
    canvas.drawCircle(center, mainRadius, mainCirclePaint);

    // העיגולים הפנימיים של השחקן
    final innerCirclePaint = Paint()
      ..color = color.darker()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final shadowPaint1 = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    double innerCircleOffset0 = mainRadius * 0.1;
    double innerCircleOffset1 = mainRadius * 0.25;
    double innerCircleOffset2 = mainRadius * 0.5;
    double innerCircleOffset3 = mainRadius * 0.75;
    double innerCircleOffset4 = mainRadius * 0.95;

    canvas.drawCircle(center, innerCircleOffset0, shadowPaint1);
    canvas.drawCircle(center, innerCircleOffset1, innerCirclePaint);
    canvas.drawCircle(center, innerCircleOffset2, shadowPaint1);

    final innerCirclePaint22 = Paint()
      ..color = Colors.black12.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, innerCircleOffset2, innerCirclePaint22);

    canvas.drawCircle(center, innerCircleOffset3, innerCirclePaint);
    canvas.drawCircle(center, innerCircleOffset3, innerCirclePaint22);

    final shadowPaint2 = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black38
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    canvas.drawCircle(center, innerCircleOffset4, shadowPaint2);

  }

  @override
  bool shouldRepaint(covariant PawnPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

extension ColorUtils on Color {
  Color darker([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final factor = 1 - percent / 100;
    return Color.fromRGBO(
      (red * factor).round(),
      (green * factor).round(),
      (blue * factor).round(),
      1,
    );
  }
}
