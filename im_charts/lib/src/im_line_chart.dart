import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImLineChart extends StatefulWidget {
  final List<DateTime> xData;
  final List<double> yData;
  final bool showGrid, showTick, playAnimation;
  final StatisticTime statisticTime;
  final Duration duration;
  final void Function(DateTime t, double y)? pointAtLine;
  ImLineChart({
    super.key,
    required this.xData,
    required this.yData,
    this.showGrid = true,
    this.showTick = true,
    this.playAnimation = true,
    this.statisticTime = StatisticTime.hour,
    this.duration = const Duration(seconds: 2),
    this.pointAtLine,
  }) : assert((xData.length == yData.length) ||
            (throw AssertionError(
                'The length of xData and yData is not consistency in ImLineChart')));

  @override
  State<ImLineChart> createState() => _ImLineChartState();
}

class _ImLineChartState extends State<ImLineChart> {
  late final bin = widget.statisticTime.bin;
  // late final hist =
  //     _histogram(bin, widget.xData, widget.yData, widget.statisticTime);
  late final yData = widget.yData;
  late final xData = widget.xData;

  late final Duration flowLag = yData.length <= 1
      ? const Duration(milliseconds: 250)
      : Duration(
          milliseconds: widget.duration.inMilliseconds ~/ (yData.length - 1));

  @override
  Widget build(BuildContext context) {
    if (widget.xData.isEmpty) {
      return const SizedBox.shrink();
    }
    int minProfit = (log(yData.reduce(min).abs() + 1) / ln10).floor();
    if (minProfit != 0 || yData.reduce(min).sign < 0) {
      if (yData.reduce(min).sign < 0) {
        minProfit = findMaxIntegerInDecimal(yData.reduce(min));
      } else {
        minProfit = pow(10, minProfit).toInt();
      }
    }
    final maxProfit = findMaxIntegerInDecimal(yData.reduce(max));

    final spots = ((List<FlSpot> Function(Function, int) f, i) => f(f.call, i))(
        (self, i) {
      final x = widget.statisticTime.track(xData[i]);
      return [FlSpot(x, yData[i])] +
          (i < xData.length - 1 ? self(self, i + 1) : []);
    }, 0)
      ..sort((a, b) => a.x.compareTo(b.x));
    // debugPrint('${'=' * 20}\nminY=$minProfit\nmaxY=$maxProfit\n${'=' * 20}');
    final flow = dataFlow(spots);
    return AspectRatio(
      aspectRatio: 2 / sqrt(3),
      child: Padding(
          padding: const EdgeInsets.only(
            right: 8,
            left: 8,
            top: 24,
            bottom: 12,
          ),
          child: StreamBuilder(
            stream: flow,
            builder: (context, snapshot) => snapshot.data != null
                ? LineChart(
                    figure(snapshot.data!, bin.reduce(min), bin.reduce(max),
                        minProfit, maxProfit),
                    duration: flowLag * 2,
                    curve: Curves.easeOutSine,
                  )
                : const CupertinoActivityIndicator(),
          )),
    );
  }

