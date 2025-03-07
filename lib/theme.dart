import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ColorSeed {
  baseColor('M3 Baseline', Color(0xff6750a4)),
  indigo('Indigo', CupertinoColors.systemIndigo),
  blue('Blue', CupertinoColors.systemBlue),
  teal('Teal', CupertinoColors.systemTeal),
  green('Green', CupertinoColors.systemGreen),
  yellow('Yellow', CupertinoColors.systemYellow),
  orange('Orange', CupertinoColors.systemOrange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', CupertinoColors.systemPink),
  prussianBlue('Prussian Blue', Color(0xff003153)),
  vandykeBrown('Vandyke Brown', Color(0xff8f4b28));

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

enum ColorImageProvider {
  leaves(
    'Leaves',
    'https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_1.png',
  ),
  peonies(
    'Peonies',
    'https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_2.png',
  ),
  bubbles(
    'Bubbles',
    'https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_3.png',
  ),
  seaweed(
    'Seaweed',
    'https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_4.png',
  ),
  seagrapes(
    'Sea Grapes',
    'https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_5.png',
  ),
  petals(
    'Petals',
    'https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_6.png',
  );

  const ColorImageProvider(this.label, this.url);
  final String label;
  final String url;
}
