import 'package:flutter/material.dart';

class BackgroundGame extends StatelessWidget {
  const BackgroundGame({super.key});

  @override
  Widget build(BuildContext context) => _backgroundGame();

  Widget _backgroundGame() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/wood_background_vintage.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade400.withOpacity(0.5),
                // Colors.black45,
                Colors.black87,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        )
      ],
    );
  }
}
