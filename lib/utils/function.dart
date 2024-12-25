import 'dart:math';
import 'package:flutter/animation.dart';

class FlipXAngleTween extends Tween<double> {
  FlipXAngleTween() {
    super.begin = .0;
    super.end = 2 * pi;
  }
  @override
  double lerp(double t) => pi / 2 * sin(pi / 2 * (t - 1));
}
