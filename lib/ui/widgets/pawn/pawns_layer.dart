import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/board_elements_details.dart';
import 'package:untitled/data/pawn/pawn_details.dart';
import 'package:untitled/data/pawn/pawn_details_data.dart';
import 'package:untitled/data/pawn/pawn_position_data.dart';
import 'package:untitled/enum/pawn_move_state.dart';
import 'package:untitled/ui/screens/game/game_view_model.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece_animate.dart';

class PawnsLayer extends StatefulWidget {
  const PawnsLayer({super.key});

  @override
  PawnsLayerState createState() => PawnsLayerState();
}

class PawnsLayerState extends State<PawnsLayer> with TickerProviderStateMixin {
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
  Widget build(BuildContext context) => _getPawns(BoardElementsDetails.cellSize,
      Provider.of<GameViewModel>(context, listen: false));

  Widget _getPawns(double cellSize, GameViewModel gameViewModel) {
    List<Widget> pawns = gameViewModel.pawns
        .map((pawn) => ValueListenableBuilder<PawnDetailsData>(
              valueListenable: pawn.pawnDataNotifier,
              builder: (ctx, pawnData, _) {
                PawnPosition pawnPosition = BoardElementsDetails.pawnPosition(
                    pawnData, pawn.isSomeWhite);

                return AnimatedPositioned(
                  curve: pawnData.isKilled
                      ? Curves.easeOutQuint
                      : Curves.easeInOut,
                  duration: pawnData.isKilled
                      ? Duration(
                          milliseconds: pawnPosition.durationMove.toInt())
                      : _pawnMoveController.duration ??
                          const Duration(milliseconds: 200),
                  left: pawnPosition.left,
                  top: pawnPosition.top,
                  child: pawnData.isKilled
                      ? _pawnKilledAnimation(
                          pawnPosition.durationMove.toInt(), cellSize, pawn)
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
          int durationMove, double cellSize, PawnDetails pawn) =>
      Animate(
        effects: [
          ScaleEffect(
              curve: Curves.fastEaseInToSlowEaseOut,
              end: BoardElementsDetails.pawnKilledScaleOffset,
              duration: Duration(milliseconds: durationMove)),
        ],
        child: PawnPiece(
          isShadow: false,
          size: cellSize,
          pawnId: pawn.id,
          isKing: pawn.isKing,
          pawnColor: pawn.color,
        ),
      );

  Widget _buildPawnWidget(
          PawnDetails pawn, double cellSize, bool isAnimatingPawn) =>
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
