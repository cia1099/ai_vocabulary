import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart'
    show isCupertino;

class CupertinoDialogTransition extends StatelessWidget {
  const CupertinoDialogTransition({
    super.key,
    required this.animation,
    this.scale = 1.3,
    this.child,
  });

  final Animation<double> animation;
  final double scale;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOutBack,
      ),
      child: animation.status == AnimationStatus.reverse
          ? child
          : ScaleTransition(
              scale: Tween(begin: scale, end: 1.0).animate(animation),
              child: child,
            ),
    );
  }
}

Widget loadingBuilder(
  BuildContext context,
  Widget child,
  ImageChunkEvent? loadingProgress,
) {
  if (loadingProgress == null) return child;
  final progress =
      loadingProgress.cumulativeBytesLoaded /
      loadingProgress.expectedTotalBytes!;
  if (isCupertino(context)) {
    return CupertinoActivityIndicator.partiallyRevealed(progress: progress);
  }
  return CircularProgressIndicator(value: progress);
}

Widget generateImageLoader(
  BuildContext context,
  Widget child,
  int? frame,
  bool wasSynchronouslyLoaded,
) {
  if (wasSynchronouslyLoaded) return child;
  return AnimatedSwitcher(
    duration: Durations.extralong1,
    switchInCurve: Curves.easeInOut,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) =>
        FadeTransition(opacity: animation, child: child),
    child: frame == null
        ? const Center(
            child: Wrap(
              direction: Axis.vertical,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                CircularProgressIndicator.adaptive(),
                Text(
                  'Image is generating, please wait...',
                  textScaler: TextScaler.noScaling,
                ),
              ],
            ),
          )
        : child,
  );
}
