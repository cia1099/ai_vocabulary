import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SpeakRipple extends StatelessWidget {
  const SpeakRipple({
    super.key,
    required this.progress,
    required this.diameter,
  });

  final double progress, diameter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;
    final colors = [
      const Color(0x00000000),
      color.withValues(alpha: (16 * 4 + 13) / 255),
      color.withValues(alpha: 16 * 10 / 255),
      color.withValues(alpha: (16 * 4 + 13) / 255),
      const Color(0x00000000),
    ];
    const stops = [0.0, 0.09, 0.51, 0.93, 1.0];
    return Container(
      height: diameter,
      alignment: const Alignment(0, 0),
      decoration: ShapeDecoration(
        gradient:
            RadialGradient(radius: progress, colors: colors, stops: stops),
        shape: const CircleBorder(),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: diameter * (progress * 1.6).clamp(.0, 1.0),
            decoration: ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(
                        width: 3, color: colorScheme.secondaryContainer))),
          ),
          Container(
            height: diameter * .8 * (progress * 1.4).clamp(.0, 1.0),
            decoration: ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(
                        width: 3, color: colorScheme.secondaryContainer))),
          ),
          Container(
              height: diameter * .6,
              alignment: const Alignment(0, 0),
              decoration: ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(
                        width: 4, color: colorScheme.secondaryContainer)),
                color: colorScheme.inversePrimary.withAlpha(0xd0),
              ),
              child: Transform.flip(
                flipX: true,
                child: Icon(Icons.record_voice_over_outlined,
                    size: diameter * .4, color: colorScheme.onPrimaryContainer),
              )),
        ],
      ),
    );
  }
}

class _NoRipples extends StatelessWidget {
  const _NoRipples({
    required this.progress,
  });
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;
    return SizedBox(
      height: 164,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 164 * (progress * 1.6).clamp(.0, 1.0),
            decoration: ShapeDecoration(
                color: color.withValues(alpha: progress / 2 + .25),
                shape: const CircleBorder()),
          ),
          Container(
            height: 132 * (progress * 1.4).clamp(.0, 1.0),
            decoration: ShapeDecoration(
                color: color.withValues(alpha: progress / 1.2),
                shape: const CircleBorder()),
          ),
          Container(
              height: 100,
              alignment: const Alignment(0, 0),
              decoration: ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(
                        width: 4, color: colorScheme.onPrimaryContainer)),
                color: colorScheme.primaryContainer.withAlpha(0xd0),
              ),
              child: Icon(CupertinoIcons.mic,
                  size: 64, color: colorScheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}

class _RippleAnimation extends StatefulWidget {
  const _RippleAnimation();

  @override
  _RippleAnimationState createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<_RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => _NoRipples(
                      progress: _controller.value,
                    )),
          ),
          Align(
            alignment: const Alignment(0, .5),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) =>
                  SpeakRipple(progress: _controller.value, diameter: 164),
            ),
          )
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: _RippleAnimation()));
}
