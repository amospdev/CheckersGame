import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  late final Future<LottieComposition> _composition;
  bool alreadyAnimate = false;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _composition = AssetLottie('assets/CrownAnimation.json').load();
    _composition.then((composition) {
      _lottieController.forward(
          from: widget.pawn.isAlreadyKing ? composition.endFrame : 0);
    });
  }

  @override
  Widget build(BuildContext context) =>
      _mainCrown(_lottieController, widget.pawn);

  Widget _mainCrown(AnimationController lottieController, Pawn pawn) =>
      Consumer<GameViewModel>(
          builder: (ctx, gameViewModel, child) =>
              _getAnimatedCrown(lottieController, widget.pawn, gameViewModel));

  Widget _getAnimatedCrown(AnimationController lottieController, Pawn pawn,
      GameViewModel gameViewModel) {
    print("CrownAnimation _getAnimatedCrown pawn: $pawn");
    print("CrownAnimation alreadyAnimate: $alreadyAnimate");

    return FutureBuilder<LottieComposition>(
      future: _composition,
      builder: (context, snapshot) => _getCrown(snapshot.data, gameViewModel),
    );
  }

  Widget _getCrown(
          LottieComposition? composition, GameViewModel gameViewModel) =>
      composition != null
          ? _getLottieCrown(composition, gameViewModel)
          : _getSvgCrown();

  Widget _getSvgCrown() => SvgPicture.asset('assets/crown.svg',
      colorFilter:
          const ColorFilter.mode(Colors.yellowAccent, BlendMode.srcATop),
      width: 20,
      height: 20);

  Widget _getLottieCrown(
          LottieComposition composition, GameViewModel gameViewModel) =>
      Lottie(
          composition: composition,
          width: 40,
          height: 40,
          controller: _lottieController
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                gameViewModel.onFinishAnimateCrown(widget.pawn);
              }
            }));

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }
}
