import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/board_elements_size.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/pawn_data.dart';
import 'package:untitled/enum/pawn_move_state.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece_animate.dart';

class PawnsLayer extends StatefulWidget {
  const PawnsLayer({super.key});

  @override
  PawnsLayerState createState() => PawnsLayerState();
}

class PawnsLayerState extends State<PawnsLayer> with TickerProviderStateMixin {
  static const Offset pawnKilledScaleOffset = Offset(0.6, 0.6);
  static const double pawnAliveScale = 0.75;

  static const int _pawnMoveDuration = 350;

  late final AnimationController _pawnMoveController;
  late final GameViewModel gameViewModel;
  StreamSubscription<PawnMoveState>? _streamPawnMove;

  @override
  void initState() {
    super.initState();
    gameViewModel = Provider.of<GameViewModel>(context, listen: false);
    _initPawnMoveController();
    _startPawnMoveAsync();
  }

  void _startPawnMoveAsync() => _streamPawnMove = gameViewModel.isStartPawnMove
      .where((pawnMoveState) => pawnMoveState == PawnMoveState.START)
      .listen((isStartPawnMove) => _startPawnMoveAnimation());

  void _initPawnMoveController() => _pawnMoveController = AnimationController(
        duration: const Duration(milliseconds: 3000),
        vsync: this,
      )..addStatusListener((status) {
          if (_pawnMoveController.isCompleted) {
            gameViewModel.onPawnMoveAnimationFinish();
          }
        });

  void _startPawnMoveAnimation() {
    _pawnMoveController.duration = Duration(
        milliseconds: (gameViewModel.pathSize > 2
            ? (_pawnMoveDuration * 1.6).toInt()
            : _pawnMoveDuration));

    _pawnMoveController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) => _getPawns(
      BoardElementsSize.cellSize,
      (BoardElementsSize.discardPileArea / 2),
      BoardElementsSize.discardPileArea,
      BoardElementsSize.innerBoardSize,
      BoardElementsSize.borderWidthGameBoard,
      Provider.of<GameViewModel>(context, listen: false));

  Widget _getPawns(
      double cellSize,
      double heightOffset,
      double discardPileArea,
      double innerBoardSize,
      double borderWidthGameBoard,
      GameViewModel gameViewModel) {
    List<Widget> pawns = gameViewModel.pawns
        .map((pawn) => ValueListenableBuilder<PawnData>(
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
                      ? _pawnKilledAnimation(distancePoints, cellSize, pawn)
                      : _buildPawnWidget(pawn, cellSize, pawnData.isAnimating),
                );
              },
            ))
        .toList();

    return Stack(
      children: pawns,
    );
  }

  Widget _pawnKilledAnimation(
          double distancePoints, double cellSize, Pawn pawn) =>
      Animate(
        effects: [
          ScaleEffect(
              curve: Curves.fastEaseInToSlowEaseOut,
              end: pawnKilledScaleOffset,
              duration: Duration(milliseconds: (distancePoints * 5).toInt())),
        ],
        child: PawnPiece(
          isShadow: false,
          size: cellSize,
          pawnId: pawn.id,
          isKing: pawn.isKing,
          pawnColor: pawn.color,
        ),
      );

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
    _streamPawnMove?.cancel();

    super.dispose();
  }
}
