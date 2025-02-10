import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DotDotDotIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  const DotDotDotIndicator({super.key, this.size = 50.0, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dotColor = color ?? colorScheme.onPrimaryContainer;
    return SpinKitThreeBounce(
      itemBuilder: (context, index) {
        final num = index % 3;
        final colors = [
          dotColor,
          dotColor.withValues(alpha: 0.7),
          dotColor.withValues(alpha: 0.4),
        ];
        return DecoratedBox(
          decoration: BoxDecoration(color: colors[num], shape: BoxShape.circle),
        );
      },
      size: size,
      duration: const Duration(milliseconds: 1000),
    );
  }
}
