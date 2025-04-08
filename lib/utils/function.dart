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

int fibonacci(int n, [int a = 0, int b = 1]) {
  if (n <= 0) return b;
  return fibonacci(n - 1, b, a + b);
}

class WeightedSelector<T> {
  final Random _random = Random();
  List<T> _remainingElements = [];
  List<double> _remainingWeights = [];

  WeightedSelector(Iterable<T> elements, Iterable<double> weights)
    : assert(elements.length == weights.length) {
    _remainingElements = List.from(elements);
    _remainingWeights = List.from(weights);
  }

  T? sample() {
    if (_remainingElements.isEmpty) return null;

    List<double> cdf = _computeCDF(_remainingWeights);
    final r = _random.nextDouble();

    int index = _binaryApproach(cdf, r);

    T selected = _remainingElements.removeAt(index);
    _remainingWeights.removeAt(index);

    return selected;
  }

  List<T> sampleN(int n) {
    if (n <= 0 || _remainingElements.isEmpty) return [];
    final selected = sample();
    final samples = sampleN(n - 1);
    if (selected != null) samples.add(selected);
    return samples;
  }

  List<double> _computeCDF(List<double> weights) {
    double sum = weights.reduce((a, b) => a + b);
    double cumulative = 0;
    return weights.map((w) {
      cumulative += w / sum;
      return cumulative;
    }).toList();
  }

  int _binaryApproach(List<double> cdf, double target) {
    int low = 0, high = cdf.length - 1;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (cdf[mid] < target) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }
}

// double retention(int inMinute, int fib) {
//   final factor = (6 * inMinute / 1440 / fib).clamp(1.0, double.infinity);
//   final r = log(factor);
//   return 1.84 / (r * r + 1.84);
// }

extension ScaleDouble on double? {
  double? scale(double? x) => this == null || x == null ? null : this! * x;
}

extension HelperString on String {
  String capitalize() {
    return "${substring(0, 1).toUpperCase()}${substring(1)}";
  }
}
