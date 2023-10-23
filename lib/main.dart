import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/widgets/main_game_border.dart';
import 'package:untitled/ui/widgets/pawn_piece.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => GameViewModel(),
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'דמקה',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameBoard(),
    );
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  late AnimationController _pawnMoveController;
  late Animation<Offset> _animation;
  Pawn? currPawn;

  static const int _pawnMoveDuration = 165;

  @override
  void initState() {
    super.initState();

    _pawnMoveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_pawnMoveController);

    _animation.addListener(_animationListener);
  }

  void _animationListener() {
    final gameViewModel = context.read<GameViewModel>();
    gameViewModel.onMovePawn(_animation.value);
    if (_pawnMoveController.isCompleted) {
      currPawn = null;
      gameViewModel.onPawnMoveAnimationFinish();
    }
  }

  void _startPawnMoveAnimation(GameViewModel gameViewModel) {
    print("_startPawnMoveAnimation start");
    gameViewModel.onPawnMoveAnimationStart();
    _pawnMoveController.forward(from: 0.0);
  }

  void movePlayerTo(int row, int column, GameViewModel gameViewModel) {
    final endPosition = Offset(column.toDouble(), row.toDouble());

    currPawn = gameViewModel.getCurrPawn();

    _pawnMoveController.duration =
        Duration(milliseconds: (gameViewModel.pathSize * _pawnMoveDuration));

    _animation = Tween<Offset>(
      begin: currPawn?.offset.value,
      end: endPosition,
    ).animate(_pawnMoveController);

    _startPawnMoveAnimation(gameViewModel);
  }

  @override
  Widget build(BuildContext context) => _mainBoard(context);

  Widget _mainBoard(BuildContext context) {
    final cellSize =
        (MediaQuery.of(context).size.width - 10) / 8; // For an 8x8 board

    return Scaffold(
      body: Center(
        child: RepaintBoundary(
            child: Stack(
          children: [
            RepaintBoundary(child: MainGameBorder(cellSize)),
            Container(
              margin: const EdgeInsets.only(left: 5, top: 5),
              width: 8 * cellSize,
              // Increased size to account for the border and prevent cut-off
              height: 8 * cellSize,
              child: Stack(
                children: [..._getCells(cellSize), ..._getPawns(cellSize)],
              ),
            )
          ],
        )),
      ),
    );
  }

  void handleCellTap(GameViewModel gameViewModel, CellDetails cell) =>
      movePlayerTo(cell.row, cell.column, gameViewModel);

  void handlePlayerTap(GameViewModel gameViewModel, Pawn pawn) {}

  List<Widget> _getCells(double cellSize) {
    print("1 MAIN WIDGET _getCells");

    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);

    return gameViewModel.boardCells
        .map((cell) => ValueListenableBuilder<Color>(
              valueListenable: cell.tmpColor,
              builder: (ctx, cellColor, _) {
                print("2 MAIN WIDGET _getCells ValueListenableBuilder: $cell");

                return Positioned(
                  left: cell.offset.dx * cellSize,
                  top: cell.offset.dy * cellSize,
                  child: RepaintBoundary(
                      child: GestureDetector(
                    onTap: () {
                      TapOnBoard tapOnBoard =
                          gameViewModel.onClickCell(cell.row, cell.column);
                      if (tapOnBoard == TapOnBoard.END) {
                        handleCellTap(gameViewModel, cell);
                      }
                    },
                    child: Container(
                      key: ValueKey(cell.id),
                      color: cellColor,
                      width: cellSize,
                      height: cellSize,
                    ),
                  )),
                );
              },
            ))
        .toList();
  }

  List<Widget> _getPawns(double cellSize) {
    print("1 MAIN WIDGET _getPawns");

    List<Pawn> currPawns = Provider.of<GameViewModel>(context).pawns;
    Pawn? nowCurrPawn = currPawn;
    if (nowCurrPawn != null) {
      Pawn currPawn = currPawns[currPawns.indexOf(nowCurrPawn)];
      currPawns.remove(currPawn);
      currPawns.add(currPawn);
    }

    return currPawns
        .map((pawn) => ValueListenableBuilder<Offset>(
              valueListenable: pawn.offset,
              builder: (ctx, offset, _) {
                return _buildPawnWidget(pawn, cellSize, currPawn == pawn);
              },
            ))
        .toList();
  }

  Widget _getPawnAnimate(double cellSize) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _animation.value.dx * cellSize,
              _animation.value.dy * cellSize,
            ),
            child: _buildPawnWidget(
                currPawn ?? Pawn.createEmpty(), cellSize, true),
          );
        });
  }

  Widget _buildPawnWidget(Pawn pawn, double cellSize, bool isAnimatingPawn) =>
      PawnPiece(pawn, isAnimatingPawn, cellSize, _pawnMoveController);

  @override
  void dispose() {
    _pawnMoveController.dispose();
    _animation.removeListener(_animationListener);
    super.dispose();
  }
}
