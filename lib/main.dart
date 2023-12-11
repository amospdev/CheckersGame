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
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/background_game.dart';
import 'package:untitled/ui/widgets/main_game_border.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece_animate.dart';
import 'package:untitled/ui/widgets/pawn/status_change/pawn_player_one_dark.dart';
import 'package:untitled/ui/widgets/pawn/status_change/pawn_player_two_light.dart';
import 'package:untitled/ui/widgets/player_pager_card.dart';
import 'package:untitled/ui/widgets/timer/timer.dart';

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
  late int selectedPage;

  static const int _pawnMoveDuration = 350;
  static const double pawnAliveScale = 0.75;
  static const Color borderCircleAvatar = Colors.black26;
  static const Color borderRoundedPlayerCard = Colors.blueGrey;

  static const Offset pawnKilledScaleOffset = Offset(0.6, 0.6);

  late final GameViewModel gameViewModel;
  StreamSubscription<bool>? _streamAiTurn;

  @override
  void initState() {
    super.initState();
    selectedPage = 0;
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

    final cellSize = (sizeBoardByOrientation -
            (paddingGameBoard * 2) -
            (borderWidthGameBoard * 2)) /
        CheckersBoard.sizeBoard;

    final discardPileAreaTop = cellSize + borderWidthGameBoard;
    final discardPileAreaBottom = cellSize + borderWidthGameBoard;
    final discardPileArea = discardPileAreaTop + discardPileAreaBottom;

    final innerBoardSize = cellSize * CheckersBoard.sizeBoard;

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          // Handle the back button press
          // Return true to allow the app to be closed, false to prevent closure
          return false;
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              const BackgroundGame(),
              SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Features(),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.all(paddingGameBoard),
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MainGameBorder(borderWidthGameBoard, innerBoardSize),
                        SizedBox(
                          width: innerBoardSize,
                          height: innerBoardSize,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _getCells(cellSize, sizeBoardByOrientation),
                          ),
                        ),
                        SizedBox(
                          width: innerBoardSize,
                          height: innerBoardSize + discardPileArea,
                          child: _getPawns(
                              cellSize,
                              (discardPileArea / 2),
                              discardPileArea,
                              innerBoardSize,
                              borderWidthGameBoard),
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
      ),
    );
  }


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

    return Stack(
      children: cells,
    );
  }

  Widget _getPawns(double cellSize, double heightOffset, double discardPileArea,
      double innerBoardSize, double borderWidthGameBoard) {
    logDebug("MAIN WIDGET _getPawns");
    List<Widget> pawns = gameViewModel.pawns
        .mapIndexed((pawn, index) => ValueListenableBuilder<PawnData>(
              valueListenable: pawn.pawnDataNotifier,
              builder: (ctx, pawnData, _) {
                double topNotKilled =
                    (pawnData.offset.dy * cellSize) + heightOffset;

                double topKilledWhite = innerBoardSize +
                    (discardPileArea / 2) +
                    borderWidthGameBoard;
                double topKilledBlack = 0;

                double top = pawnData.isKilled
                    ? pawn.isSomeWhite
                        ? topKilledWhite
                        : topKilledBlack
                    : topNotKilled;

                double leftNotKilled = (pawnData.offset.dx * cellSize);

                double cellSizeKilledWithFactor =
                    cellSize * pawnKilledScaleOffset.dx;

                double padding =
                    -(cellSizeKilledWithFactor * (1 - pawnAliveScale));
                double margin = 3;

                double leftKilled = padding +
                    (pawnData.indexKilled *
                        (cellSizeKilledWithFactor + margin));

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

  Widget _bottomLayer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: const Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlayerPagerCard(
                avatarPath: 'assets/avatar_player.png',
                playerName: 'AMOS',
                pawnStatusChange: PawnPlayerOneDark()),
            TurnTimer(),
            PlayerPagerCard(
                avatarPath: 'assets/bot_1.png',
                playerName: 'BATMAN',
                pawnStatusChange: PawnPlayerTwoLight())
          ],
        ),
      ),
    );
  }

// Widget _playerPager(
//     {required String avatarPath,
//     required String playerName,
//     required Widget pawnStatusChange}) {
//   return Container(
//     height: 140,
//     width: 100,
//     decoration: BoxDecoration(
//       color: Colors.grey.shade700,
//       borderRadius: BorderRadius.circular(15),
//       border: Border.all(
//         color: borderRoundedPlayerCard, // Green border
//         width: 2,
//       ),
//     ),
//     child: Column(
//       children: [
//         Expanded(
//             child: PageView(
//           onPageChanged: (page) {
//             setState(() {
//               selectedPage = page;
//             });
//           },
//           children: [
//             _player(
//               playerName: playerName,
//               avatarPath: avatarPath,
//             ),
//             pawnStatusChange
//           ],
//         )),
//         PageViewDotIndicator(
//           currentItem: selectedPage,
//           count: 2,
//           unselectedColor: Colors.black26,
//           selectedColor: Colors.blue,
//           duration: const Duration(milliseconds: 200),
//           boxShape: BoxShape.circle,
//           // onItemClicked: (index) {
//           //   _pageController.animateToPage(
//           //     index,
//           //     duration: const Duration(milliseconds: 200),
//           //     curve: Curves.easeInOut,
//           //   );
//           // },
//         ),
//       ],
//     ),
//   );
// }
}
