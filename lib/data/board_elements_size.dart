import 'package:flutter/material.dart';
import 'package:untitled/extensions/screen_ratio.dart';
import 'package:untitled/game/checkers_board.dart';

class BoardElementsSize {
  static late final double cellSize;
  static late final double sizeBoardByOrientation;
  static late final double discardPileArea;
  static late final double innerBoardSize;
  static const double paddingGameBoard = 8;
  static const double borderWidthGameBoard = 10;

  static void measurementElementsBoardSize(
      {required MediaQueryData mediaQueryData}) {
    final sizeBoardByOrientation =
        mediaQueryData.sizeByOrientation; // For an 8x8 board

    cellSize = (sizeBoardByOrientation -
            (paddingGameBoard * 2) -
            (borderWidthGameBoard * 2)) /
        CheckersBoard.sizeBoard;

    discardPileArea = _discardPileArea();

    innerBoardSize = _innerBoardSize();
  }

  static double _discardPileArea() {
    final discardPileAreaTop = cellSize + borderWidthGameBoard;
    final discardPileAreaBottom = cellSize + borderWidthGameBoard;
    final discardPileArea = discardPileAreaTop + discardPileAreaBottom;
    return discardPileArea;
  }

  static double _innerBoardSize() => cellSize * CheckersBoard.sizeBoard;
}
