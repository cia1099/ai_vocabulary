import 'dart:async';

import 'package:flutter/material.dart';

class AutomatedPopRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final Widget Function(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) transitionsBuilder;
  final Duration stay;
  Timer? timer;

  AutomatedPopRoute({
    required this.builder,
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
    return buildTransitions(context, animation, secondaryAnimation, child);
  }

  @override
  bool didPop(T? result) {
    timer?.cancel();
    return super.didPop(result);
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => Colors.black54;

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
  return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
        curveAnimation,
      ),
      child: ScaleTransition(
          scale: Tween<double>(begin: .1, end: 1).animate(curveAnimation),
          child: child));
}
