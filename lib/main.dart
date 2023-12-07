import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/cell_details_data.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/pawn_data.dart';
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
  static const double mainBoardBorder = 0;
  static const Offset mainBoardBorderOffset = Offset(3, 3);
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

    double paddingGameBoard = 8;
    double borderWidthGameBoard = 10;
    double innerBorderWidthGameBoard = 2;

    final cellSize = (sizeBoardByOrientation -
            (paddingGameBoard * 2) -
            (borderWidthGameBoard * 2)) /
        CheckersBoard.sizeBoard;

    final boardSize = cellSize * CheckersBoard.sizeBoard;

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        // decoration: _gameBackground(),
        child: Stack(
          children: [
            _backgroundGame(),
            SafeArea(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _features(),
                Expanded(
                    child: Container(
                  padding: EdgeInsets.all(paddingGameBoard),
                  alignment: Alignment.center,
                  // color: Colors.lightGreen,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _bordersGameBoard(borderWidthGameBoard, boardSize,
                          innerBorderWidthGameBoard),
                      SizedBox(
                        // color: Colors.blue.withOpacity(0.8),
                        width: boardSize,
                        height: boardSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _getCells(cellSize, sizeBoardByOrientation),
                        ),
                      ),
                      SizedBox(
                        // color: Colors.lightGreen.withOpacity(0.1),
                        width: boardSize,
                        height: boardSize + cellSize + cellSize,
                        child: _getPawns(cellSize, paddingGameBoard, cellSize),
                      ),
                    ],
                  ),
                )),
                _bottomLayer(),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget _timer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.tealAccent, // Green border
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade700,
                  blurRadius: 10.0,
                  offset: const Offset(0, 0),
                ),
              ]),
          child: const Text(
            "22",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            "Time Left",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
          ),
        )
      ],
    );
  }

  Widget _pawnStatusChangeAnimate(
      {required Color pawnColor, required PawnStatus pawnStatus}) {
    return Animate(
      key: ValueKey(pawnStatus.totalPawnsText),
      effects: const [
        FlipEffect(
          duration: Duration(milliseconds: 200),
          alignment: Alignment.center,
          begin: 1,
          end: 2, // 2 * pi for a full rotation
        )
      ],
      child: Container(
        width: 73,
        height: 60,
        alignment: Alignment.centerRight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PawnPiece(
                pawnColor: pawnColor,
                isKing: false,
                isShadow: false,
                pawnId: "pawnId",
                size: 25),
            Text(pawnStatus.totalPawnsText)
          ],
        ),
      ),
    );
  }

  Widget _pawnStatusChange(
          {required Color pawnColor, required PawnStatus pawnStatus}) =>
      _pawnStatusChangeAnimate(pawnColor: pawnColor, pawnStatus: pawnStatus);

  Widget _player(
          {required Color pawnColor,
          required String avatarPath,
          required String playerName,
          required ValueNotifier<PawnStatus> pawnStatusValueNotifier}) =>
      Container(
        padding: const EdgeInsets.only(left: 8, top: 24, right: 8, bottom: 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.yellow, // Green border
            width: 1.0,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: ValueListenableBuilder<PawnStatus>(
          valueListenable: pawnStatusValueNotifier,
          builder: (ctx, pawnStatus, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    playerName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                Stack(
                  children: [
                    _circleAvatarPlayer(filePath: avatarPath),
                    _pawnStatusChange(
                        pawnColor: pawnColor, pawnStatus: pawnStatus)
                  ],
                ),
              ],
            );
          },
        ),
      );

  Widget _circleAvatarPlayer({required filePath}) {
    return CircleAvatar(
      radius: 30.0, // Adjust the radius as needed
      backgroundColor: Colors.white.withOpacity(0.95),
      child: Image.asset(
        filePath,
        height: 50,
      ),
    );
  }

  Widget _features() => SizedBox(
        height: 65,
        width: MediaQuery.of(context).size.width,
        child: const Align(
          alignment: Alignment.topCenter,
          child: Features(),
        ),
      );

  Widget _getCells(double cellSize, double widthBoardByOrientation) {
    // logDebug("MAIN WIDGET _getCells");
    List<Widget> cells = gameViewModel.boardCells.map((cell) {
      double leftPos = (cell.offset.dx) * cellSize;
      double topPos = (cell.offset.dy) * cellSize;
      return Positioned(
        left: leftPos,
        top: topPos,
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

              return RepaintBoundary(
                  child: Transform.rotate(
                angle: cell.isUnValid ? pi / 2 : 0,
                // Specify the rotation angle in radians
                child: Image.asset('assets/wood.png',
                    color: cell.isUnValid
                        ? Colors.white
                        : cell.tmpColor == cell.color
                            ? Colors.black
                            : cell.tmpColor,
                    colorBlendMode: cell.isUnValid
                        ? BlendMode.modulate
                        : cell.tmpColor == cell.color
                            ? BlendMode.overlay
                            : BlendMode.color,
                    width: cellSize,
                    height: cellSize),
              ));
            },
          ),
        ),
      );
    }).toList();

    return Container(
      // width: widthBoardByOrientation,
      // height: widthBoardByOrientation,

      child: Stack(
        children: cells,
      ),
    );
    //   Container(
    //   width: widthBoardByOrientation,
    //   height: widthBoardByOrientation,
    //   // margin: const EdgeInsets.only(left: 8, right: 8),
    //   // decoration: BoxDecoration(
    //   //   border: Border.all(
    //   //       color: Colors.brown,
    //   //       width: mainBoardBorder,
    //   //       style: BorderStyle.none),
    //   //   boxShadow: [
    //   //     BoxShadow(
    //   //       color: Colors.brown.shade500,
    //   //       spreadRadius: 1,
    //   //       blurRadius: 4,
    //   //       offset: mainBoardBorderOffset,
    //   //     ),
    //   //   ],
    //   // ),
    //   child: ,
    // );
  }

  Widget _getPawns(
      double cellSize, double paddingGameBoard, double heightOffset) {
    logDebug("MAIN WIDGET _getPawns");
    double discardPileSize = ((cellSize * pawnKilledScaleOffset.dx)) +
        mainBoardBorderAll +
        mainBoardBorderOffset.dy;
    double pawnsAreaSize = CheckersBoard.sizeBoard * cellSize;
    List<Widget> pawns = gameViewModel.pawns
        .mapIndexed((pawn, index) => ValueListenableBuilder<PawnData>(
              valueListenable: pawn.pawnDataNotifier,
              builder: (ctx, pawnData, _) {
                double topNotKilled =
                    (pawnData.offset.dy * cellSize) + heightOffset;

                double topKilledWhite = pawnsAreaSize - (cellSize * 0.85);
                double topKilledBlack = ((discardPileSize / 2) -
                        (cellSize * pawnKilledScaleOffset.dx)) /
                    2;
                double top = pawnData.isKilled
                    ? pawn.isSomeWhite
                        ? topKilledWhite
                        : topKilledBlack
                    : topNotKilled;

                // double leftNotKilled =
                //     ((pawnData.offset.dx) * cellSize) + (mainBoardBorder) + 8;

                double leftNotKilled = ((pawnData.offset.dx) * cellSize);
                double leftKilled = pawnData.indexKilled *
                    (cellSize * pawnKilledScaleOffset.dx + 2.5);
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

    return Stack(
      children: pawns,
    );
  }

  Widget _buildPawnWidget(Pawn pawn, double cellSize, bool isAnimatingPawn) =>
      PawnPieceAnimate(
          isAnimatingPawn: isAnimatingPawn,
          pawnMoveController: _pawnMoveController,
          size: cellSize,
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

  Widget _backgroundGame() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/wood_background_vintage.jpg'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade400.withOpacity(0.5),
                // Colors.black45,
                Colors.black87,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        )
      ],
    );
  }

  Widget _bottomLayer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      // height: 100,
      // color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _player(
                playerName: 'AMOS',
                avatarPath: 'assets/avatar_player.png',
                pawnColor: PawnsOperation.playerOneDarkColor,
                pawnStatusValueNotifier: gameViewModel.blackPawnStatus),
            _timer(), ////////
            _player(
                playerName: 'BATMAN',
                avatarPath: 'assets/bot_1.png',
                pawnColor: PawnsOperation.playerTwoLightColor,
                pawnStatusValueNotifier: gameViewModel.whitePawnStatus),
          ],
        ),
      ),
    );
  }

  Widget _bordersGameBoard(double borderWidthGameBoard, double boardSize,
      double innerBorderWidthGameBoard) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200.withOpacity(0.4),
              // Green border
              width: borderWidthGameBoard,
            ),
          ),
          width: boardSize + (borderWidthGameBoard * 2),
          height: boardSize + (borderWidthGameBoard * 2),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                // Green border
                width: innerBorderWidthGameBoard,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.5,
                  offset: const Offset(1.5, 1.5),
                ),
              ]),
          width: boardSize + innerBorderWidthGameBoard,
          height: boardSize + innerBorderWidthGameBoard,
        )
      ],
    );
  }
}
