import 'package:flutter/cupertino.dart';

class BubbleArrowPainter extends CustomPainter {
  final Color color;

  BubbleArrowPainter({super.repaint, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path.from(arrowPath(Offset(w * .95, h)));
    // final se3 = Matrix4.rotationZ(0)
    //   ..setEntry(0, 3, w * .95)
    //   ..setEntry(1, 3, h);
    canvas.drawPath(
        // path.transform(se3.storage),
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);

    // canvas.drawRect(
    //     Offset.zero & size,
    //     Paint()
    //       ..color = CupertinoColors.black
    //       ..strokeWidth = 1
    //       ..style = PaintingStyle.stroke);
  }

  Path arrowPath(Offset start) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
