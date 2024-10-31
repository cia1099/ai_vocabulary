import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/regex.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:path_provider/path_provider.dart';

class WordProvider {
  final _studyWords = <Vocabulary>[];
  // final _wordIds = <int>{}; //<int>{15508} //used for debug;
  Vocabulary? _currentWord;
  final _providerState = StreamController<Vocabulary?>();
  late final _provider = _providerState.stream.asBroadcastStream();
  var studyCount = 20, _learnedIndex = 0;
  var appDirectory = '';
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

  Future<void> _init() async {
    final file = File(p.join(appDirectory, fileName));
    if (shouldResample(file)) {
      final wordIds = await _sampleWordIds({}, studyCount);
      await requestWords(wordIds);
      final now = DateTime.now();
      final dateTime =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
      await file.writeAsString(
          json.encode({'dateTime': dateTime, 'wordIds': wordIds.toList()}));
    } else {
      final wordIds = json.decode(file.readAsStringSync())['wordIds'];
      print(
          'local wordId: ${wordIds.map((e) => '\x1b[32m$e\x1b[0m').join(', ')}');
    }
  }

  Future<Set<int>> _sampleWordIds(Set<int> wordIds, final int count) async {
    final maxId = await getMaxId();
    final rng = Random();
    while (wordIds.length < count) {
      wordIds.add(rng.nextInt(maxId) + 1);
    }
    return wordIds;
  }

  bool shouldResample(final File file) {
    if (!file.existsSync()) return true;
    final obj = json.decode(file.readAsStringSync());
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now - obj['dateTime'] >= 86400;
  }

  Future<void> requestWords(Set<int> wordIds) async {
    Exception? error = ApiException('initial');
    while (error != null) {
      try {
        final words = await getWords(wordIds);
        error = null;
        _studyWords.clear();
        _learnedIndex = _studyWords.length;
        _studyWords.addAll(words);
        popWord();
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
  }

  Vocabulary? popWord([int? index]) {
    // if (_learnedIndex > _studyWords.length) _learnedIndex = 0;
    final word = _studyWords.elementAtOrNull(index ?? _learnedIndex);
    if (index == null) {
      _learnedIndex = min(_learnedIndex + 1, _studyWords.length);
      _currentWord = word;
      _providerState.add(_currentWord);
    }
    return word;
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
      provider.popWord();
    }
  }

  for (int i = 0; i < 5; i++) {
    // await Future.delayed(const Duration(milliseconds: 500));
    // final word = provider.popWord();
    // print('$idx:\x1b[32m${word?.word}\x1b[0m shit');
    print('don\'t print this shit');
  }
  stream.cancel();

  // final message = 'word@[15508, 20] not found';
  // final split = splitWords(message).expand((w) sync* {
  //   if (w.contains(RegExp(r'^-?\d+$'))) yield w;
  // }).map((s) => int.parse(s));
  // print(split);
}
