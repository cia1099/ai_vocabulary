import 'dart:math' show pi;
import 'dart:ui' as ui show ImageFilter;

import 'package:flutter/material.dart';

class ChatBubblePainter extends CustomPainter {
  final ColorScheme colorScheme;
  final bool isMe;

  ChatBubblePainter(
      {super.repaint, required this.colorScheme, this.isMe = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          isMe ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh
      ..style = PaintingStyle.fill;
    final rect = Offset.zero & size;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect, const Radius.circular(kRadialReactionRadius)),
        paint);

    final mirror = isMe
        ? Matrix4.identity()
        : (Matrix4.rotationY(pi)..setEntry(0, 3, size.width));
    canvas.drawPath(bottomRightArrow(size),
        paint..imageFilter = ui.ImageFilter.matrix(mirror.storage));
  }

  Path bottomRightArrow(Size size) {
    const rd = 16.0; //计算比例使用
    const rdd = 16.0; // 实际大小
    const offw = 4.0;

    const p1x = rdd * (4 / rd);
    const p1y = rdd * (0.0 / rd);

    const p2x = rdd * (4 / rd);
    const p2y = rdd * (8 / rd);

    const p3x = rdd * (3.0 / rd);
    const p3y = rdd * (12.0 / rd);

    const p4x = rdd * (0.0 / rd);
    const p4y = rdd * (rd / rd);

    const p5x = rdd * (15.0 / rd);
    const p5y = rdd * (15.0 / rd);

    const p6x = rdd * (16.0 / rd);
    const p6y = rdd * (0.0 / rd);

    final path = Path();
    path.moveTo(
      size.width - p1x + offw,
      size.height - rdd + p1y,
    );
    path.lineTo(size.width - p2x + offw, size.height - rdd + p2y);

    //2
    path.quadraticBezierTo(
      size.width - p3x + offw,
      size.height - rdd + p3y,
      size.width - p4x + offw,
      size.height - rdd + p4y,
    );

    // //3
    path.quadraticBezierTo(
      size.width - p5x + offw,
      size.height - rdd + p5y,
      size.width - p6x + offw,
      size.height - rdd + p6y,
    );
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
