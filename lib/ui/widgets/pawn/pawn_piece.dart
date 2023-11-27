import 'package:flutter/widgets.dart';
import 'package:untitled/ui/pawn_painter.dart';
import 'package:untitled/ui/widgets/crown_animation.dart';

class PawnPiece extends StatelessWidget {
  // final Pawn pawn;
  final double size;
  final Color pawnColor;
  final bool isKing;
  final String pawnId;

  const PawnPiece(
      {required this.pawnColor,
      required this.isKing,
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
            painter: PawnPainter(pawnColor),
          )),
          isKing
              ? CrownAnimation(pawnId: pawnId, isKing: isKing)
              : const SizedBox(),
        ],
      );
}
