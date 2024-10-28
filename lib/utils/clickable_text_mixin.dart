import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'regex.dart';

mixin ClickableTextStateMixin<T extends StatefulWidget> on State<T> {
  Future<T?> Function<T>(String)? onTap;
  int? _selectedIndex;
  final _tapRecognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    onTap = null;
    _tapRecognizers.forEach((element) {
      element.onTap = null;
      element.dispose();
    });
    _tapRecognizers.clear();
    super.dispose();
  }

  List<TextSpan> clickableWords(String text,
      {Iterable<String> patterns = const []}) {
    final words = splitWords(text).toList();
    return List.generate(
        words.length, (i) => _assignWord(words[i], i, patterns));
  }

  TextSpan _assignWord(String word, int index, Iterable<String> patterns) {
    final tapRecognizer =
        word.contains(RegExp(r'(?=\s+|[,.!?=\[\]\(\)\/])|(?<=[^\x00-\x7F])')) ||
                word.contains(RegExp(r"('s|'re|'d|'ve|'m|'ll|^[-|+]?\d+)")) ||
                patterns.contains(word)
            ? null
            : TapGestureRecognizer()
          ?..onTap = () {
            setState(() {
              _selectedIndex = index;
            });
            onTap?.call(word).then((_) => setState(() {
                  _selectedIndex = null;
                }));
          };
    if (tapRecognizer != null) {
      _tapRecognizers.add(tapRecognizer);
    }
    return TextSpan(
        text: word,
        style: _selectedIndex != index
            ? !patterns.contains(word)
                ? null
                : TextStyle(color: Theme.of(context).colorScheme.inversePrimary)
            : TextStyle(
                backgroundColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.onPrimary),
        recognizer: tapRecognizer);
  }
}
