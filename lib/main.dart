import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/cell_details_data.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/pawn_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/enum/tap_on_board.dart';
import 'package:untitled/extensions/cg_collections.dart';
import 'package:untitled/extensions/cg_log.dart';
import 'package:untitled/extensions/screen_ratio.dart';
import 'package:untitled/features_game.dart';
import 'package:untitled/game/checkers_board.dart';
import 'package:untitled/game/pawns_operation.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece_animate.dart';

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
  late final AnimationController _pawnMoveController;

  static const int _pawnMoveDuration = 350;
  static const double mainBoardBorder = 5;
  static const Offset mainBoardBorderOffset = Offset(2, 3);
  static const Offset pawnKilledScaleOffset = Offset(0.6, 0.6);
  static const double mainBoardBorderAll = mainBoardBorder * 2;
  late final GameViewModel gameViewModel;
  StreamSubscription<bool>? _streamAiTurn;

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

    _streamAiTurn =
        gameViewModel.isAITurnStream.where((isAI) => isAI).listen(_aiTurn);
  }

  Future _delayedBeforeClick(int duration) =>
      Future.delayed(Duration(milliseconds: duration));

  Future<void> _aiTurn(bool isAI) async {
    await _delayedBeforeClick(300);

    logDebug("MAIN WIDGET _aiTurn: $isAI");
    PathPawn? pathPawn = gameViewModel.aIMove();
    if (pathPawn == null) return;
    gameViewModel.onTapBoardGame(
        pathPawn.startPosition.row, pathPawn.startPosition.column);

    await _delayedBeforeClick(300);

    TapOnBoard tapOnBoardEnd = gameViewModel.onTapBoardGame(
        pathPawn.endPosition.row, pathPawn.endPosition.column);

    await _delayedBeforeClick(100);

    if (tapOnBoardEnd == TapOnBoard.END) {
      movePlayerTo(pathPawn.endPosition.row, pathPawn.endPosition.column);
    }
  }

  void _startPawnMoveAnimation() => _pawnMoveController.forward(from: 0.0);

  void movePlayerTo(int row, int column) {
    gameViewModel.onPawnMoveAnimationStart();
    _pawnMoveController.duration = Duration(
        milliseconds: (gameViewModel.pathSize > 2
            ? (_pawnMoveDuration * 1.6).toInt()
            : _pawnMoveDuration));

    _startPawnMoveAnimation();
  }

  @override
  Widget build(BuildContext context) => _mainBoard(context);

  Widget _mainBoard(BuildContext context) {
    final sizeBoardByOrientation =
        MediaQuery.of(context).sizeByOrientation; // For an 8x8 board

    final sizeBoardMinusBorder = sizeBoardByOrientation - mainBoardBorderAll;
    final cellSize = sizeBoardMinusBorder / 8;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.5), BlendMode.srcATop),
            image: const AssetImage('assets/wood.png'),
            // Replace with your background image
            fit: BoxFit.fill, // You can adjust the fit as needed
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _status(),
            Expanded(
                flex: 11,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _getCells(cellSize, sizeBoardByOrientation),
                    _getPawns(cellSize),
                  ],
                )),
            _features()
          ],
        ),
      ),
    );
  }

  Widget _status() => ValueListenableBuilder<StatusGame>(
        valueListenable: gameViewModel.gameStatus,
        builder: (ctx, pawnsStatus, _) {
          return Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            height: 65,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/wood.png'),
                // Replace with your background image
                fit: BoxFit.fitWidth, // You can adjust the fit as needed
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.srcATop),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const PawnPiece(
                              pawnColor: Colors.grey,
                              isKing: false,
                              pawnId: "pawnId",
                              rectSize: 40,
                              size: 40),
                          Text(
                              '${pawnsStatus.totalBlackKings + pawnsStatus.totalBlackPawns}')
                        ],
                      ),
                      pawnsStatus.currPlayer == CellType.BLACK
                          ? const Icon(Icons.arrow_back)
                          : Container(),
                    ],
                  ),
                  Row(
                    children: [
                      pawnsStatus.currPlayer == CellType.WHITE
                          ? const Icon(Icons.arrow_forward)
                          : Container(),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const PawnPiece(
                              pawnColor: Colors.white,
                              isKing: false,
                              pawnId: "pawnId",
                              rectSize: 40,
                              size: 40),
                          Text(
                              '${pawnsStatus.totalWitheKings + pawnsStatus.totalWithePawns}')
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _features() => Container(
        height: 65,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/wood.png'),
            // Replace with your background image
            fit: BoxFit.fitWidth, // You can adjust the fit as needed
          ),
        ),
        child: const Align(
          alignment: Alignment.center,
          child: Features(),
        ),
      );

  Widget _getCells(double cellSize, double widthBoardByOrientation) {
    // logDebug("MAIN WIDGET _getCells");

    List<Widget> cells = gameViewModel.boardCells.map((cell) {
      return Positioned(
        left: (cell.offset.dx) * cellSize,
        top: (cell.offset.dy) * cellSize,
        child: GestureDetector(
          onTap: () {
            TapOnBoard tapOnBoard =
                gameViewModel.onTapBoardGame(cell.row, cell.column);
            if (tapOnBoard == TapOnBoard.END) {
              movePlayerTo(cell.row, cell.column);
            }
          },
          child: ValueListenableBuilder<CellDetailsData>(
            valueListenable: cell.cellDetailsData,
            builder: (ctx, cellDetailsData, _) {
              // logDebug(
              //     "MAIN WIDGET ***REBUILD*** _getCells ValueListenableBuilder $cell");

              return Stack(
                alignment: Alignment.center,
                children: [
                  RepaintBoundary(
                      child: Transform.rotate(
                    angle: cell.isUnValid ? pi / 2 : 0,
                    // Specify the rotation angle in radians
                    child: Image.asset('assets/wood.png',
                        color: cell.isUnValid
                            ? Colors.white.withOpacity(0.35)
                            : cell.tmpColor == cell.color
                                ? Colors.black.withOpacity(0.15)
                                : cell.tmpColor.withOpacity(0.6),
                        colorBlendMode: BlendMode.srcATop,
                        width: cellSize,
                        height: cellSize),
                  )),
                ],
              );
            },
          ),
        ),
      );
    }).toList();

    return Container(
      width: widthBoardByOrientation,
      // Increased size to account for the border and prevent cut-off
      height: widthBoardByOrientation,
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.brown,
            width: mainBoardBorder,
            style: BorderStyle.none),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade500,
            spreadRadius: 1,
            blurRadius: 3,
            offset: mainBoardBorderOffset,
          ),
        ],
      ),
      child: Stack(
        children: [...cells],
      ),
    );
  }

  Widget _getPawns(double cellSize) {
    logDebug("MAIN WIDGET _getPawns");
    double discardPileSize =
        (cellSize * 1.5) + mainBoardBorderAll + mainBoardBorderOffset.dx;
    double pawnsAreaSize = CheckersBoard.sizeBoard * cellSize + discardPileSize;
    List<Widget> pawns = gameViewModel.pawns
        .mapIndexed((pawn, index) => ValueListenableBuilder<PawnData>(
              valueListenable: pawn.pawnDataNotifier,
              builder: (ctx, pawnData, _) {
                double topNotKilled =
                    ((pawnData.offset.dy) * cellSize) + (discardPileSize / 2);

                double topKilledWhite = -(cellSize * 0.15);
                double topKilledBlack = pawnsAreaSize - (cellSize * 0.85) ;
                double top = pawnData.isKilled
                    ? pawn.isSomeWhite
                        ? topKilledWhite
                        : topKilledBlack
                    : topNotKilled;

                double leftNotKilled =
                    ((pawnData.offset.dx) * cellSize) + (mainBoardBorder);
                double leftKilled =
                    (pawnData.indexKilled * (cellSize * 0.67)) - 5;
                double left = pawnData.isKilled ? leftKilled : leftNotKilled;

                double distancePoints = (Offset(leftNotKilled, topNotKilled) -
                        Offset(leftKilled,
                            pawn.isSomeWhite ? topKilledWhite : topKilledBlack))
                    .distance;

                return AnimatedPositioned(
                  curve: pawnData.isKilled
                      ? Curves.easeOutQuint
                      : Curves.easeInOut,
                  duration: pawnData.isKilled
                      ? Duration(milliseconds: (distancePoints * 5).toInt())
                      : _pawnMoveController.duration ??
                          const Duration(milliseconds: 200),
                  left: left,
                  top: top,
                  child: pawnData.isKilled
                      ? Animate(
                          effects: [
                            ScaleEffect(
                                curve: Curves.fastEaseInToSlowEaseOut,
                                end: pawnKilledScaleOffset,
                                duration: Duration(
                                    milliseconds:
                                        (distancePoints * 5).toInt())),
                          ],
                          child: PawnPiece(
                            isShadow: false,
                            size: cellSize,
                            rectSize: cellSize,
                            pawnId: pawn.id,
                            isKing: pawn.isKing,
                            pawnColor: pawn.color,
                          ),
                        )
                      : _buildPawnWidget(pawn, cellSize, pawnData.isAnimating),
                );
              },
            ))
        .toList();

    return Container(
      alignment: Alignment.center,
      height: pawnsAreaSize,
      child: Stack(
        children: [
          ...pawns,
        ],
      ),
    );
  }

  Widget _buildPawnWidget(Pawn pawn, double cellSize, bool isAnimatingPawn) =>
      PawnPieceAnimate(
          isAnimatingPawn: isAnimatingPawn,
          pawnMoveController: _pawnMoveController,
          size: cellSize * 0.75,
          rectSize: cellSize,
          pawnColor: pawn.color,
          isKing: pawn.isKing,
          pawnId: pawn.id,
          row: pawn.row,
          column: pawn.column,
          key: ValueKey('pawn_${pawn.id}PawnPiece'));

  @override
  void dispose() {
    _pawnMoveController.dispose();
    _streamAiTurn?.cancel();
    super.dispose();
  }
}
