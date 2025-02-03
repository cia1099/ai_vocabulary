import 'dart:async';
import 'dart:math';

import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:im_charts/im_charts.dart';

import '../api/dict_api.dart';
import '../app_settings.dart';
import '../database/my_db.dart';
import '../model/vocabulary.dart';
import '../utils/regex.dart';

abstract class WordProvider {
  final _studyWords = <Vocabulary>[];
  final pageController = PageController();
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
  // reminder
  final _remindWords = <Vocabulary>{};
  bool shouldRemind() {
    if (currentWord != null) {
      _remindWords.add(currentWord!);
    }
    return _remindWords.isNotEmpty &&
            _remindWords.length % kRemindLength == 0 ||
        _remindWords.length >= length;
  }

  List<Vocabulary> remindWords() {
    final reminds = _remindWords.toList();
    _remindWords.clear();
    return reminds;
  }

  void nextStudyWord() {
    Future.delayed(Durations.extralong4, () {
      pageController.nextPage(
          duration: Durations.medium3, curve: Curves.easeInBack);
    });
    MyDB().notifyListeners();
  }
}

class RecommendProvider extends WordProvider {
  final BuildContext context;
  RecommendProvider({required this.context}) {
    fetchStudyWords(0).whenComplete(() {
      currentWord = _studyWords.firstOrNull;
      _completer.complete(true);
    }).onError(
        (e, _) => _completer.completeError(TimeoutException(e.toString())));
  }

  static const kMaxLength = 10;
  var _fetchTime = 0;
  Future<void> fetchStudyWords(int index) async {
    const initCount = 5;
    if (index % kMaxLength ~/ 2 != _fetchTime) return;
    _fetchTime = ++_fetchTime % 5;
    final count = _studyWords.length < kMaxLength && _fetchTime == 4
        ? 1
        : _studyWords.isNotEmpty
            ? 2
            : initCount;
    await MyDB().isReady;
    final reviewIDs = MyDB().fetchReviewWordIDs().toList();
    reviewIDs
        .removeWhere((id) => _studyWords.map((w) => w.wordId).contains(id));
    final requestIDs = await sampleWordIds(
        _studyWords.map((w) => w.wordId).toList() + reviewIDs, count);
    // print(
    //     'page = $index, fetchTime = $_fetchTime, sampleIDs = ${requestIDs.join(', ')}');
    // final words = await requestWords(requestIDs);
    final candidateWords = (await Future.wait(
            [requestWords(requestIDs), fetchWords(reviewIDs, take: count * 2)]))
        .reduce((a, b) => a + b);
    final fib = Fibonacci();
    final selector = WeightedSelector(candidateWords,
        candidateWords.map((w) => 1 - calculateRetention(w, fib)));
    final words = selector.sampleN(count);
    MyDB().insertWords(
        Stream.fromIterable(words.where((w) => requestIDs.contains(w.wordId))));

    if (_studyWords.length < kMaxLength) {
      _studyWords.addAll(words);
      if (context.mounted) AppSettings.of(context).notifyListeners();
    } else {
      final insertIndex = _fetchTime * 2;
      _studyWords.replaceRange(insertIndex, insertIndex + 2, words);
    }
  }
}

class ReviewProvider extends WordProvider {
  ReviewProvider() {
    fetchReviewWords()
        .onError((e, __) => _completer.completeError(e.toString()));
  }

  Future<void> fetchReviewWords() async {
    await MyDB().isReady;
    if (_completer.isCompleted) {
      _completer = Completer<bool>();
    }
    final reviewIDs = MyDB().fetchReviewWordIDs();
    final words = await fetchWords(reviewIDs);
    _studyWords
      ..clear()
      ..addAll(words);
    currentWord = _studyWords.firstOrNull;
    _completer.complete(true);
  }
}

Future<List<Vocabulary>> requestWords(Set<int> wordIds) async {
  var words = <Vocabulary>[];
  Exception? error = ApiException('initial');
  //errorID example: 1088
  while (error != null) {
    try {
      words = await getWords(wordIds);
      error = null;
    } on ApiException catch (e) {
      final errorIds = splitWords(e.message).expand((w) sync* {
        if (w.contains(RegExp(r'^-?\d+$'))) yield w;
      }).map((s) => int.parse(s));
      debugPrint('There is errorIDs: $errorIds in fetch dictionary API');
      wordIds.removeAll(errorIds);
      final resampleIDs = await sampleWordIds(wordIds, errorIds.length);
      wordIds.addAll(resampleIDs);
      error = e;
    }
  }
  // MyDB.instance.insertWords(Stream.fromIterable(words));
  return words;
}

Future<List<Vocabulary>> fetchWords(Iterable<int> wordIds, {int? take}) async {
  final words = await compute(sortByRetention, MyDB().fetchWords(wordIds));
  return words.sublist(0, take?.clamp(0, words.length));
}

List<Vocabulary> sortByRetention(Iterable<Vocabulary> words) {
  final fibonacci = Fibonacci();
  return words.toList()
    ..sort((a, b) => calculateRetention(a, fibonacci)
        .compareTo(calculateRetention(b, fibonacci)));
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

double calculateRetention(Vocabulary word, Fibonacci fibonacci) {
  final acquaint = word.acquaint;
  final lastLearnedTime = word.lastLearnedTime;
  if (acquaint == 0 || lastLearnedTime == null) return 0;
  final fib = fibonacci(acquaint);
  final inMinute =
      DateTime.now().millisecondsSinceEpoch ~/ 6e4 - lastLearnedTime;
  return forgettingCurve(inMinute / 1440, fib.toDouble());
}
