import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

mixin ClickableTextStateMixin<T extends StatefulWidget> on State<T> {
  Future<T?> Function<T>(String)? onTap;

  List<TextSpan> clickableWords(String text) {
    final words = _splitWords(text);
    return List.generate(words.length, (i) => _assignWord(words[i], i));
  }

  int? _selectedIndex;
  List<String> _splitWords(String text) {
    return text
        .split(RegExp(r'(?=\s+|[,.!?=\[\]\(\)\/])|(?<=\s+|[,.!?=\[\]\(\)\/])'))
        .expand((word) sync* {
          final match =
              RegExp(r"(\w+)?('s|'re|'d|'ve|'m|'ll)").firstMatch(word);
          if (match != null) {
            for (final m in match.groups([1, 2])) yield m ?? '';
          } else {
            yield word;
          }
        })
        .where((w) => w.isNotEmpty)
        .toList();
  }

  TextSpan _assignWord(String word, int index) {
    return TextSpan(
        text: word,
        style: _selectedIndex != index
            ? null
            : TextStyle(
                backgroundColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.onPrimary),
        recognizer: word.contains(RegExp(r'(?=\s+|[,.!?=\[\]\(\)\/])')) ||
                word.contains(RegExp(r"('s|'re|'d|'ve|'m|'ll|^[-|+]?\d+)"))
            ? null
            : TapGestureRecognizer()
          ?..onTap = () {
            setState(() {
              _selectedIndex = index;
            });
            onTap?.call(word).then((_) => setState(() {
                  _selectedIndex = null;
                }));
          });
  }
}
