import 'package:flutter/material.dart';

class MainGameBorder extends StatelessWidget {
  const MainGameBorder({super.key});

  @override
  Widget build(BuildContext context) => _mainGameBorder();

  Widget _mainGameBorder() => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double width = constraints.maxWidth - 10;
          double cellSize = width / 8; // For an 8x8 board

          return Container(
              width: 8 * cellSize + 10,
              // Increased size to account for the border and prevent cut-off
              height: 8 * cellSize + 10,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.brown.shade200,
                  width: 10.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(5, 5),
                  ),
                ],
              ));
        },
      );
}
