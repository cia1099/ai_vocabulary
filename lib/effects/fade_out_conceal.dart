import 'package:flutter/material.dart';

class FadeOutConceal extends StatefulWidget {
  final ConcealState fadeOutState;
  final Duration duration;
  final Widget? child;
  const FadeOutConceal({
    super.key,
    this.duration = Durations.long3,
    required this.fadeOutState,
    this.child,
  });

  @override
  State<FadeOutConceal> createState() => _FadeOutFadeOutState();
}

class _FadeOutFadeOutState extends State<FadeOutConceal> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      transitionBuilder: (child, animation) {
        final opacity =
            animation.status == AnimationStatus.dismissed ? .8 : 0.0;
        return FadeTransition(
          opacity: Tween(
            begin: opacity,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
          child: child,
        );
      },
      child: widget.fadeOutState == ConcealState.unhide ? widget.child : null,
    );
  }
}

enum ConcealState { hide, unhide }
