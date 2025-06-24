import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, StretchMode;

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
const kStretchModes = [
  StretchMode.zoomBackground,
  StretchMode.blurBackground,
  StretchMode.fadeTitle,
];
const String kChatBotUID = '00000000-0000-0000-0000-000000000000';

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

extension SpeechColoredText on Text {
  Text coloredSpeech({
    required BuildContext context,
    final bool isShortcut = false,
    final int length = 0,
  }) {
    final color = _speechColor(data!)?.resolveFrom(context);
    final text = isShortcut ? speechShortcut(data!, length: length) : data!;
    return Text(
      text,
      style: style?.apply(color: color) ?? TextStyle(color: color),
    );
  }
}

const kAppleJson = '''
{"word_id": 810, "frequency": 0.5, "word": "apple", "asset": "http://www.cia1099.cloudns.ch/dict/dictionary/img/thumb/apple.jpg", "definitions": [{"part_of_speech": "noun", "explanations": [{"explain": "a hard, round fruit with a smooth green, red or yellow skin", "subscript": "countable, uncountable", "examples": ["apple juice"]}], "audio_us": "http://www.cia1099.cloudns.ch/dict/dictionary/audio/apple__us_1.mp3", "phonetic_uk": "/\u02c8\u00e6p.\u0259l/", "inflection": "apple, apples", "phonetic_us": "/\u02c8\u00e6p(\u0259)l/", "synonyms": null, "antonyms": null, "audio_uk": "http://www.cia1099.cloudns.ch/dict/dictionary/audio/apple__gb_1.mp3", "definition_id": 992}]}
''';
