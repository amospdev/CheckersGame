import 'package:flutter/material.dart';

class MainGameBorder extends StatelessWidget {
  final double cellSize;

  const MainGameBorder(this.cellSize, {super.key});

  @override
  Widget build(BuildContext context) => _mainGameBorder(cellSize);

  Widget _mainGameBorder(double cellSize) => Container(
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
}
