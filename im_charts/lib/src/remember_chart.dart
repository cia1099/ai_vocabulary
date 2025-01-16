import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RememberChart extends StatelessWidget {
  final double trainingRate;
  const RememberChart({super.key, required this.trainingRate});

  @override
  Widget build(BuildContext context) {
    double sliderValue = 0;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: .95,
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            Container(
              height: kTextTabBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: const Alignment(1, 0),
              child: Wrap(spacing: 8, children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(kRadialReactionRadius),
                    ),
                    child: Text('Your Memory',
                        style: textTheme.titleSmall
                            ?.apply(color: colorScheme.onPrimaryContainer))),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      borderRadius:
                          BorderRadius.circular(kRadialReactionRadius),
                    ),
                    child: Text(
                      'Normal People',
                      style: textTheme.titleSmall
                          ?.apply(color: colorScheme.onTertiary),
                    )),
              ]),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: LineChart(
                      figure(sliderValue.floor(), sliderValue.floor() + 10,
                          context),
                      duration: Durations.medium1 * 2,
                      curve: Curves.easeOutSine,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(-.95, 1),
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(kRadialReactionRadius),
                        ),
                        child: Text('Day',
                            style: textTheme.titleSmall?.apply(
                                color: colorScheme.onPrimaryContainer))),
                  ),
                ],
              ),
            ),
            CupertinoSlider(
              key: const Key('slider'),
              value: sliderValue,
              max: 360,
              divisions: 36,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  LineChartData figure(int minX, int maxX, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LineChartData(
      maxX: maxX + .5,
      minX: minX - .5,
      maxY: 1.01,
      minY: .0,
      lineBarsData: [
        generalCurve(minX, maxX, color: colorScheme.tertiary),
        generalCurve(minX, maxX,
            color: colorScheme.primary, fib: trainingRate, shadow: true),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: kRadialReactionRadius,
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipHorizontalOffset: 4,
          getTooltipColor: (touchedSpot) =>
              const CupertinoDynamicColor.withBrightness(
            color: Color(0xCCF2F2F2),
            darkColor: Color(0xBF1E1E1E),
          ).resolveFrom(context),
          getTooltipItems: (touchedSpots) => touchedSpots.map((sport) {
            final memory = (sport.y * 1e2).roundToDouble();
            final color = sport.barIndex == 0
                ? colorScheme.tertiary
                : colorScheme.primary;
            return LineTooltipItem('Remember: ${memory.toStringAsFixed(0)}%',
                Theme.of(context).textTheme.titleSmall!.apply(color: color));
          }).toList(),
        ),
        getTouchedSpotIndicator: (barData, spotIndexes) => List.generate(
            spotIndexes.length,
            (index) => TouchedSpotIndicatorData(
                  FlLine(
                      strokeWidth: 5, color: colorScheme.onSecondaryContainer),
                  const FlDotData(
                    show: false,
                  ),
                )),
      ),
      gridData: gridDraw(context),
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
    );
  }

  LineChartBarData generalCurve(int minX, int maxX,
      {required Color color, double fib = 1, bool shadow = false}) {
    final X = List.generate((maxX - minX) + 1, (i) => minX + i);
    final gradientColors = [
      color.withAlpha(0x42),
      color.withAlpha(0x0F),
    ];
    return LineChartBarData(
        spots: X
            .map(
                (x) => FlSpot(x.toDouble(), forgettingCurve(x.toDouble(), fib)))
            .toList(),
        isCurved: true,
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 24,
        barWidth: 10,
        color: color.withAlpha(0xb0),
        belowBarData: BarAreaData(
          show: shadow,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
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
