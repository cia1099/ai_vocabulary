import 'dart:math';

import 'package:flutter/material.dart';

class ChatBubbleShape extends ShapeBorder {
  final Color? color;
  final bool isMe;
  const ChatBubbleShape({this.color, required this.isMe});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
          rect, const Radius.circular(kRadialReactionRadius)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    var path = getInnerPath(rect);
    final start = rect.bottomRight;
    path.addPath(arrowPath(start), Offset.zero);
    if (!isMe) {
      final se3 = Matrix4.rotationY(pi)..setEntry(0, 3, rect.center.dx);
      path = path.shift(Offset(-rect.center.dx, 0));
      path = path.transform(se3.storage);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (color == null) return;
    var path = Path.from(arrowPath(rect.bottomRight));
    if (!isMe) {
      final se3 = Matrix4.rotationY(pi)..setEntry(0, 3, rect.center.dx);
      path = path.shift(Offset(-rect.center.dx, 0));
      path = path.transform(se3.storage);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color!
        ..style = PaintingStyle.fill,
    );
    // canvas.drawRRect(
    //     RRect.fromRectAndRadius(
    //         rect, const Radius.circular(kRadialReactionRadius)),
    //     Paint()
    //       ..color = color
    //       ..strokeWidth = 3
    //       ..style = PaintingStyle.stroke);
    // canvas.drawPath(
    //     getOuterPath(rect),
    //     Paint()
    //       ..color = color
    //       ..strokeWidth = 3
    //       ..style = PaintingStyle.stroke);
  }

  @override
  ShapeBorder scale(double t) => this;

  Path arrowPath(Offset start) {
    const rd = 16.0;
    const rdd = 16.0;
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
      start.dx - p1x + offw,
      start.dy - rdd + p1y,
    );
    path.lineTo(start.dx - p2x + offw, start.dy - rdd + p2y);

    //2
    path.quadraticBezierTo(
      start.dx - p3x + offw,
      start.dy - rdd + p3y,
      start.dx - p4x + offw,
      start.dy - rdd + p4y,
    );

    // //3
    path.quadraticBezierTo(
      start.dx - p5x + offw,
      start.dy - rdd + p5y,
      start.dx - p6x + offw,
      start.dy - rdd + p6y,
    );
    return path;
  }
}
