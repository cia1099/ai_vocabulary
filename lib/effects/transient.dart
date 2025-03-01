import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      child:
          animation.status == AnimationStatus.reverse
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
  if (Platform.isIOS || Platform.isMacOS) {
    return CupertinoActivityIndicator.partiallyRevealed(progress: progress);
  }
  return CircularProgressIndicator(value: progress);
}
