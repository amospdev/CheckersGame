import 'package:flutter/material.dart';

class ScaleAnimation extends StatefulWidget {
  final Widget child;

  const ScaleAnimation({super.key, required this.child});

  @override
  ScaleAnimationState createState() => ScaleAnimationState();
}

class ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<double> _heartAnimation;
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    _controller
      ..forward(from: 0.8)
      ..repeat(reverse: true);
  }

  @override
  void initState() {
    super.initState();
    const quick = Duration(milliseconds: 500);
    final scaleTween = Tween(begin: 0.8, end: 1.0);
    _controller = AnimationController(duration: quick, vsync: this);

    _heartAnimation = scaleTween.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _animate();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ScaleTransition(
          scale: _heartAnimation,
          child: widget.child,
        ));
  }
}
