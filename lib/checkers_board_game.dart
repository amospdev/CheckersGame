import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/checker_board_painter.dart';
import 'package:untitled/game/checkers_board.dart';
import 'package:untitled/game_view_model.dart';

class CheckerBoard extends StatefulWidget {
  @override
  _CheckerBoardState createState() => _CheckerBoardState();
}

class _CheckerBoardState extends State<CheckerBoard>
    with SingleTickerProviderStateMixin {
  // int selectedRow = -1;
  // int selectedCol = -1;
  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });
  }

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
              gameViewModel.destinationRow,
              gameViewModel.destinationCol,
              gameViewModel.board,
              gameViewModel.paths,
              true,
              _animation.value,
              _controller.isAnimating),
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

    TapOnBoard tapOnBoard =
        gameViewModel.onTapBoardGame(selectedRow, selectedCol);

    if (tapOnBoard == TapOnBoard.END) {
      print("TapOnBoard.END");
      _startAnimation(gameViewModel);
    }
  }

  void _startAnimation(GameViewModel gameViewModel) async {
    List<PositionDetails> positionDetailsList =
        gameViewModel.onStartAnimation();
    for (final (index, positionDetails) in positionDetailsList.indexed) {
      if (index + 1 == positionDetailsList.length) break;
      gameViewModel.onPoint(
          positionDetails.position, positionDetailsList[index + 1].position);
      _controller.forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    _animation.addListener(() {
      // print("_animation.value: ${_animation.value}");
      // _controller.isCompleted
      if (_controller.isCompleted) {
        print("_controller.isCompleted _animation value: ${_animation.value}");
        Position lastPosition = positionDetailsList.last.position;

        if (lastPosition.row == gameViewModel.destinationRow &&
            lastPosition.column == gameViewModel.destinationCol) {
          gameViewModel.onTapEndPosition();
        }
      } else {
        print("_animation value: ${_animation.value}");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
