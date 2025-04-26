import 'dart:math' show pi;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import 'regex.dart';

mixin ClickableTextStateMixin<T extends StatefulWidget> on State<T> {
  Future<T?> Function<T>(String)? onTap;
  int? _selectedIndex;
  final _tapRecognizers = <TapGestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    onTap =
        // <T>(word) => showPlatformModalSheet<T>(
        //   context: context,
        //   material: MaterialModalSheetData(
        //     useSafeArea: true,
        //     isScrollControlled: true,
        //   ),
        //   builder: (context) => RetrievalBottomSheet(queryWord: word),
        // );
        <T>(word) => Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Durations.medium1,
            reverseTransitionDuration: Durations.medium1,
            barrierDismissible: true,
            barrierLabel: 'Dismiss',
            opaque: false,
            barrierColor: CupertinoDynamicColor.resolve(
              kCupertinoModalBarrierColor,
              context,
            ),
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    RetrievalBottomSheet(queryWord: word),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                      position: Tween(
                        begin: const Offset(0, .75),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
          ),
        );
  }

  @override
  void dispose() {
    onTap = null;
    for (var element in _tapRecognizers) {
      element.onTap = null;
      element.dispose();
    }
    _tapRecognizers.clear();
    super.dispose();
  }

  List<TextSpan> clickableWords(
    String text, {
    Iterable<String> patterns = const [],
  }) {
    final words = splitWords(text).toList();
    return List.generate(
      words.length,
      (i) => _assignWord(words[i], i, patterns),
    );
  }

  TextSpan _assignWord(String word, int index, Iterable<String> patterns) {
    final tapRecognizer =
        word.contains(
                    RegExp(r'(?=\s+|[,.!?"=\[\]\(\)\/])|(?<=[^\x00-\x7F])'),
                  ) ||
                  word.contains(RegExp(r"('s|'re|'d|'ve|'m|'ll|^[-|+]?\d+)")) ||
                  patterns.contains(word.toLowerCase())
              ? null
              : TapGestureRecognizer()
          ?..onTap = () {
            setState(() {
              _selectedIndex = index;
            });
            onTap
                ?.call(word)
                .then(
                  (_) => setState(() {
                    _selectedIndex = null;
                  }),
                );
          };
    if (tapRecognizer != null) {
      _tapRecognizers.add(tapRecognizer);
    }
    return TextSpan(
      text: word,
      style:
          _selectedIndex != index
              ? !patterns.contains(word.toLowerCase())
                  ? null
                  : TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    shadows: List.generate(
                      1,
                      (i) => Shadow(
                        offset: Offset.fromDirection(pi * (1 + 2 * i) / 4, 2),
                        color: Theme.of(context).colorScheme.surfaceBright,
                      ),
                    ),
                  )
              : TextStyle(
                backgroundColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
      recognizer: tapRecognizer,
    );
  }
}
