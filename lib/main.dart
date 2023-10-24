import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/cell_details_data.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/pawn_data.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/cell.dart';
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
      gameViewModel.onPawnMoveAnimationFinish();
    }
  }

  void _startPawnMoveAnimation(GameViewModel gameViewModel) {
    gameViewModel.onPawnMoveAnimationStart();
    _pawnMoveController.forward(from: 0.0);
  }

  void movePlayerTo(int row, int column, GameViewModel gameViewModel) {
    final endPosition = Offset(column.toDouble(), row.toDouble());

    _pawnMoveController.duration =
        Duration(milliseconds: (gameViewModel.pathSize * _pawnMoveDuration));

    _animation = Tween<Offset>(
      begin: gameViewModel.currPawn?.pawnDataNotifier.value.offset,
      end: endPosition,
    ).animate(_pawnMoveController);

    _startPawnMoveAnimation(gameViewModel);
  }

  @override
  Widget build(BuildContext context) => _mainBoard(context);

  Widget _mainBoard(BuildContext context) {
    // print("MAIN WIDGET REBUILD _mainBoard");
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
    // print("MAIN WIDGET _getCells");

    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);

    return gameViewModel.boardCells
        .map((cell) => Positioned(
              left: cell.offset.dx * cellSize,
              top: cell.offset.dy * cellSize,
              child: GestureDetector(
                onTap: () {
                  TapOnBoard tapOnBoard =
                      gameViewModel.onClickCell(cell.row, cell.column);
                  if (tapOnBoard == TapOnBoard.END) {
                    handleCellTap(gameViewModel, cell);
                  }
                },
                child: ValueListenableBuilder<CellDetailsData>(
                  valueListenable: cell.cellDetailsData,
                  builder: (ctx, cellDetailsData, _) {
                    // print("MAIN WIDGET REBUILD _getCells: $cell");

                    return RepaintBoundary(
                        child: CustomPaint(
                      painter: CellPainter(cellDetailsData.tmpColor),
                      size: Size(cellSize, cellSize),
                    ));
                  },
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _getPawns(double cellSize) {
    // print("MAIN WIDGET _getPawns");

    List<Pawn> currPawns =
        Provider.of<GameViewModel>(context, listen: false).pawns;
    Pawn? currPawn =
        Provider.of<GameViewModel>(context, listen: false).currPawn;

    final widgets = currPawns
        .map((pawn) => ValueListenableBuilder<PawnData>(
              valueListenable: pawn.pawnDataNotifier,
              builder: (ctx, pawnData, _) {
                // print("MAIN WIDGET REBUILD _getPawns: $pawn");

                return pawnData.isKilled
                    ? Container()
                    : _buildPawnWidget(pawn, cellSize, pawn == currPawn);
              },
            ))
        .toList();

    return widgets;
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
