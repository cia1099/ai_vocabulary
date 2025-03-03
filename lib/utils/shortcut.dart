import 'package:flutter/cupertino.dart';

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
