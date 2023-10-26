import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/cell_details_data.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/pawn_data.dart';
import 'package:untitled/enum/tap_on_board.dart';
import 'package:untitled/extensions/cg_log.dart';
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
    logDebug("REBUILD MyApp");
    return MaterialApp(
      title: 'Checkers Game',
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

  static const int _pawnMoveDuration = 150;
  late final GameViewModel gameViewModel;

  @override
  void initState() {
    super.initState();
    gameViewModel = Provider.of<GameViewModel>(context, listen: false);
    _pawnMoveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..addStatusListener((status) {
        if (_pawnMoveController.isCompleted) {
          gameViewModel.onPawnMoveAnimationFinish();
        }
      });
  }

  void _startPawnMoveAnimation() => _pawnMoveController.forward(from: 0.0);

  void movePlayerTo(int row, int column) {
    gameViewModel.onPawnMoveAnimationStart();
    _pawnMoveController.duration =
        Duration(milliseconds: (gameViewModel.pathSize * _pawnMoveDuration));

    _startPawnMoveAnimation();
  }

  @override
  Widget build(BuildContext context) => _mainBoard(context);

  Widget _mainBoard(BuildContext context) {
    logDebug("MAIN WIDGET REBUILD _mainBoard");
    final cellSize =
        (MediaQuery.of(context).size.width - 10) / 8; // For an 8x8 board

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
                children: [..._getCells(cellSize), ..._getPawns(cellSize)],
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleCellTap(CellDetails cell) => movePlayerTo(cell.row, cell.column);

  List<Widget> _getCells(double cellSize) {
    logDebug("MAIN WIDGET _getCells");

    return gameViewModel.boardCells.map((cell) {
      logDebug("MAIN WIDGET ***REBUILD*** Positioned START");

      return Positioned(
        left: cell.offset.dx * cellSize,
        top: cell.offset.dy * cellSize,
        child: GestureDetector(
          onTap: () {
            TapOnBoard tapOnBoard =
                gameViewModel.onTapBoardGame(cell.row, cell.column);
            if (tapOnBoard == TapOnBoard.END) {
              handleCellTap(cell);
            }
          },
          child: ValueListenableBuilder<CellDetailsData>(
            valueListenable: cell.cellDetailsData,
            builder: (ctx, cellDetailsData, _) {
              logDebug(
                  "MAIN WIDGET ***REBUILD*** _getCells ValueListenableBuilder $cell");

              return RepaintBoundary(
                  child: AnimatedContainer(
                duration: const Duration(milliseconds: 125),
                color: cell.tmpColor,
                height: cellSize,
                width: cellSize,
              ));
            },
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _getPawns(double cellSize) {
    logDebug("MAIN WIDGET _getPawns");

    return gameViewModel.pawns
        .map((pawn) => ValueListenableBuilder<PawnData>(
              valueListenable: pawn.pawnDataNotifier,
              builder: (ctx, pawnData, _) {
                logDebug(
                    "MAIN WIDGET ***REBUILD*** _getPawns ValueListenableBuilder $pawn");

                return AnimatedPositioned(
                  duration: _pawnMoveController.duration ??
                      const Duration(milliseconds: 200),
                  left: pawnData.offset.dx * cellSize,
                  top: pawnData.offset.dy * cellSize,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: pawnData.isKilled
                        ? Container(
                            key: ValueKey('empty_${pawn.id}AnimatedSwitcher'))
                        : _buildPawnWidget(
                            pawn, cellSize, pawnData.isAnimating),
                  ),
                );
              },
            ))
        .toList();
  }

  Widget _buildPawnWidget(Pawn pawn, double cellSize, bool isAnimatingPawn) =>
      PawnPiece(pawn, isAnimatingPawn, cellSize, _pawnMoveController,
          key: ValueKey('pawn_${pawn.id}PawnPiece'));

  @override
  void dispose() {
    _pawnMoveController.dispose();
    super.dispose();
  }
}