  Widget xLabelTick(double value, TitleMeta meta) {
    Widget text;
    final truncatedTick = value.toInt();
    final type = widget.statisticTime;
    if (!bin.sublist(0, bin.length - 1).contains(truncatedTick)) {
      text = const SizedBox.shrink();
    } else {
      if (type == StatisticTime.hour) {
        final quotient = truncatedTick ~/ 3;
        text = Text(
          '$truncatedTick${quotient & 3 == 0 ? type.suffix : ''}'
              .padLeft(2, '0'),
          // color: ImColor.grey52,
          // fontSize: 12,
        );
      } else {
        text = Text(
          '$truncatedTick${type.suffix}',
          // color: ImColor.grey52,
          // fontSize: 12,
        );
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget yLabelTick(double value, TitleMeta meta) {
    final tenThousands = value / 1e4;
    String text = tenThousands.floor() <= 0
        ? '${value.round()}'
        : (tenThousands - tenThousands.floor()).abs() * 1e2 <= 0
            ? '${tenThousands.truncate()}w'
            : '${tenThousands.toStringAsFixed(1)}w';
    if (value.floor() == meta.max.floor()) return const SizedBox.shrink();
    if ((value - meta.min).abs() < 0.95 * meta.appliedInterval.abs()) {
      if (value > meta.min) return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        textAlign: TextAlign.center,
        // color: ImColor.grey52,
        // fontSize: 12,
      ),
    );
  }

  LineChartData figure(
      List<FlSpot> spots, int minX, int maxX, int minY, int maxY) {
    if (minY == maxY) {
      // minY = -300000;
      // maxY = 900000;
      maxY = minY + 100;
    }
    return LineChartData(
      gridData: FlGridData(
        show: widget.showGrid,
        drawVerticalLine: true,
        horizontalInterval: (maxY - minY) / 4,
        verticalInterval: widget.statisticTime.interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: CupertinoColors.systemGrey.resolveFrom(context),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: CupertinoColors.systemGrey.resolveFrom(context),
            strokeWidth: 1,
            dashArray: [3, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: widget.showTick,
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: xLabelTick,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (maxY - minY) / 4,
            getTitlesWidget: yLabelTick,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: widget.showGrid,
        border: Border.symmetric(
            horizontal: BorderSide(
                color: CupertinoColors.systemGrey.resolveFrom(context))),
      ),
      minX: minX.toDouble(),
      maxX: maxX.toDouble(),
      minY: minY.toDouble(),
      maxY: maxY.toDouble(),
      lineTouchData: LineTouchData(
        enabled: widget.showGrid && widget.showTick,
        getTouchedSpotIndicator: (barData, spotIndexes) => List.generate(
            spotIndexes.length,
            (index) => TouchedSpotIndicatorData(
                  FlLine(color: CupertinoColors.systemRed.resolveFrom(context)),
                  FlDotData(
                      getDotPainter: (spot, percent, barData, idx) =>
                          FlDotCirclePainter(
                            color: CupertinoColors.white,
                            strokeColor:
                                CupertinoColors.systemRed.resolveFrom(context),
                          )),
                )),
        getTouchLineEnd: (barData, spotIndex) => maxY.toDouble(),
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 24,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipHorizontalOffset: 4,
          // tooltipBgColor: ImColor.red,
          tooltipMargin: -44,
          tooltipPadding: const EdgeInsets.all(0),
          // tooltipBorder: BoxDecoration(),
          getTooltipItems: (touchedSpots) {
            const txtStyle = TextStyle(
                color: CupertinoColors.white, fontWeight: FontWeight.w400);
            return List.generate(
                touchedSpots.length,
                (idx) => const LineTooltipItem(
                      '',
                      txtStyle,
                      children: [
                        // if (touchedSpots[idx].y > 0)
                        //   TextSpan(text: '+', style: txtStyle),
                        // if (touchedSpots[idx].y < 0)
                        //   TextSpan(text: '-', style: txtStyle),
                        // TextSpan(
                        //     text: touchedSpots[idx].y.toStringAsFixed(2),
                        //     style: txtStyle),
                      ],
                    ));
          },
        ),
        touchCallback: (even, lineTouch) {
          if (even.isInterestedForInteractions &&
              even is FlLongPressMoveUpdate &&
              lineTouch != null &&
              lineTouch.lineBarSpots != null) {
            final t = widget.statisticTime
                .untrack(lineTouch.lineBarSpots![0].x, widget.xData.first);
            final y = lineTouch.lineBarSpots![0].y;
            widget.pointAtLine?.call(t, y);
          }
        },
      ),
      lineBarsData: [
        plotLine(spots),
      ],
    );
  }

  LineChartBarData plotLine(List<FlSpot> spots) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColors = [
      colorScheme.primary.withAlpha(0x42),
      colorScheme.primary.withAlpha(0x0F),
    ];
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: colorScheme.primary,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
    );
  }

