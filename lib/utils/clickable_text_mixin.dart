import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

mixin ClickableTextStateMixin<T extends StatefulWidget> on State<T> {
  Future<T?> Function<T>(String)? onTap;
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
    final words = _splitWords(text);
    return List.generate(
        words.length, (i) => _assignWord(words[i], i, patterns));
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

  TextSpan _assignWord(String word, int index, Iterable<String> patterns) {
    final tapRecognizer = word.contains(RegExp(r'(?=\s+|[,.!?=\[\]\(\)\/])')) ||
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
