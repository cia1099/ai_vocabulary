import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

class SineTween extends Tween<double> {
  SineTween({super.begin = pi / 2, super.end = .0});
  @override
  double lerp(double t) => begin! + (end! - begin!) * sin(pi / 2 * t);
}

class PeakQuadraticTween extends Tween<double> {
  PeakQuadraticTween({super.begin = 0.0, super.end = 1.0});
  @override
  double lerp(double t) {
    return -15 * pow(t, 2) + 15 * t + 1;
  }
}
