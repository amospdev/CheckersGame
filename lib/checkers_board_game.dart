import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/checker_board_painter.dart';
import 'package:untitled/game_view_model.dart';

class CheckerBoard extends StatefulWidget {
  @override
  _CheckerBoardState createState() => _CheckerBoardState();
}

class _CheckerBoardState extends State<CheckerBoard> {
  int selectedRow = -1;
  int selectedCol = -1;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width * 0.95;
    double height = size.width * 0.95;

    return Consumer<GameViewModel>(builder: (context, gameViewModel, child) {
      return GestureDetector(
        onTapUp: (details) {
          onTapUpCell(details, gameViewModel);
        },
        child: CustomPaint(
          painter: CheckerBoardPainter(
              gameViewModel.selectedRow,
              gameViewModel.selectedCol,
              gameViewModel.board,
              gameViewModel.paths,
              true),
          size: Size(width, height),
        ),
      );
    });
  }

  void onTapUpCell(TapUpDetails tapUpDetails, GameViewModel gameViewModel) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final RenderBox renderBox = renderObject as RenderBox;

    final localPosition = renderBox.globalToLocal(tapUpDetails.globalPosition);
    final cellWidth = renderBox.size.width / 8;
    final cellHeight = renderBox.size.height / 8;

    int selectedRow = (localPosition.dy / cellHeight).floor();
    int selectedCol = (localPosition.dx / cellWidth).floor();

    gameViewModel.onTapBoardGame(selectedRow, selectedCol);
  }
}
