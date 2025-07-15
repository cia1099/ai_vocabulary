import 'dart:async';
import 'dart:math';

import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/load_word_route.dart' show loadWordList;
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:im_charts/im_charts.dart';

import '../api/dict_api.dart';
import '../app_settings.dart';
import '../database/my_db.dart';
import '../model/vocabulary.dart';
import '../utils/regex.dart';

part 'word_provider2.dart';

abstract class WordProvider {
  final _studyWords = <Vocabulary>[];
  late final pageController = PageController(
    onAttach: _onAttach,
    keepPage: false,
  );
  Vocabulary? _currentWord;
  final _providerState = StreamController<Vocabulary?>();
  late final _provider = _providerState.stream.asBroadcastStream();
  var _completer = Completer<bool>();
  var clozeSeed = 101; //To keep cloze example is the same when navigation occur

  Future<bool> get isReady => _completer.future;

  Stream<Vocabulary?> get provideWord async* {
    yield _currentWord;
    yield* _provider;
  }

  set currentWord(Vocabulary? word) {
    _currentWord = word;
    _providerState.add(word);
  }

  Vocabulary? get currentWord => _currentWord;
  int get length => _studyWords.length;
  Vocabulary operator [](int i) => _studyWords[i];
  Iterable<T> map<T>(T Function(Vocabulary) toElement) =>
      _studyWords.map(toElement);
  int indexWhere(bool Function(Vocabulary w) test, [int start = 0]) =>
      _studyWords.indexWhere(test, start);
  // reminder
  static final _remindWords = <Vocabulary>{};
  bool shouldRemind([bool reachTarget = false]) {
    return _remindWords.isNotEmpty &&
            _remindWords.length % kRemindLength == 0 ||
        _remindWords.length >= length ||
        reachTarget;
  }

  List<Vocabulary> remindWords() {
    final reminds = _remindWords.toList();
    // _remindWords.clear();//Compiler will optimize all reference no any clone collection can be created
    return reminds;
  }

  void clearRemind() => _remindWords.clear();
  bool addRemind() {
    if (currentWord != null) {
      return _remindWords.add(currentWord!);
    }
    return false;
  }

  void nextStudyWord() {
    Future.delayed(Durations.extralong4, () {
      pageController.nextPage(
        duration: Durations.medium3,
        curve: Curves.easeInBack,
      );
    });
  }

  void _onAttach(ScrollPosition position) {
    final page = _studyWords.indexWhere((w) => w == currentWord);
    if (page > -1) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (position.haveDimensions) pageController.jumpToPage(page);
      });
    }
  }

  void _onError(Object e, [StackTrace? s]) {
    _completer.completeError(e, s);
    currentWord = null;
  }
}

Future<List<Vocabulary>> fetchWords(Iterable<int> wordIDs, {int? take}) async {
  // await Future.delayed(
  //   Durations.extralong4,
  //   () => throw Exception("fetch error"),
  // );
  final words = await compute(
    sortByRetention,
    await loadWordList(wordIDs).last,
  );
  return words.sublist(0, take?.clamp(0, words.length));
}

List<Vocabulary> sortByRetention(Iterable<Vocabulary> words) {
  return words.toList()
    ..sort((a, b) => calculateRetention(a).compareTo(calculateRetention(b)));
}

Future<Set<int>> sampleWordIds(Iterable<int> existIDs, final int count) async {
  final maxId = await getMaxId();
  final doneIDs = MyDB().fetchDoneWordIDs();
  final rng = Random();
  final wordIds = <int>{};
  // Set.of(MyDB().fetchUnknownWordIDs().take(count).toList()..shuffle());
  while (wordIds.length < count) {
    final id = rng.nextInt(maxId) + 1;
    if (doneIDs.contains(id) || existIDs.contains(id)) continue;
    wordIds.add(id);
  }
  return wordIds;
}

double calculateRetention(Vocabulary word) {
  final acquaint = word.acquaint;
  final lastLearnedTime = word.lastLearnedTime;
  if (acquaint == 0 || lastLearnedTime == null) return 0;
  final fib = fibonacci(acquaint);
  final inMinute =
      DateTime.now().millisecondsSinceEpoch ~/ 6e4 - lastLearnedTime;
  return forgettingCurve(inMinute / 1440, fib.toDouble());
}
