import 'dart:math' show pi, sqrt2;

import 'package:ai_vocabulary/utils/shortcut.dart' show kCupertinoSheetColor;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, kRadialReactionRadius;

class TipOverlap extends StatelessWidget {
  final Widget? child;
  final Widget Function(BuildContext context) tipBuilder;
  final VoidCallback? onTap;
  const TipOverlap({
    super.key,
    required this.tipBuilder,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    return GestureDetector(
      onTap: () {
        onTap?.call();
        final rBox = context.findRenderObject() as RenderBox?;
        var anchor = rBox?.localToGlobal(Offset.zero);
        if (anchor == null || rBox == null) return;
        anchor += Offset(rBox.size.width / 2, 0);
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            barrierLabel: 'Tip',
            barrierColor: colorScheme.inverseSurface.withValues(
              alpha: isDark ? 5e-2 : .4,
            ),
            pageBuilder: (context, animation, _) {
              const tipWidth = 225.0;
              final left = (anchor!.dx - tipWidth / 2).clamp(
                .0,
                screenSize.width - tipWidth,
              );
              final top = anchor.dy + TipShape.kArrowHeight + rBox.size.height;
              final bottom =
                  screenSize.height - anchor.dy + TipShape.kArrowHeight;
              final bottom2TopScroll = top > bottom ? pi : .0;
              return Stack(
                children: [
                  Positioned(
                    left: left,
                    width: tipWidth,
                    top: top > bottom ? null : top,
                    bottom: top > bottom ? bottom : null,
                    child: Transform(
                      transform: Matrix4.rotationX(bottom2TopScroll),
                      alignment: Alignment(0, 0),
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          color: kCupertinoSheetColor.resolveFrom(context),
                          shape: TipShape(),
                        ),
                        child: Transform(
                          transform: Matrix4.rotationX(bottom2TopScroll),
                          alignment: Alignment(0, 0),
                          child: tipBuilder(context),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            transitionsBuilder: (_, animation, _, child) {
              final matrix = Matrix4Tween(
                end: Matrix4.diagonal3Values(1, 1, 1),
                begin: Matrix4.diagonal3Values(1, .1, 1),
              ).chain(CurveTween(curve: Curves.easeOut));
              return AnimatedBuilder(
                animation: animation,
                builder: (_, __) => Transform(
                  origin: anchor,
                  alignment: Alignment.topCenter,
                  transform: matrix.evaluate(animation),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: AbsorbPointer(child: child),
    );
  }
}

class TipShape extends ShapeBorder {
  static const kArrowHeight = 20.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(kRadialReactionRadius / 2),
      ),
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = getInnerPath(rect);
    const h = kArrowHeight, base = h * sqrt2;
    final points = [
      Offset(0, -h),
      Offset(-base / 2, 0),
      Offset(base / 2, 0),
    ].map((p) => p + rect.topCenter);
    path.addPolygon(points.toList(), true);
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

void main() {
  runApp(CupertinoApp(home: Home()));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Align(
        alignment: Alignment(0, -.25),
        child: TipOverlap(
          tipBuilder: (context) => Text("Shit man"),
          child: CupertinoButton.tinted(
            onPressed: () {},
            child: Text("Show Tip"),
          ),
        ),
      ),
    );
  }
}
