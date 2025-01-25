import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../api/dict_api.dart';
import '../database/my_db.dart';
import '../model/vocabulary.dart';
import '../utils/regex.dart';

class SliderProvider {
  SliderProvider({this.pageController}) {
    fetchStudyWords(0).whenComplete(() {
      currentWord = _studyWords.firstOrNull;
      _completer.complete();
    });
  }
  final PageController? pageController;
  final _studyWords = <Vocabulary>[];
  Vocabulary? _currentWord;
  final _providerState = StreamController<Vocabulary?>();
  late final _provider = _providerState.stream.asBroadcastStream();
  final _completer = Completer<void>();

  Future<void> initial() => _completer.future;

  Stream<Vocabulary?> get provideWord async* {
    yield _currentWord;
    yield* _provider;
  }

  set currentWord(Vocabulary? word) {
    _currentWord = word;
    _providerState.add(word);
  }

  // List<Vocabulary> get studyWords => _studyWords;
  int get length => _studyWords.length;
  Vocabulary operator [](int i) => _studyWords[i];
  Iterable<T> map<T>(T Function(Vocabulary) toElement) =>
      _studyWords.map(toElement);

  var _fetchTime = 0;
  Future<void> fetchStudyWords(int index) async {
    const kMaxLength = 10, initCount = 5;
    if (index % kMaxLength ~/ 2 != _fetchTime) return;
    _fetchTime = ++_fetchTime % 5;
    final count = _studyWords.length < kMaxLength && _fetchTime == 4
        ? 1
        : _studyWords.isNotEmpty
            ? 2
            : initCount;
    final wordIDs =
        await sampleWordIds(_studyWords.map((w) => w.wordId), count);
    print(
        'page = $index, fetchTime = $_fetchTime, sampleIDs = ${wordIDs.join(', ')}');
    final words = await requestWords(wordIDs);
    if (_studyWords.length < kMaxLength) {
      _studyWords.addAll(words);
    } else {
      final insertIndex = _fetchTime * 2;
      _studyWords.replaceRange(insertIndex, insertIndex + 2, words);
    }
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
