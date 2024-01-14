import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:untitled/ui/screens/game/game_view_model.dart';

class CrownAnimation extends StatefulWidget {
  final String pawnId;
  final bool isKing;
  final bool isShowAnimation;

  const CrownAnimation(
      {required this.pawnId,
      required this.isKing,
      this.isShowAnimation = true,
      super.key});

  @override
  CrownAnimationState createState() => CrownAnimationState();
}

class CrownAnimationState extends State<CrownAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final Future<LottieComposition> _composition;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _composition = AssetLottie('assets/CrownAnimation.json').load();
    _composition.then((composition) {
      if (mounted) {
        _lottieController.forward(
            from: Provider.of<GameViewModel>(context, listen: false)
                        .isAlreadyMarkedKing(widget.pawnId) ||
                    !widget.isShowAnimation
                ? composition.endFrame
                : 0);
      }
    });

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Provider.of<GameViewModel>(context, listen: false)
            .onFinishAnimateCrown(widget.pawnId, widget.isKing);
      }
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LottieComposition>(
        future: _composition,
        builder: (context, snapshot) => _getCrown(snapshot.data),
      );

  Widget _getCrown(LottieComposition? composition) =>
      composition != null ? _getLottieCrown(composition) : _getSvgCrown();

  SvgPicture _getSvgCrown() => SvgPicture.asset('assets/crown.svg',
      colorFilter:
          const ColorFilter.mode(Colors.amberAccent, BlendMode.srcATop),
      width: 20,
      height: 20);

  Lottie _getLottieCrown(LottieComposition composition) => Lottie(
        composition: composition,
        width: 40,
        height: 40,
        controller: _lottieController,
      );

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }
}
