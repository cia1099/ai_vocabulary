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
    if (currentWord != null) {
      _remindWords.add(currentWord!);
    }
    return _remindWords.isNotEmpty &&
            _remindWords.length % kRemindLength == 0 ||
        _remindWords.length >= length ||
        reachTarget;
  }

  List<Vocabulary> remindWords() {
    final reminds = _remindWords.toList();
    _remindWords.clear();
    return reminds;
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
}

class RecommendProvider extends WordProvider {
  final BuildContext context;
  RecommendProvider({required this.context}) {
    fetchStudyWords(0).onError(_completer.completeError).whenComplete(() {
      currentWord = _studyWords.firstOrNull;
      if (!_completer.isCompleted) {
        _completer.complete(true);
      }
    });
  }

  static const kMaxLength = 10;
  final _stepCount = kMaxLength ~/ 5;
  var _fetchTime = 0;
  Future<void> fetchStudyWords(int index, {bool isReset = false}) async {
    const initCount = 5;
    if (index % kMaxLength ~/ _stepCount != _fetchTime) return;
    final fetchTime = (_fetchTime + 1) % (kMaxLength ~/ _stepCount);
    final count = _studyWords.isEmpty || isReset
        ? initCount
        : _studyWords.length < kMaxLength
        ? (kMaxLength - _studyWords.length).clamp(0, _stepCount)
        : _stepCount;
    await MyDB().isReady;
    final reviewIDs = MyDB().fetchReviewWordIDs();
    final existIDs = _studyWords.map((w) => w.wordId).followedBy(reviewIDs);
    final requestIDs = await sampleWordIds(existIDs, count);
    // print(
    //   'page = $index, fetchTime = $fetchTime, sampleIDs = ${requestIDs.join(', ')}',
    // );
    // if (!_completer.isCompleted)
    //   await Future.delayed(
    //     Duration(seconds: 1),
    //     () => throw Exception('error happen'),
    //   );
    final undoneReview =
        context.mounted &&
        AppSettings.of(context).studyState != StudyStatus.completedReview;
    final candidateWords = (await Future.wait([
      requestWords(requestIDs),
      if (undoneReview)
        //fetchWords(reviewIDs, take: count * 2),
        compute(
          sortByRetention,
          MyDB().fetchWords(reviewIDs),
        ).then((list) => list.take(count * 2).toList()),
    ])).reduce((a, b) => a + b);
    final selector = WeightedSelector(
      candidateWords,
      candidateWords.map((w) => 1 - calculateRetention(w)),
    );
    final words = selector.sampleN(count);
    MyDB().insertWords(
      Stream.fromIterable(words.where((w) => requestIDs.contains(w.wordId))),
    );
    if (isReset) _studyWords.clear();

    if (_studyWords.length < kMaxLength) {
      _studyWords.addAll(words);
      if (_completer.isCompleted) MyDB().notifyListeners();
    } else {
      final insertIndex = fetchTime * _stepCount;
      _studyWords.replaceRange(insertIndex, insertIndex + count, words);
    }
    //when request successfully, update _fetchTime
    _fetchTime = fetchTime;
  }

  Future<void> resetWords() async {
    if (!_completer.isCompleted) return;
    _fetchTime = 0;
    await fetchStudyWords(0, isReset: true);
    // currentWord = _studyWords.firstOrNull; //PageView itemBuilder has set currentWord
    if (!await isReady.onError((_, _) => false)) {
      //reset _completer to rebuild FutureBuilder to replace initialized error
      _completer = Completer<bool>()..complete(true);
    }
  }

  Future<void> bottomRequest() async {
    return fetchStudyWords(_fetchTime * _stepCount);
  }
}

class ReviewProvider extends WordProvider {
  final Iterable<int>? reviewIDs;
  ReviewProvider([this.reviewIDs]) {
    fetchReviewWords().onError(_completer.completeError).whenComplete(() {
      if (!_completer.isCompleted) {
        _completer.complete(true);
      }
    });
  }

  Future<void> fetchReviewWords() async {
    await MyDB().isReady;
    final requireIDs = reviewIDs ?? MyDB().fetchReviewWordIDs();
    final words = await fetchWords(requireIDs);
    _studyWords
      ..clear()
      ..addAll(words);
    // currentWord = _studyWords.firstOrNull; //PageView itemBuilder has set currentWord
    if (_completer.isCompleted && !await isReady.onError((_, _) => false)) {
      //reset initialized error
      _completer = Completer<bool>()..complete(true);
    }
  }
}

Future<List<Vocabulary>> requestWords(Set<int> wordIds) async {
  var words = <Vocabulary>[];
  Object? error = ApiException('initial');
  //errorID example: 1088
  while (error is ApiException) {
    try {
      words = await getWords(wordIds);
      error = null;
    } on ApiException catch (e) {
      final errorIds = splitWords(e.message)
          .expand((w) sync* {
            if (w.contains(RegExp(r'^-?\d+$'))) yield w;
          })
          .map((s) => int.parse(s));
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
