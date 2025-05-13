import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
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
      vsync: this, duration: Durations.extralong1
      // Duration(milliseconds: (widget.percentage / velocity * 1e3).round()),
      );
  @override
  Widget build(BuildContext context) {
    controller.animateTo(widget.percentage.clamp(.0, 1.0));
    final colorScheme = Theme.of(context).colorScheme;
    final platform = Theme.of(context).platform;
    return LayoutBuilder(
      builder: (context, constraints) {
        final localSize = Size(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          painter: _RingPainter(
            progress: controller,
            // subtitleColor: DefaultTextStyle.of(context).style.color,
            subtitleColor: colorScheme.onSecondaryContainer,
            colors: [TargetPlatform.iOS, TargetPlatform.macOS]
                    .contains(platform)
                ? [
                    CupertinoColors.systemPink.resolveFrom(context),
                    CupertinoColors.systemOrange.resolveFrom(context),
                    CupertinoColors.systemMint.resolveFrom(context),
                  ]
                : const [Colors.pinkAccent, Colors.orangeAccent, Colors.teal],
          ),
          size: localSize,
        );
      },
    );
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }
}

class _RingPainter extends CustomPainter {
  final Animation progress;
  final List<Color> colors;
  final Color? subtitleColor;
  _RingPainter(
      {required this.progress, required this.colors, this.subtitleColor})
      : super(repaint: progress);

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
          ..color = const Color(0xAFD9D9D9));
    final rect =
        Rect.fromCircle(center: c, radius: size.height / 2 - strokeWidth / 2);
    canvas.drawArc(
        rect,
        -math.pi / 2,
        progress.value * 2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..shader = SweepGradient(
                  transform: const GradientRotation(-math.pi / 2),
                  stops: const [.15, .5, .85],
                  colors: colors)
              .createShader(rect));
    var textPainter = TextPainter(
        text: TextSpan(
            text: 'Current Retention',
            style: TextStyle(
              fontSize: size.height / 12,
              fontWeight: FontWeight.w400,
              color: subtitleColor,
            )),
        textDirection: TextDirection.ltr)
      ..layout();
    var textRect = Offset.zero & textPainter.size;
    final shift = Offset(0, size.height / 6);
    textPainter.paint(canvas, c + shift - textRect.center);

    final t = progress.value;
    textPainter.text = TextSpan(
        text: '${(progress.value * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: size.height / 4,
          fontWeight: FontWeight.w600,
          color: Color.lerp(Color.lerp(colors[0], colors[1], t),
              Color.lerp(colors[1], colors[2], t), t),
        ));
    textPainter.layout();
    textRect = Offset.zero & textPainter.size;
    textPainter.paint(canvas, c - textRect.center);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => false;
}
