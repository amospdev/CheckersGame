import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/ui/screens/game/game_view_model.dart';
import 'package:untitled/ui/painter/gradient_stroke_painter.dart';
import 'package:untitled/ui/widgets/animation/pulse_animation.dart';

class TurnTimer extends StatelessWidget {
  const TurnTimer({super.key});

  @override
  Widget build(BuildContext context) =>
      _timer(gameViewModel: Provider.of<GameViewModel>(context, listen: false));

  Widget _timer({required GameViewModel gameViewModel}) {
    const timerSize = 60.0;
    const limitPulse = 5;
    return ValueListenableBuilder<int>(
      valueListenable: gameViewModel.turnTimerText,
      builder: (ctx, time, _) {
        Widget timer = Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: timerSize,
              height: timerSize,
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
              width: timerSize - 7,
              height: timerSize - 7,
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
                style: TextStyle(
                  color: time <= limitPulse ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        );

        return Column(
          children: [
            time <= limitPulse ? PulseAnimation(child: timer) : timer,
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "Time Left",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20),
              ),
            )
          ],
        );
      },
    );
  }
}
