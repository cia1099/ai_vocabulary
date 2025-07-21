import 'dart:math' show pi;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CupertinoApp(home: _HomePage()));
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final isHome = ValueNotifier(true);
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: isHome,
                builder: (context, value, child) => AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  decoration: value
                      ? homeDecoration()
                      : backgroundAuthDecoration(),
                ),
              ),
            ),
            Align(
              alignment: Alignment(0, .75),
              child: CupertinoButton.tinted(
                child: Text("Toggle background"),
                onPressed: () {
                  isHome.value ^= true;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Decoration homeDecoration() {
  return BoxDecoration(
    // borderRadius: BorderRadius.circular(_borderRadius),
    gradient: LinearGradient(
      transform: GradientRotation(-pi / 4),
      stops: const [0.1, 0.5, 0.7, 0.9],
      colors: [
        homePageBackgroundColor[800]!,
        homePageBackgroundColor[700]!,
        homePageBackgroundColor[600]!,
        homePageBackgroundColor[400]!,
      ],
    ),
  );
}

Decoration backgroundAuthDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      transform: GradientRotation(-pi / 4),
      stops: const [0.1, 0.5, 0.9],
      colors: [
        authPageBackgroundColor[700]!,
        authPageBackgroundColor[600]!,
        authPageBackgroundColor[400]!,
      ],
    ),
  );
}

const MaterialColor authPageBackgroundColor = Colors.blueGrey;
const MaterialColor homePageBackgroundColor = Colors.indigo;
