import 'package:flutter/material.dart';
import 'package:untitled/ui/gradient_stroke_painter.dart';

class TurnTimer extends StatelessWidget {
  const TurnTimer({super.key});

  @override
  Widget build(BuildContext context) => _timer();

  Widget _timer() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: GradientStrokePainter(
                  strokeWidth: 3.5, // Adjust the stroke width as needed
                  gradient: const LinearGradient(
                    colors: [
                      Colors.lightBlueAccent,
                      Colors.greenAccent,
                      Colors.blueAccent
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Container(
              width: 57,
              height: 57,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.grey.shade500.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(1, 2),
                      blurRadius: 1.5,
                      color: Colors.black.withOpacity(0.4),
                    )
                  ]),
              child: const Text(
                "45",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            "Time Left",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
          ),
        )
      ],
    );
  }
}
