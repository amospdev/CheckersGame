import 'package:flutter/material.dart';
import 'package:untitled/data/pawn/pawn_details_data.dart';
import 'package:untitled/data/pawn/pawn_position_data.dart';
import 'package:untitled/extensions/screen_ratio.dart';
import 'package:untitled/game/checkers_board.dart';

class BoardElementsDetails {
  static late final double cellSize;
  static late final double sizeBoardByOrientation;
  static late final double discardPileArea;
  static late final double innerBoardSize;
  static const double paddingGameBoard = 8;
  static const double borderWidthGameBoard = 10;
  static const Offset pawnKilledScaleOffset = Offset(0.6, 0.6);
  static const double pawnAliveScale = 0.75;

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

  static PawnPosition pawnPosition(PawnDetailsData pawnData, bool isSomeWhite) {

    double heightOffset = (BoardElementsDetails.discardPileArea / 2);
    double topNotKilled = (pawnData.offset.dy * cellSize) + heightOffset;

    double topKilledWhite =
        innerBoardSize + (discardPileArea / 2) + borderWidthGameBoard;
    double topKilledBlack = 0;

    double top = pawnData.isKilled
        ? isSomeWhite
            ? topKilledWhite
            : topKilledBlack
        : topNotKilled;

    double leftNotKilled = (pawnData.offset.dx * cellSize);

    double cellSizeKilledWithFactor = cellSize * pawnKilledScaleOffset.dx;

    double padding = -(cellSizeKilledWithFactor * (1 - pawnAliveScale));
    double margin = 3;

    double leftKilled =
        padding + (pawnData.indexKilled * (cellSizeKilledWithFactor + margin));

    double left = pawnData.isKilled ? leftKilled : leftNotKilled;

    double distancePoints = (Offset(leftNotKilled, topNotKilled) -
            Offset(leftKilled, isSomeWhite ? topKilledWhite : topKilledBlack))
        .distance;

    return PawnPosition(
        left: left, top: top, durationMove: (distancePoints * 5));
  }

  static double _innerBoardSize() => cellSize * CheckersBoard.sizeBoard;
}
