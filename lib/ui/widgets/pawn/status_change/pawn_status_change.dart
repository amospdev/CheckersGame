import 'package:flutter/cupertino.dart';
import 'package:untitled/game/pawns_operation.dart';
import 'package:untitled/ui/widgets/pawn/pawn_piece.dart';

class PawnStatusChange extends StatelessWidget {
  final ValueNotifier<PawnStatus> pawnStatusNotifier;
  final Color pawnTextColor;
  final Color pawnColor;

  const PawnStatusChange(
      {super.key,
      required this.pawnStatusNotifier,
      required this.pawnTextColor,
      required this.pawnColor});

  @override
  Widget build(BuildContext context) => _pawnStatusChange(
      pawnColor: pawnColor,
      pawnTextColor: pawnTextColor,
      pawnStatusNotifier: pawnStatusNotifier);

  Widget _pawnStatusChange({
    required ValueNotifier<PawnStatus> pawnStatusNotifier,
    required Color pawnColor,
    required Color pawnTextColor,
  }) {
    double pawnSize = 40;
    double pawnTextScaleFactor = 0.41;
    return ValueListenableBuilder<PawnStatus>(
      valueListenable: pawnStatusNotifier,
      builder: (ctx, pawnStatus, _) {
        return SizedBox(
          width: 73,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  PawnPiece(
                    pawnColor: pawnColor,
                    isKing: false,
                    isShadow: false,
                    pawnId: "pawnId",
                    size: pawnSize,
                    isShowAnimation: false,
                  ),
                  Text(
                    pawnStatus.totalPawnsText,
                    style: TextStyle(
                        color: pawnTextColor,
                        fontSize: pawnSize * pawnTextScaleFactor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  PawnPiece(
                    pawnColor: pawnColor,
                    isKing: true,
                    isShadow: false,
                    pawnId: "pawnId",
                    size: pawnSize,
                    isShowAnimation: false,
                  ),
                  Text(
                    pawnStatus.totalKingPawnsText,
                    style: TextStyle(
                        color: pawnTextColor,
                        fontSize: pawnSize * pawnTextScaleFactor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        );

        // return _pawnStatusChange(
        //     pawnColor: pawnColor,
        //     pawnStatus: pawnStatus,
        //     pawnTextColor: pawnTextColor);
      },
    );
  }
}
