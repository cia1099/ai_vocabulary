import 'package:flutter/material.dart';

class OnPointerDownPhysic extends StatefulWidget {
  final Widget child;
  final Color? color;

  const OnPointerDownPhysic({
    super.key,
    required this.child,
    this.color,
  });

  @override
  State<OnPointerDownPhysic> createState() => _OnPointerDownPhysicState();
}

class _OnPointerDownPhysicState extends State<OnPointerDownPhysic> {
  var onPointerDown = false;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Listener(
      onPointerDown: (_) => setState(() => onPointerDown = true),
      onPointerUp: (_) => setState(() => onPointerDown = false),
      onPointerCancel: (_) => setState(() => onPointerDown = false),
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 100),
        color: onPointerDown
            ? widget.color ?? colorScheme.primaryContainer.withAlpha(0xff)
            : Colors.transparent,
        elevation: onPointerDown ? 4 : 0,
        shadowColor: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(kRadialReactionRadius),
        clipBehavior: Clip.antiAlias,
        curve: Curves.easeInOutCubic,
        child: widget.child,
      ),
    );
  }
}
