import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/board_elements_size.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/pawn_data.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece_animate.dart';

class PawnsLayer extends StatelessWidget {
  static const Offset pawnKilledScaleOffset = Offset(0.6, 0.6);
  static const double pawnAliveScale = 0.75;
  final AnimationController pawnMoveController;

  const PawnsLayer(this.pawnMoveController, {super.key});

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
    // logDebug("MAIN WIDGET _getPawns");
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
                      : pawnMoveController.duration ??
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
          pawnMoveController: pawnMoveController,
          size: cellSize,
          pawnColor: pawn.color,
          isKing: pawn.isKing,
          pawnId: pawn.id,
          row: pawn.row,
          column: pawn.column,
          key: ValueKey('pawn_${pawn.id}PawnPiece'));
}
