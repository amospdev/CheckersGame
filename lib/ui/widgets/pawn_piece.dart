import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/pawn.dart';
import 'package:untitled/ui/widgets/crown_animation.dart';

class PawnPiece extends StatefulWidget {
  final Pawn pawn;
  final bool isAnimatingPawn;
  final double cellSize;
  final AnimationController pawnMoveController;

  const PawnPiece(
      this.pawn, this.isAnimatingPawn, this.cellSize, this.pawnMoveController,
      {super.key});

  @override
  PawnPieceState createState() => PawnPieceState();
}

class PawnPieceState extends State<PawnPiece>
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
  Widget build(BuildContext context) =>
      _mainPawn(widget.pawn, widget.isAnimatingPawn, widget.cellSize);

  Widget _mainPawn(Pawn pawn, bool isAnimatingPawn, double cellSize) =>
      _getPawn(pawn, isAnimatingPawn, cellSize);

  Widget _getPawn(Pawn pawn, bool isAnimatingPawn, double cellSize) {
    return Positioned(
      left: pawn.pawnDataNotifier.value.offset.dx * cellSize,
      top: pawn.pawnDataNotifier.value.offset.dy * cellSize,
      child: GestureDetector(
        onTap: () => Provider.of<GameViewModel>(context, listen: false)
            .onClickPawn(pawn.row, pawn.column),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scaleX: isAnimatingPawn ? _radiusFactorAnimation.value : 1.0,
              scaleY: isAnimatingPawn ? _radiusFactorAnimation.value : 1.0,
              child: RepaintBoundary(
                  child: CustomPaint(
                size: Size(cellSize, cellSize),
                painter: PawnPainter(pawn.color),
              )),
            ),
            pawn.isKing ? CrownAnimation(pawn) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
