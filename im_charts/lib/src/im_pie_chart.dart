import 'dart:math' as math;
import 'package:flutter/material.dart';

class ImPieChart extends StatefulWidget {
  final double percentage;
  const ImPieChart({super.key, this.percentage = 0});

  @override
  State<ImPieChart> createState() => _ImPieChartState();
}

class _ImPieChartState extends State<ImPieChart>
    with SingleTickerProviderStateMixin {
  final velocity = 0.5;
  late final controller = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: (widget.percentage / velocity * 1e3).round()))
    ..forward();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final localSize = Size(constraints.maxWidth, constraints.maxHeight);
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) => CustomPaint(
            painter: _RingPainter(
                progress: controller.value,
                percentage: widget.percentage.clamp(0.0, 1.0)),
            size: localSize,
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final double progress;
  _RingPainter({this.percentage = 0, this.progress = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.height / 6;
    canvas.drawCircle(
        c,
        size.height / 2 - strokeWidth / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = Color(0xFFD9D9D9));
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: size.height / 2 - strokeWidth / 2),
        -math.pi / 2,
        progress * 2 * math.pi * percentage,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = Color(0xFF243BB2));
    var textPainter = TextPainter(
        text: TextSpan(
            text: '当日收益占比',
            style: TextStyle(
                color: Color(0x85121212),
                fontSize: size.height / 12,
                fontWeight: FontWeight.w400)),
        textDirection: TextDirection.ltr)
      ..layout();
    var textRect = Offset.zero & textPainter.size;
    final shift = Offset(0, size.height / 6);
    textPainter.paint(canvas, c + shift - textRect.center);

    textPainter.text = TextSpan(
        text: (progress * percentage * 100).toStringAsFixed(0) + '%',
        style: TextStyle(
            color: Colors.black,
            fontSize: size.height / 4,
            fontWeight: FontWeight.w600));
    textPainter.layout();
    textRect = Offset.zero & textPainter.size;
    textPainter.paint(canvas, c - textRect.center);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => true;
}
