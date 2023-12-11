import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:untitled/game/pawns_operation.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/widgets/pawn/status_change/pawn_status_change.dart';

class PawnPlayerTwoLight extends StatelessWidget {
  const PawnPlayerTwoLight({super.key});

  @override
  Widget build(BuildContext context) =>
      _pawnStatusChange(
          pawnColor: PawnsOperation.playerTwoPawnLightColor,
          pawnTextColor: PawnsOperation.playerTwoPawnTextDarkColor,
          pawnStatusNotifier:
          Provider
              .of<GameViewModel>(context, listen: false)
              .whitePawnStatus);

  Widget _pawnStatusChange({
    required ValueNotifier<PawnStatus> pawnStatusNotifier,
    required Color pawnColor,
    required Color pawnTextColor,
  }) =>
      PawnStatusChange(pawnStatusNotifier: pawnStatusNotifier,
          pawnTextColor: pawnTextColor,
          pawnColor: pawnColor);
}
