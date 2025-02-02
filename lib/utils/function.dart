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

class WeightedSelector<T> {
  final Iterable<T> elements;
  final Iterable<double> weights;
  final Random _random = Random();
  List<T> _remainingElements = [];
  List<double> _remainingWeights = [];

  WeightedSelector(this.elements, this.weights)
      : assert(elements.length == weights.length) {
    _remainingElements = List.from(elements);
    _remainingWeights = List.from(weights);
  }

  T? sample() {
    if (_remainingElements.isEmpty) return null;

    List<double> cdf = _computeCDF(_remainingWeights);
    final r = _random.nextDouble();

    int index = _binarySearch(cdf, r);

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

  int _binarySearch(List<double> cdf, double target) {
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
