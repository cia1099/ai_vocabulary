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

class Fibonacci {
  final _memory = [1, 2];

  int sequence(int n) {
    final element = _memory.elementAtOrNull(n);
    if (element != null) return element;
    final result = sequence(n - 1) + sequence(n - 2);
    _memory.add(result);
    return result;
  }

  int call(int n) => sequence(n);
}
