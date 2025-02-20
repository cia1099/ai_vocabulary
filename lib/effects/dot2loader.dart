import 'package:flutter/material.dart';

class TwoDotLoader extends StatefulWidget {
  const TwoDotLoader({super.key, this.size});
  final double? size;

  @override
  State<TwoDotLoader> createState() => _TwoDotLoaderState();
}

class _TwoDotLoaderState extends State<TwoDotLoader>
    with SingleTickerProviderStateMixin {
  late final controller =
      AnimationController(vsync: this, duration: Durations.long2)
        ..repeat(reverse: true);
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      children: [
        SlideTransition(
            position: Tween(begin: Offset.zero, end: const Offset(1, 0))
                .animate(CurvedAnimation(
                    parent: controller, curve: Curves.easeInOut)),
            child: CircleAvatar(
                radius: (widget.size ?? 16) / 2,
                backgroundColor: colorScheme.secondary.withAlpha(0xc4))),
        SlideTransition(
            position: Tween(begin: Offset.zero, end: const Offset(-1, 0))
                .animate(CurvedAnimation(
                    parent: controller, curve: Curves.easeInOut)),
            child: CircleAvatar(
                radius: (widget.size ?? 16) / 2,
                backgroundColor: colorScheme.tertiary.withAlpha(0xc4))),
      ],
    );
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }
}
