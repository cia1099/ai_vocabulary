import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RememberChart extends StatelessWidget {
  const RememberChart({super.key});

  @override
  Widget build(BuildContext context) {
    double swipeDistance = 0.0;
    return AspectRatio(
      aspectRatio: 2 / sqrt(3),
      child: LineChart(
        figure(0, 10, context),
        duration: Durations.medium1 * 2,
        curve: Curves.easeOutSine,
      ),
    );
  }

  LineChartData figure(int minX, int maxX, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LineChartData(
        gridData: gridDraw(context),
        maxX: maxX + .5,
        minX: minX - .5,
        maxY: 1.01,
        minY: .0,
        titlesData: ticksDraw(),
        borderData: FlBorderData(
            border: const Border(bottom: BorderSide(), left: BorderSide())),
        rangeAnnotations: RangeAnnotations(
            verticalRangeAnnotations: List.generate(
                (maxX - minX) ~/ 2,
                (i) => VerticalRangeAnnotation(
                    x1: 2 * i + .5 + minX,
                    x2: 2 * i + 1.5 + minX,
                    color: CupertinoColors.tertiarySystemFill
                        .resolveFrom(context)))),
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (barData, spotIndexes) => List.generate(
              spotIndexes.length,
              (index) => TouchedSpotIndicatorData(
                    FlLine(
                        strokeWidth: 5,
                        color: colorScheme.onSecondaryContainer),
                    FlDotData(
                        show: false,
                        getDotPainter: (spot, percent, barData, idx) =>
                            FlDotCirclePainter(
                              color: CupertinoColors.white,
                              strokeColor: CupertinoColors.systemRed
                                  .resolveFrom(context),
                            )),
                  )),
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: kRadialReactionRadius,
            tooltipHorizontalAlignment: FLHorizontalAlignment.center,
            tooltipHorizontalOffset: 4,
            getTooltipColor: (touchedSpot) =>
                colorScheme.secondaryContainer.withAlpha(0xcc),
            getTooltipItems: (touchedSpots) => touchedSpots.map((sport) {
              final memory = (sport.y * 1e2).roundToDouble();
              return LineTooltipItem(
                  'Remember\n${memory.toStringAsFixed(0)}%',
                  Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .apply(color: colorScheme.onSecondaryContainer));
            }).toList(),
          ),
        ),
        lineBarsData: [
          generalCurve(minX, maxX, color: colorScheme.tertiary),
        ]);
  }

  LineChartBarData generalCurve(int minX, int maxX, {required Color color}) {
    final X = List.generate((maxX - minX) + 1, (i) => minX + i);
    return LineChartBarData(
        spots: X
            .map((x) => FlSpot(x.toDouble(), forgettingCurve(x.toDouble())))
            .toList(),
        isCurved: true,
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 24,
        barWidth: 10,
        color: color.withAlpha(0xb0),
        dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 8,
                  color: color,
                  strokeColor: color.withAlpha(0x8a),
                  strokeWidth: 4,
                )));
  }

  FlTitlesData ticksDraw() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles()),
      rightTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 16,
        getTitlesWidget: (value, meta) => const SizedBox.shrink(),
      )),
      bottomTitles: const AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        maxIncluded: false,
        minIncluded: false,
        reservedSize: 30,
      )),
      leftTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 50,
        maxIncluded: false,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text('${(value * 10).round() * 10}%'),
        ),
      )),
    );
  }

  FlGridData gridDraw(BuildContext context) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: .1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: CupertinoColors.systemGrey.resolveFrom(context),
          strokeWidth: 1,
          dashArray: [3, 5],
        );
      },
    );
  }
}

double forgettingCurve(double t, [double fib = 1]) {
  final r = log(t * 6 / fib).clamp(.0, double.infinity);
  return 1.84 / (r * r + 1.84);
}
