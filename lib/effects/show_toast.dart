import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';

void _showToast({
  required BuildContext context,
  required Widget child,
  Alignment alignment = Alignment.center,
  Duration stay = Durations.extralong4,
}) {
  const duration = Durations.long2;
  final key = GlobalKey();
  final overlayEntry = OverlayEntry(
    // opaque: true,
    builder:
        (context) => Align(
          alignment: alignment,
          child: _AnimatedFadeInOut(key: key, duration: duration, child: child),
        ),
  );
  Overlay.of(context).insert(overlayEntry);
  Future.delayed(stay, () {
    // ignore: invalid_use_of_protected_member
    key.currentState?.deactivate();
    Future.delayed(duration * 1.5, () {
      overlayEntry.remove();
      overlayEntry.dispose();
    });
  });
}

void showToast({
  required BuildContext context,
  required Widget child,
  Alignment alignment = Alignment.center,
  Duration stay = Durations.extralong4,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  _showToast(
    context: context,
    alignment: alignment,
    stay: stay,
    child: FractionallySizedBox(
      widthFactor: .85,
      child: Container(
        height: 85,
        padding: const EdgeInsets.all(8),
        alignment: const Alignment(0, 0),
        decoration: BoxDecoration(
          color: const CupertinoDynamicColor.withBrightness(
            color: Color(0xBF1E1E1E),
            darkColor: Color(0xCCF2F2F2),
          ).resolveFrom(context),
          borderRadius: BorderRadius.circular(42.5),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: colorScheme.onInverseSurface),
          child: child,
        ),
      ),
    ),
  );
}

void appearAward(BuildContext context, String? word) {
  final colorScheme = Theme.of(context).colorScheme;
  showToast(
    context: context,
    stay: const Duration(milliseconds: 1500),
    alignment: const Alignment(0, .4),
    child: Row(
      children: [
        Lottie.asset('assets/lottie/coin.json'),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: "You're familiar with ",
              children: [
                TextSpan(
                  text: word,
                  style: TextStyle(color: colorScheme.primaryContainer),
                ),
                const TextSpan(text: " a lot!"),
              ],
            ),
            style: TextStyle(color: colorScheme.onInverseSurface),
          ),
        ),
      ],
    ),
  );
}

class _AnimatedFadeInOut extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _AnimatedFadeInOut({
    super.key,
    required this.child,
    this.duration = Durations.short2,
  });

  @override
  State<_AnimatedFadeInOut> createState() => _FadeInOutState();
}

class _FadeInOutState extends State<_AnimatedFadeInOut>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller.forward();
    });
  }

  @override
  void deactivate() {
    controller.reverse();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: controller,
        curve: Curves.linearToEaseOut,
        reverseCurve: Curves.fastOutSlowIn,
      ),
      child: widget.child,
    );
  }
}
