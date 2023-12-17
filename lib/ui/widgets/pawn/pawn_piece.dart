import 'package:flutter/widgets.dart';
import 'package:untitled/ui/widgets/pawn/painter/pawn_painter.dart';
import 'package:untitled/ui/widgets/crown_animation.dart';

class PawnPiece extends StatelessWidget {
  final double size;
  final Color pawnColor;
  final bool isKing;
  final bool isShadow;
  final String pawnId;
  final double factorRadius;
  final bool isShowAnimation;

  const PawnPiece(
      {required this.pawnColor,
      required this.isKing,
      this.isShadow = true,
      this.isShowAnimation = true,
      this.factorRadius = 1,
      required this.pawnId,
      required this.size,
      super.key});

  @override
  Widget build(BuildContext context) =>
      _main(pawnColor: pawnColor, isKing: isKing, pawnId: pawnId, size: size);

  Widget _main(
          {required Color pawnColor,
          required String pawnId,
          required bool isKing,
          required double size}) =>
      Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
              child: CustomPaint(
            size: Size(size, size),
            painter: PawnPainter(
                pawnColor: pawnColor,
                isShadow: isShadow,
                factorRadius: factorRadius),
          )),
          isKing
              ? CrownAnimation(
                  pawnId: pawnId,
                  isKing: isKing,
                  isShowAnimation: isShowAnimation)
              : const SizedBox(),
        ],
      );
}
