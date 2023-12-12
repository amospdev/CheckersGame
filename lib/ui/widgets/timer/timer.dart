import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/gradient_stroke_painter.dart';

class TurnTimer extends StatelessWidget {
  const TurnTimer({super.key});

  @override
  Widget build(BuildContext context) =>
      _timer(gameViewModel: Provider.of<GameViewModel>(context, listen: false));

  Widget _timer({required GameViewModel gameViewModel}) {
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
            ValueListenableBuilder<int>(
              valueListenable: gameViewModel.turnTimerText,
              builder: (ctx, time, _) {
                return Container(
                  width: 53,
                  height: 53,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0.5, 1),
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.6),
                        )
                      ]),
                  child: Text(
                    time.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                );
              },
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

  List<Color> interpolateColors(Color startColor, Color endColor, int steps) {
    final double stepR = (endColor.red - startColor.red) / (steps - 1);
    final double stepG = (endColor.green - startColor.green) / (steps - 1);
    final double stepB = (endColor.blue - startColor.blue) / (steps - 1);

    List<Color> colors = [];
    for (int i = 0; i < steps; i++) {
      int r = (startColor.red + stepR * i).round();
      int g = (startColor.green + stepG * i).round();
      int b = (startColor.blue + stepB * i).round();
      colors.add(Color.fromARGB(255, r, g, b));
    }

    return colors;
  }
}
