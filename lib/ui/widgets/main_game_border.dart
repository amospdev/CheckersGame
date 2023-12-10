import 'package:flutter/material.dart';

class MainGameBorder extends StatelessWidget {
  static const double innerBorderWidthGameBoard = 2;
  final double borderWidthGameBoard;
  final double innerBoardSize;

  const MainGameBorder(this.borderWidthGameBoard, this.innerBoardSize,
      {super.key});

  @override
  Widget build(BuildContext context) => _bordersGameBoard(
      borderWidthGameBoard, innerBoardSize, innerBorderWidthGameBoard);

  Widget _bordersGameBoard(double borderWidthGameBoard, double innerBoardSize,
      double innerBorderWidthGameBoard) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade300.withOpacity(0.7),
              // Green border
              width: borderWidthGameBoard,
            ),
          ),
          width: innerBoardSize + (borderWidthGameBoard * 2),
          height: innerBoardSize + (borderWidthGameBoard * 2),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                // Green border
                width: innerBorderWidthGameBoard,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.5,
                  offset: Offset(1.5, 1.5),
                ),
              ]),
          width: innerBoardSize + innerBorderWidthGameBoard,
          height: innerBoardSize + innerBorderWidthGameBoard,
        )
      ],
    );
  }
}
