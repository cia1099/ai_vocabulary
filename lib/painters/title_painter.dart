import 'dart:math' show pi;

import 'package:flutter/material.dart';

class TitlePainter extends CustomPainter {
  final String title;
  final double headerHeight;
  final TextStyle? style;
  final Color? strokeColor;

  TitlePainter(
      {super.repaint,
      required this.title,
      required this.headerHeight,
      this.strokeColor,
      this.style});
  @override
  void paint(Canvas canvas, Size size) {
    final h = (size.height - kToolbarHeight) / headerHeight;
    final opacity = h > .05 && h < .25 ? .0 : 1.0;
    final textPainter = TextPainter(
        maxLines: 1,
        ellipsis: '...',
        textScaler: TextScaler.linear(1 + h),
        text: TextSpan(
          text: title,
          style: style?.apply(
            //TODO: apply below code will casue flutter bug
            color: style?.color?.withOpacity(opacity),
            shadows: List.generate(
                4,
                (i) => Shadow(
                    offset: Offset.fromDirection(pi * (1 + 2 * i) / 4, 2),
                    color: strokeColor?.withOpacity(h < .25 ? .0 : h) ??
                        kDefaultIconLightColor)),
          ),
        ),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: size.width);

    final textRect = Offset.zero & textPainter.size;
    final dOffset = Tween<Offset>(
        end: Offset(16, headerHeight - 16) - textRect.centerLeft / 2,
        begin: Offset(size.width / 2, 0) +
            textRect.centerLeft / 2 -
            textRect.topRight / 2);
    textPainter.paint(canvas, dOffset.transform(h));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
