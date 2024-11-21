import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/regex.dart';
// import 'package:path_provider/path_provider.dart';

class WordProvider {
  final _studyWords = <Vocabulary>[];
  // final _wordIds = <int>{}; //<int>{15508} //used for debug;
  Vocabulary? _currentWord;
  final _providerState = StreamController<Vocabulary?>();
  late final _provider = _providerState.stream.asBroadcastStream();
  late final StreamSubscription _subscript;
  var studyCount = 25, _learnedIndex = 0;
  final fileName = 'today.json';

  static WordProvider? _instance;
  WordProvider._internal() {
    _init();
  }
  static WordProvider get instance => _instance ??= WordProvider._internal();
  factory WordProvider() => instance;
  Stream<Vocabulary?> get provideWord async* {
    yield _currentWord;
    yield* _provider;
  }

  Vocabulary? get currentWord => _currentWord;
  String get studyProgress => '$_learnedIndex/$studyCount';

  Future<void> _init() async {
    late final String appDirectory;
    try {
      appDirectory = MyDB().appDirectory;
    } on Error {
      appDirectory = await MyDB().futureAppDirectory;
    }
    var wordIds = <int>[];
    final file = File(p.join(appDirectory, fileName));
    if (shouldResample(file)) {
      final setIds = await _sampleWordIds({}, studyCount);
      final words = await requestWords(setIds);
      _studyWords.addAll(words);
      wordIds = setIds.toList();
      final now = DateTime.now();
      final dateTime =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
      await file.writeAsString(json.encode({
        'dateTime': dateTime,
        'learnedIndex': _learnedIndex,
        'wordIds': wordIds.toList()
      }));
      MyDB.instance.insertWords(Stream.fromIterable(words));
    } else {
      final today =
          json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      _learnedIndex = today['learnedIndex'] ?? 0;
      final todayIDs = today['wordIds'];
      wordIds = List<int>.from(todayIDs);
      final words = MyDB.instance.fetchWords(wordIds);
      _studyWords.addAll(words);
      // _mappingWordId(wordIds);
      // print(
      //     'local wordId: ${wordIds.map((e) => '\x1b[32m$e\x1b[0m').join(', ')}');
      // print(
      //     'retieval wordId: ${_studyWords.map((w) => '\x1b[31m${w.wordId}\x1b[0m').join(', ')}');
    }
    _subscript = _provider.listen(
      (_) => file.readAsString().then((jstr) {
        final fobj = json.decode(jstr);
        fobj['learnedIndex'] = _learnedIndex;
        file.writeAsString(json.encode(fobj));
      }),
      onDone: () => print("only read = $_learnedIndex"),
    );
    _mappingWordId(wordIds);
    nextStudyWord(_learnedIndex);
  }

  void dispose() {
    _studyWords.clear();
    _subscript.cancel();
    _providerState.close();
  }

  Future<Set<int>> _sampleWordIds(Set<int> wordIds, final int count) async {
    final maxId = await getMaxId();
    final doneIDs = MyDB().fetchDoneWords();
    final rng = Random();
    while (wordIds.length < count) {
      final id = rng.nextInt(maxId) + 1;
      if (doneIDs.contains(id)) continue;
      wordIds.add(id);
    }
    return wordIds;
  }

  void _mappingWordId(List<int> wordIds) {
    assert(_studyWords.length == wordIds.length,
        'The length of _studyWords must equal to wordIds');
    for (var i = 0, j = _studyWords.length - 1; i < j;) {
      final word = _studyWords[i];
      final idx = wordIds.indexOf(word.wordId, i);
      if (idx == i || idx < 0)
        i++;
      else {
        _studyWords[i] = _studyWords[idx];
        _studyWords[idx] = word;
      }
      while (_studyWords[j].wordId == wordIds[j] && j > i) j--;
    }
  }

  bool shouldResample(final File file) {
    if (!file.existsSync()) return true;
    final obj = json.decode(file.readAsStringSync());
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now - obj['dateTime'] >= 86400;
  }

  Future<List<Vocabulary>> requestWords(Set<int> wordIds) async {
    var words = <Vocabulary>[];
    Exception? error = ApiException('initial');
    while (error != null) {
      try {
        words = await getWords(wordIds);
        error = null;
      } on ApiException catch (e) {
        final errorIds = splitWords(e.message).expand((w) sync* {
          if (w.contains(RegExp(r'^-?\d+$'))) yield w;
        }).map((s) => int.parse(s));
        print(errorIds);
        wordIds.removeAll(errorIds);
        wordIds = await _sampleWordIds(wordIds, studyCount);
        error = e;
      }
    }
    return words;
  }

  void nextStudyWord([int? index]) {
    if (index == null) {
      _learnedIndex = min(_learnedIndex + 1, _studyWords.length);
    }
    final word = _studyWords.elementAtOrNull(index ?? _learnedIndex);
    _currentWord = word;
    _providerState.add(word);
    if (_studyWords.isNotEmpty) {
      if (_learnedIndex == _studyWords.length) {
        Future.delayed(Durations.extralong4, () => _subscript.pause());
      } else {
        _subscript.resume();
      }
    }
  }
}

void main() async {
  final provider = WordProvider();
  var idx = 1;
  final stream = provider.provideWord
      .listen((word) => print('$idx:\x1b[43m${word?.word}\x1b[0m'));
  await for (final w in provider.provideWord) {
    if (w != null || idx > 20) {
      print('${idx++}:\x1b[32m${w?.word}\x1b[0m');
    } else {
      print('waiting for initialization...');
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (idx <= 24) {
      provider.nextStudyWord();
    }
  }

  for (int i = 0; i < 5; i++) {
    await Future.delayed(const Duration(milliseconds: 500));
    // final word = provider.popWord();
    // print('$idx:\x1b[32m${word?.word}\x1b[0m shit');
    print('don\'t print this shit main');
  }
  stream.cancel();
  provider.dispose();

  // final message = 'word@[15508, 20] not found';
  // final split = splitWords(message).expand((w) sync* {
  //   if (w.contains(RegExp(r'^-?\d+$'))) yield w;
  // }).map((s) => int.parse(s));
  // print(split);
}
