import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/checker_board_painter.dart';
import 'package:untitled/game_view_model.dart';

class CheckerBoard extends StatefulWidget {
  @override
  _CheckerBoardState createState() => _CheckerBoardState();
}

class _CheckerBoardState extends State<CheckerBoard> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("DO ACTION");
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width * 0.95;
    double height = size.width * 0.95;

    return Consumer<GameViewModel>(builder: (context, gameViewModel, child) {
      return GestureDetector(
        onTapUp: (details) => _onTapUpCell(details, gameViewModel),
        child: CustomPaint(
          painter: CheckerBoardPainter(
              gameViewModel.selectedRow,
              gameViewModel.selectedCol,
              gameViewModel.destinationRow,
              gameViewModel.destinationCol,
              gameViewModel.board,
              gameViewModel.paths,
              true),
          size: Size(width, height),
        ),
      );
    });
  }

  void _onTapUpCell(
      TapUpDetails tapUpDetails, GameViewModel gameViewModel) /*async*/ {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final RenderBox renderBox = renderObject as RenderBox;

    final localPosition = renderBox.globalToLocal(tapUpDetails.globalPosition);
    final cellWidth = renderBox.size.width / 8;
    final cellHeight = renderBox.size.height / 8;

    int selectedRow = (localPosition.dy / cellHeight).floor();
    int selectedCol = (localPosition.dx / cellWidth).floor();

    gameViewModel.onTapBoardGame(selectedRow, selectedCol);


    print(
        "WIDGET SR: ${gameViewModel.selectedRow}, SC: ${gameViewModel.selectedCol}, DR: ${gameViewModel.destinationRow}, DC: ${gameViewModel.destinationCol}");

    // setState(() {
    //
    // });

    // await Future.delayed(const Duration(milliseconds: 1));

    // if (gameViewModel.selectedRow != -1 &&
    //     gameViewModel.selectedCol != -1 &&
    //     gameViewModel.destinationRow != -1 &&
    //     gameViewModel.destinationCol != -1) {
    //   gameViewModel.endTurn();
    // }
  }
}
