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
    final color = colorScheme.inversePrimary;
    // CupertinoDynamicColor.withBrightness(
    //         color: colorScheme.primaryContainer, darkColor: colorScheme.primary)
    //     .resolveFrom(context);
    final strokeColor = CupertinoDynamicColor.withBrightness(
            color: colorScheme.secondaryContainer,
            darkColor: colorScheme.secondary)
        .resolveFrom(context);
    final colors = [
      const Color(0x00000000),
      HSVColor.fromColor(color).withSaturation((16 * 4 + 13) / 255).toColor(),
      HSVColor.fromColor(color).withSaturation(16 * 10 / 255).toColor(),
      HSVColor.fromColor(color).withSaturation((16 * 4 + 13) / 255).toColor(),
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
              height: diameter * .6,
              alignment: const Alignment(0, 0),
              decoration: ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(width: 4, color: strokeColor)),
                color: colorScheme.inversePrimary, //.withAlpha(0xd0),
              ),
              child: Transform.flip(
                flipX: true,
                child: Icon(Icons.record_voice_over_outlined,
                    size: diameter * .4, color: colorScheme.onPrimaryContainer),
              )),
          Container(
            height: diameter * (progress * 1.6).clamp(.0, 1.0),
            decoration: ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(
                        width: 1.5,
                        color: strokeColor.withValues(alpha: progress)))),
          ),
          Container(
            height: diameter * .8 * (progress * 1.4).clamp(.0, 1.0),
            decoration: ShapeDecoration(
                shape: CircleBorder(
                    side: BorderSide(
                        width: 1.5,
                        color: strokeColor.withValues(alpha: progress)))),
          ),
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
    // final color = CupertinoDynamicColor.withBrightness(
    //         color: colorScheme.primary, darkColor: colorScheme.primaryContainer)
    //     .resolveFrom(context);
    final colors = [
      colorScheme.primaryContainer,
      colorScheme.primary,
      // HSVColor.fromColor(color).withSaturation((16 * 4 + 13) / 255).toColor(),
      // HSVColor.fromColor(color).withSaturation(16 * 10 / 255).toColor(),
    ];
    const stops = [1.8, 1.8, 1.8]; //[1.6, 3.2, 6.4];
    return Container(
        height: 100,
        alignment: const Alignment(0, 0),
        decoration: ShapeDecoration(
          shape: CircleBorder(
              side:
                  BorderSide(width: 4, color: colorScheme.onPrimaryContainer)),
          color: colorScheme.inversePrimary, //.withAlpha(0xd0),
          shadows: List.generate(
              colors.length,
              (i) => BoxShadow(
                    blurRadius: stops[i],
                    spreadRadius: (colors.length - i) * 20 * progress,
                    color: colors[i],
                    // blurStyle: BlurStyle.solid,
                  )),
        ),
        child: Icon(CupertinoIcons.mic,
            size: 64, color: colorScheme.onPrimaryContainer));
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
  runApp(MaterialApp(
    theme: ThemeData.light(),
    home: const _RippleAnimation(),
  ));
}