  Stream<List<FlSpot>> dataFlow(List<FlSpot> sp) async* {
    if (!widget.playAnimation) {
      yield sp;
    } else {
      for (int i = 0; i < sp.length; i++) {
        yield sp.sublist(0, i + 1) + List.filled(sp.length - 1 - i, sp[i]);
        await Future.delayed(flowLag);
      }
    }
  }
}

// List<double> _histogram(final List<int> bin, final List<DateTime> X,
//     final List<double> Y, StatisticTime type) {
//   final hist = List.filled(bin.length, 0.0);
//   for (int i = 0; i < X.length; i++) {
//     final dateTime = X[i];
//     int x = type.track(dateTime);
//     final positiveIndex =
//         bin.map((b) => b - x).toList().indexWhere((element) => element >= 0);
//     hist[positiveIndex] += Y[i];
//   }
//   return hist;
// }

int findMaxIntegerInDecimal(final double v) {
  int head = 1;
  int expo = (log(v.abs() + 1) / ln10).floor();
  if (expo < 1) {
    expo = 1;
  }
  final decimal = pow(10.0, expo).toDouble();
  while (head * decimal - v.abs() < 0) {
    head++;
  }
  return head * (decimal * v.sign).toInt();
}

enum StatisticTime implements Comparable<StatisticTime> {
  hour(0),
  day(1),
  month(2);

  final int type;
  const StatisticTime(this.type);

  List<int> get bin => _whatsBin();
  String get suffix => _whatsSuffix();
  double get interval => _dividedInterval();

  double track(DateTime dateTime) {
    switch (type) {
      case 1:
        final fraction = (dateTime.hour * 24 + dateTime.minute) / 24 / 60;
        return dateTime.day + fraction;
      case 2:
        final fraction = (dateTime.day * 31 + dateTime.hour) / 31 / 24;
        return dateTime.month + fraction;
      default:
        final fraction = (dateTime.minute * 60 + dateTime.second) / 3.6e3;
        return dateTime.hour + fraction;
    }
  }

  DateTime untrack(double t, DateTime ref) {
    switch (type) {
      case 1:
        final d = t ~/ (24 * 60);
        final h = t - d;
        final m = t - d - h;
        return DateTime(
            ref.year, ref.month, d, (h * 24).floor(), (m * 24 * 60).round());
      case 2:
        final M = t ~/ (31 * 24);
        final d = t - M;
        final h = t - M - d;
        return DateTime(ref.year, M, (d * 31).floor(), (h * 24).round());
      default:
        final h = t ~/ 3.6e3;
        final m = t - h;
        final s = t - h - m;
        return DateTime(ref.year, ref.month, ref.day, h, (m * 60).floor(),
            (s * 3.6e3).round());
    }
  }

  List<int> _whatsBin() {
    switch (type) {
      case 1:
        return [1] + List.generate(5, (index) => (index + 1) * 5) + [32];
      case 2:
        return List.generate(6, (index) => 1 + index * 2) + [13];
      default:
        return List.generate(8, (index) => index * 3) + [24];
    }
  }

  String _whatsSuffix() {
    switch (type) {
      case 1:
        return '日';
      case 2:
        return '月';
      default:
        return '时';
    }
  }

  double _dividedInterval() {
    switch (type) {
      case 1:
        return 5;
      // case 2:
      //   return 0;
      default:
        return 3;
    }
  }

  @override
  int compareTo(StatisticTime other) => type - other.type;
}

//only for test
DateTime createTodayTime([int? hour]) {
  final rng = Random();
  final now = DateTime.now();
  return DateTime(now.year, rng.nextInt(13), rng.nextInt(32),
      hour ?? rng.nextInt(24), rng.nextInt(60), rng.nextInt(60));
}

double createProfit() {
  final rng = Random();
  return rng.nextDouble() * 30 + 40;
}
