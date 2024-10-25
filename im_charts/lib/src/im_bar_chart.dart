import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'im_line_chart.dart';

class ImBarChart extends StatefulWidget {
  final Color color;
  final List<String>? barLabel;
  final List<double> barData;
  final double barWidth;
  ImBarChart(
      {super.key,
      this.color = const Color(0xFF5128D4),
      this.barLabel,
      required this.barData,
      this.barWidth = 16})
      : assert(barData.isNotEmpty ||
            (throw AssertionError(
                'You have to pass at least one barData in ImBarChart')));

  @override
  State<ImBarChart> createState() => _ImBarChartState();
}

class _ImBarChartState extends State<ImBarChart>
    with SingleTickerProviderStateMixin {
  bool startShow = false;
  late double labelWidth;
  late final controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // setState(() {
      //   startShow = true;
      // });
      controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    int maxX = findMaxIntegerInDecimal(widget.barData.reduce(max));
    if (maxX == 0) {
      maxX += 1000;
    }
    const gap = 10.0;
    final drawHeight = widget.barData.length * (widget.barWidth + gap);
    final drawSize = Size(double.infinity, drawHeight);
    return Padding(
      padding: const EdgeInsets.only(
        right: 18,
        top: 24,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          labelWidth = constraints.maxWidth / 5;
          return Stack(
            children: [
              LineChart(
                figure(0, maxX, 0, widget.barData.length),
                // duration: const Duration(milliseconds: 1500),
                // curve: Curves.decelerate,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SingleChildScrollView(
                  child: CustomPaint(
                    painter: _BarPainter(
                      barWidth: widget.barWidth,
                      maxTick: maxX.toDouble(),
                      barData: widget.barData,
                      barLabel: widget.barLabel ??
                          List.generate(widget.barData.length,
                              (index) => index.toString()),
                      reservedSize: labelWidth,
                      color: widget.color,
                      gap: gap,
                      progress: controller,
                    ),
                    size: drawSize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  LineChartData figure(int minX, int maxX, int minY, int maxY) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: false,
        verticalInterval: (maxX - minX) / 5,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: CupertinoColors.systemGrey,
            strokeWidth: 1,
            dashArray: [3, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (maxX - minX) / 5,
            getTitlesWidget: xLabelTick,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: yLabelTick,
            reservedSize: labelWidth,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(left: BorderSide(color: CupertinoColors.systemGrey)),
      ),
      minX: minX.toDouble(),
      maxX: maxX.toDouble(),
      minY: minY.toDouble(),
      maxY: maxY.toDouble(),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [plotBar(1, 0)],
      // List.generate(widget.barData.length, (index) {
      //   final idx = widget.barData.length - 1 - index;
      //   return plotBar(idx.toDouble() + 1,
      //       startShow ? widget.barData[index] : minX.toDouble());
      // }),
    );
  }

  LineChartBarData plotBar(double y, double value) {
    final spots = List.filled(2, FlSpot(0, y), growable: true)
      ..insert(1, FlSpot(value, y));
    return LineChartBarData(
      isCurved: true,
      color: widget.color,
      barWidth: widget.barWidth,
      isStrokeJoinRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: spots,
    );
  }

  Widget yLabelTick(double value, TitleMeta meta) {
    return const SizedBox.shrink();
    // if (value.floor() == meta.min.floor()) return SizedBox.shrink();
    // String text;
    // if (widget.barLabel == null) {
    //   text = '${value.abs().floor() - 1}';
    // } else {
    //   final index = widget.barLabel!.length - value.abs().floor();
    //   text = index >= 0 ? widget.barLabel![index] : '$index';
    // }
    // return SideTitleWidget(
    //   axisSide: meta.axisSide,
    //   child: ImText('', color: ImColor.grey52, textAlign: TextAlign.left),
    // );
  }

  Widget xLabelTick(double value, TitleMeta meta) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final text = '${value.toInt()}'
        .replaceAllMapped(reg, (Match match) => '${match[1]},');
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        textAlign: TextAlign.left,
        // color: ImColor.grey52,
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final double reservedSize;
  final double barWidth, gap, maxTick;
  final List<double> barData;
  final List<String> barLabel;
  final Color color;
  final Animation progress;

  _BarPainter(
      {required this.reservedSize,
      required this.barWidth,
      required this.maxTick,
      required this.barData,
      required this.barLabel,
      required this.color,
      required this.progress,
      this.gap = 10})
      : super(repaint: progress);
  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Offset(reservedSize, 0) & Size(size.width - reservedSize, size.height);
    // canvas.drawRect(rect, Paint()..color = Colors.lightGreen.withOpacity(0.2));

    for (int i = 0; i < barData.length; i++) {
      final dy = barWidth / 2 + (gap + barWidth) * i;
      final p1 = Offset(rect.left, dy);
      final p2 = Offset(
          (rect.width * progress.value)
                  .clamp(0, barData[i] / maxTick * rect.width) +
              rect.left,
          dy);
      canvas.drawBar(
          p1,
          p2,
          Paint()
            ..color = color
            ..strokeWidth = barWidth);
      canvas.paintText(barLabel[i], p1.translate(-5, 0));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on Canvas {
  void drawBar(Offset p1, Offset p2, Paint paint) {
    if ((p2 - p1).distanceSquared < 1e-3) return;
    final r = paint.strokeWidth / 2;
    final dp2 = p2.translate(-r, 0);
    drawLine(p1, dp2, paint);
    final rect = Rect.fromCenter(
        center: dp2.translate(-4e-1, 0), width: 2 * r, height: 2 * r);
    drawArc(rect, -pi / 2, pi, false, paint);
  }

  void paintText(String text, Offset rightBaseLine) {
    final textPainter = TextPainter(
        textAlign: TextAlign.right,
        maxLines: 1,
        ellipsis: '...',
        text: TextSpan(
            text: text,
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              // fontSize: ImFontSize.normal,
              // overflow: TextOverflow.ellipsis,
            )),
        textDirection: TextDirection.ltr)
      ..layout(
          minWidth: rightBaseLine.dx.abs(), maxWidth: rightBaseLine.dx.abs());
    final textRect = Offset.zero & textPainter.size;
    textPainter.paint(this, Offset(0, rightBaseLine.dy) - textRect.centerLeft);
  }
}
