import 'dart:math';

import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/pages/cloze_page.dart';
import 'package:ai_vocabulary/pages/puzzle_word.dart';
import 'package:ai_vocabulary/utils/enums.dart';
import 'package:flutter/cupertino.dart';

class QuizShuttle extends StatelessWidget {
  final Vocabulary word;
  final MapEntry<String, String>? entry;
  const QuizShuttle({super.key, required this.word, this.entry});

  @override
  Widget build(BuildContext context) {
    var quiz = AppSettings.of(context).quiz;
    if (quiz == Quiz.arbitrary) {
      final provider = AppSettings.of(context).wordProvider;
      final index = Random(provider?.clozeSeed).nextInt(Quiz.values.length - 1);
      quiz = Quiz.values[index];
    }
    switch (quiz) {
      case Quiz.cloze:
        return ClozePage(word: word, entry: entry);
      case Quiz.puzzle:
        return PuzzleWord(word: word, entry: entry);
      default:
        return ClozePage(word: word, entry: entry);
    }
  }
}
