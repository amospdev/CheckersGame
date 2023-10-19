import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/game_view_model.dart';

class CrownAnimation extends StatefulWidget {
  final Pawn pawn;

  const CrownAnimation(this.pawn, {super.key});

  @override
  CrownAnimationState createState() => CrownAnimationState();
}

class CrownAnimationState extends State<CrownAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) => _getCrown(_lottieController);

  Widget _getCrown(
          AnimationController lottieController) =>
      Consumer<GameViewModel>(
          builder: (ctx, gameViewModel, child) =>
              _getAnimatedCrown(lottieController, widget.pawn, gameViewModel));

  Widget _getAnimatedCrown(AnimationController lottieController, Pawn pawn,
      GameViewModel gameViewModel) {
    print("CrownAnimation _getAnimatedCrown pawn: $pawn");
    return Lottie.asset('assets/CrownAnimation.json',
        repeat: false,
        controller: lottieController,
        height: 40,
        width: 40, onLoaded: (composition) {
      lottieController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          gameViewModel.onFinishAnimateCrown(pawn);
        }
      });

      lottieController.forward(
          from: pawn.isAlreadyKing ? composition.endFrame : 0);
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }
}
