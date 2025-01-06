import 'dart:async';

import 'package:flutter/material.dart';

class AutomatedPopRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Widget Function(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) transitionsBuilder;
  final Duration stay;
  Timer? timer;
  @override
  final Color? barrierColor;

  AutomatedPopRoute({
    required this.builder,
    this.barrierColor,
    this.stay = Durations.extralong4,
    this.transitionsBuilder = _kDefaultIslandTransitionsBuilder,
  });

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer = Timer(stay, () {
        Navigator.maybePop(context);
      });
    });
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return transitionsBuilder(context, animation, secondaryAnimation, child);
  }

  @override
  bool didPop(T? result) {
    timer?.cancel();
    return super.didPop(result);
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'AutomatedPopRouteBarrier';

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;
}

Widget _kDefaultIslandTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  final curveAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.fastOutSlowIn);

  return ScaleTransition(
      alignment: const Alignment(0, -.95),
      scale: Tween<double>(begin: 0, end: 1).animate(curveAnimation),
      child: child);
}
