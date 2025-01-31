import 'dart:async';
import 'dart:math';

import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/material.dart';

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
  final _completer = Completer<bool>();

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
    final wordIDs =
        await sampleWordIds(_studyWords.map((w) => w.wordId), count);
    // print(
    //     'page = $index, fetchTime = $_fetchTime, sampleIDs = ${wordIDs.join(', ')}');
    final words = await requestWords(wordIDs);
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
    fetchReviewWords().whenComplete(() {
      _completer.complete(true);
    }).onError((e, __) => _completer.completeError(e.toString()));
  }

  Future<void> fetchReviewWords() async {
    await MyDB().isReady;
    final reviewIDs = MyDB().fetchReviewWordIDs();
    final words = MyDB().fetchWords(reviewIDs);
    _studyWords.addAll(words);
    currentWord = _studyWords.firstOrNull;
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
  return words;
}

Future<Set<int>> sampleWordIds(Iterable<int> reviewIDs, final int count) async {
  final maxId = await getMaxId();
  final doneIDs = MyDB().fetchDoneWordIDs();
  final rng = Random();
  final wordIds = <int>{};
  // Set.of(MyDB().fetchUnknownWordIDs().take(count).toList()..shuffle());
  while (wordIds.length < count) {
    final id = rng.nextInt(maxId) + 1;
    if (doneIDs.contains(id) || reviewIDs.contains(id)) continue;
    wordIds.add(id);
  }
  return wordIds;
}
