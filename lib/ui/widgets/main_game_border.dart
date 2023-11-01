import 'package:flutter/material.dart';
import 'package:untitled/extensions/screen_ratio.dart';
import 'package:untitled/game/checkers_board.dart';

class MainGameBorder extends StatelessWidget {
  const MainGameBorder({super.key});

  @override
  Widget build(BuildContext context) =>
      _mainGameBorder((MediaQuery.of(context).sizeByOrientation - 10) / CheckersBoard.sizeBoard);

  Widget _mainGameBorder(double cellSize) => Container(
      width: CheckersBoard.sizeBoard * cellSize + 10,
      // Increased size to account for the border and prevent cut-off
      height: CheckersBoard.sizeBoard * cellSize + 10,
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
}
