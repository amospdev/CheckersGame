import 'package:flutter/widgets.dart';
import 'package:untitled/ui/widgets/pawn/pawn_painter.dart';
import 'package:untitled/ui/widgets/crown_animation.dart';

class PawnPiece extends StatelessWidget {
  final double size;
  final double rectSize;
  final Color pawnColor;
  final bool isKing;
  final bool isShadow;
  final String pawnId;

  const PawnPiece(
      {required this.pawnColor,
      required this.isKing,
      this.isShadow = true,
      this.rectSize = 0,
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
            painter: PawnPainter(pawnColor, isShadow, rectSize),
          )),
          isKing
              ? CrownAnimation(pawnId: pawnId, isKing: isKing)
              : const SizedBox(),
        ],
      );
}
