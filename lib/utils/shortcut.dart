import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;

const _speechShortcut = {
  "verb": "v.",
  "noun": "n.",
  "adjective": "adj.",
  "adverb": "adv.",
  "pronoun": "pron.",
  "preposition": "prep.",
  "conjunction": "conj.",
  "interjection": "int.",
};

CupertinoDynamicColor? _speechColor(String partOfSpeech) =>
    switch (partOfSpeech) {
      "noun" => CupertinoColors.systemCyan,
      "verb" => CupertinoColors.systemPink,
      "adjective" => CupertinoDynamicColor.withBrightness(
        color: Colors.teal[600]!,
        darkColor: Colors.teal,
      ),
      "adverb" => CupertinoColors.systemOrange,
      _ => null,
    };

const kAppBarPadding = 10.0;
const kMaxAcquaintance = 15;
const kRemindLength = 7;
const kMenuDividerHeight = 8.0;
const kMaxInt64 = 9223372036854775807;
const kUncategorizedName = 'uncategorized';
// const kcollapsedSliverHeight = 64.0;
const kExpandedSliverAppBarHeight = 112.0;

const kCupertinoSheetColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xCCF2F2F2),
  darkColor: Color(0xBF1E1E1E),
);

String speechShortcut(String partOfSpeech, {int length = 0}) {
  final shortcut =
      _speechShortcut[partOfSpeech] ?? '${partOfSpeech.substring(0, 3)}.';
  return shortcut.length < length
      ? ' ' * (length - shortcut.length) + shortcut
      : shortcut;
}

class SpeechColoredText {
  final String partOfSpeech;
  final BuildContext context;
  final int length;
  final bool isShortcut;
  final TextStyle? style;

  final double maxWidth;
  late final TextPainter textPainter;

  SpeechColoredText({
    required this.partOfSpeech,
    required this.context,
    this.isShortcut = false,
    this.length = 0,
    this.maxWidth = double.infinity,
    this.style,
  }) {
    final color = _speechColor(partOfSpeech)?.resolveFrom(context);
    textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: isShortcut ? _shortcut() : partOfSpeech,
        style: style?.apply(color: color) ?? TextStyle(color: color),
      ),
    )..layout(maxWidth: maxWidth);
  }

  String _shortcut() {
    final shortcut =
        _speechShortcut[partOfSpeech] ?? '${partOfSpeech.substring(0, 3)}.';
    return shortcut.length < length
        ? ' ' * (length - shortcut.length) + shortcut
        : shortcut;
  }

  InlineSpan get span => textPainter.text!;
}
