import 'package:flutter/cupertino.dart';

const _speechShortcut = {
  "verb": "v.",
  "noun": "n.",
  "adjective": "adj.",
  "adverb": "adv.",
  "pronoun": "pron.",
  "preposition": "prep.",
  "conjunction": "conj.",
  "interjection": "int."
};

const kAppBarPadding = 10.0;
const kMaxAcquaintance = 15;
const kRemindLength = 7;
const kMenuDividerHeight = 8.0;
const kMaxInt64 = 9223372036854775807;
const kUncategorizedName = 'uncategorized';

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

extension ScaleDouble on double? {
  double? scale(double? x) => this == null || x == null ? null : this! * x;
}

class CupertinoDialogTransition extends StatelessWidget {
  const CupertinoDialogTransition(
      {super.key, required this.animation, this.scale = 1.3, this.child});

  final Animation<double> animation;
  final double scale;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOutBack),
      child: animation.status == AnimationStatus.reverse
          ? child
          : ScaleTransition(
              scale: Tween(begin: scale, end: 1.0).animate(animation),
              child: child),
    );
  }
}
