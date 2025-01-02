import 'dart:math' show pi, sqrt2;

import 'package:flutter/material.dart';

class SlideAppear extends StatefulWidget {
  final bool isHorizontal;
  final Widget child;
  const SlideAppear(
      {super.key, required this.child, this.isHorizontal = false});

  @override
  State<SlideAppear> createState() => _SlideAppearState();
}

class _SlideAppearState extends State<SlideAppear> {
  late var offset = widget.isHorizontal
      ? Offset.fromDirection(0, sqrt2)
      : Offset.fromDirection(pi / 2, sqrt2);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        offset = Offset.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: offset,
      duration: Durations.long3,
      curve: Curves.fastOutSlowIn,
      child: widget.child,
    );
  }
}
