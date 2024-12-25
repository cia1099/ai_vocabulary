import 'dart:math';
import 'package:flutter/animation.dart';

class SineTween extends Tween<double> {
  SineTween({super.begin = pi / 2, super.end = .0});
  @override
  double lerp(double t) => begin! + (end! - begin!) * sin(pi / 2 * t);
}
