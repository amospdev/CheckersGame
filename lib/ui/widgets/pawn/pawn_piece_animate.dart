import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/main.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece.dart';

class PawnPieceAnimate extends StatefulWidget {
  final bool isAnimatingPawn;
  final AnimationController pawnMoveController;
  final double size;
  final Color pawnColor;
  final bool isKing;
  final String pawnId;
  final int row;
  final int column;

  const PawnPieceAnimate(
      {required this.pawnMoveController,
      required this.isAnimatingPawn,
      required this.pawnColor,
      required this.isKing,
      required this.row,
      required this.column,
      required this.pawnId,
      required this.size,
      super.key});

  @override
  PawnPieceAnimateState createState() => PawnPieceAnimateState();
}

class PawnPieceAnimateState extends State<PawnPieceAnimate>
    with SingleTickerProviderStateMixin {
  late Animation<double> _radiusFactorAnimation;

  @override
  void initState() {
    super.initState();
    _initRadiusFactorAnimation();
  }

  void _initRadiusFactorAnimation() {
    _radiusFactorAnimation = TweenSequence<double>(
      [
        _getTweenSequenceItem(1.0, 1.25, 50),
        _getTweenSequenceItem(1.25, 1.0, 50),
      ],
    ).animate(widget.pawnMoveController);
  }

  TweenSequenceItem<double> _getTweenSequenceItem(
          double begin, double end, double weight) =>
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: begin, end: end),
        weight: weight, // Representing the remaining 50% of the duration
      );

  @override
  Widget build(BuildContext context) => _getPawn(
      isKing: widget.isKing,
      pawnColor: widget.pawnColor,
      row: widget.row,
      column: widget.column,
      size: widget.size,
      pawnId: widget.pawnId,
      isAnimatingPawn: widget.isAnimatingPawn);

  Widget _getPawn(
      {required bool isAnimatingPawn,
      required Color pawnColor,
      required bool isKing,
      required int row,
      required int column,
      required String pawnId,
      required double size}) {
    return GestureDetector(
      onTap: () => Provider.of<GameViewModel>(context, listen: false)
          .onClickPawn(row, column),
      child: AnimatedBuilder(
        animation: _radiusFactorAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isAnimatingPawn ? _radiusFactorAnimation.value : 1.0,
            child: PawnPiece(
              size: size,
              pawnId: pawnId,
              isKing: isKing,
              factorRadius: GameBoardState.pawnAliveScale,
              pawnColor: pawnColor,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
