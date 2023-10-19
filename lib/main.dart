import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/cell.dart';
import 'package:untitled/ui/widgets/main_game_border.dart';
import 'package:untitled/ui/widgets/pawn_piece.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => GameViewModel(),
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (ctx, gameViewModel, child) {
        return MaterialApp(
          title: 'דמקה',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: GameBoard(gameViewModel),
        );
      },
    );
  }
}

class GameBoard extends StatefulWidget {
  final GameViewModel gameViewModel;

  GameBoard(this.gameViewModel);

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  late AnimationController _pawnMoveController;
  late Animation<Offset> _animation;
  Pawn? currPawn;

  static const int _pawnMoveDuration = 165;
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pawnMoveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..addListener(() {
        setState(() {
          currPawn?.setOffset(_animation.value);
        });

        if (_pawnMoveController.isCompleted) {
          currPawn = null;
          widget.gameViewModel.onPawnMoveAnimationFinish();
        }
      });
  }

  void _startPawnMoveAnimation() {
    print("_startPawnMoveAnimation start");
    widget.gameViewModel.onPawnMoveAnimationStart();
    _pawnMoveController.forward(from: 0.0);
  }

  void movePlayerTo(int row, int column, GameViewModel gameViewModel) {
    final endPosition = Offset(column.toDouble(), row.toDouble());

    currPawn = gameViewModel.getCurrPawn();

    setState(() {
      _pawnMoveController.duration =
          Duration(milliseconds: (gameViewModel.pathSize * _pawnMoveDuration));

      _animation = Tween<Offset>(
        begin: currPawn?.offset,
        end: endPosition,
      ).animate(_pawnMoveController);
    });

    _startPawnMoveAnimation();
  }

  @override
  void dispose() {
    _pawnMoveController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _mainBoard(context);

  Widget _mainBoard(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth - 10;
        double cellSize = width / 8; // For an 8x8 board

        List<Widget> cells = _getCells(cellSize);
        List<Widget> pawns = _getPawns(cellSize);

        return Scaffold(
          body: Center(
            child: Stack(
              children: [
                const MainGameBorder(),
                Container(
                  margin: const EdgeInsets.only(left: 5, top: 5),
                  width: 8 * cellSize,
                  // Increased size to account for the border and prevent cut-off
                  height: 8 * cellSize,
                  child: Stack(
                    children: [...cells, ...pawns],
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.play_arrow),
          ),
        );
      },
    );
  }

  void handleCellTap(GameViewModel gameViewModel, CellDetails cell) =>
      movePlayerTo(cell.row, cell.column, gameViewModel);

  void handlePlayerTap(GameViewModel gameViewModel, Pawn pawn) {}

  List<Widget> _getCells(double cellSize) {
    List<Widget> cells = [];
    for (var element in widget.gameViewModel.board) {
      for (var cell in element) {
        cells.add(Positioned(
          // Positioned is now the outermost widget in this hierarchy
          left: cell.offset.dx * cellSize,
          top: cell.offset.dy * cellSize,
          child: GestureDetector(
            // GestureDetector is now inside Positioned
            onTap: () {
              // Handle cell tap here.
              TapOnBoard tapOnBoard =
                  widget.gameViewModel.onClickCell(cell.row, cell.column);
              if (tapOnBoard == TapOnBoard.END) {
                handleCellTap(widget.gameViewModel, cell);
              }
            },
            child: CustomPaint(
              painter: CellPainter(cell.tmpColor, cell.offset),
              child: SizedBox(
                width: cellSize,
                height: cellSize,
              ),
            ),
          ),
        ));
      }
    }

    return cells;
  }

  List<Widget> _getPawns(double cellSize) {
    List<Widget> allPawns = [];

    for (var pawn in widget.gameViewModel.pawns) {
      if (currPawn != pawn) {
        allPawns.add(_buildPawnWidget(pawn, cellSize, false));
      }
    }

    if (currPawn != null) {
      allPawns.add(
          _buildPawnWidget(currPawn ?? Pawn.createEmpty(), cellSize, true));
    }

    return allPawns;
  }

  Widget _buildPawnWidget(Pawn pawn, double cellSize, bool isAnimatingPawn) =>
      PawnPiece(pawn, isAnimatingPawn, cellSize, _pawnMoveController);
}
