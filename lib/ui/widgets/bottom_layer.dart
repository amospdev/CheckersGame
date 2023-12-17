import 'package:flutter/cupertino.dart';
import 'package:untitled/ui/widgets/pawn/status_change/pawn_player_one_dark.dart';
import 'package:untitled/ui/widgets/pawn/status_change/pawn_player_two_light.dart';
import 'package:untitled/ui/widgets/player_pager_card.dart';
import 'package:untitled/ui/widgets/timer/timer.dart';

class BottomLayer extends StatelessWidget{
  const BottomLayer({super.key});

  @override
  Widget build(BuildContext context) => _bottomLayer();

  Widget _bottomLayer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: const Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlayerPagerCard(
                avatarPath: 'assets/avatar_player.png',
                playerName: 'AMOS',
                pawnStatusChange: PawnPlayerOneDark()),
            TurnTimer(),
            PlayerPagerCard(
                avatarPath: 'assets/bot_1.png',
                playerName: 'BATMAN',
                pawnStatusChange: PawnPlayerTwoLight())
          ],
        ),
      ),
    );
  }
}