import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/regex.dart';
// import 'package:flutter/cupertino.dart';

class WordProvider {
  final _studyWords = <Vocabulary>[];
  final _wordIds = <int>{}; //<int>{15508} //used for debug;
  Vocabulary? _currentWord;
  final _providerState = StreamController<Vocabulary?>();
  late final _provider = _providerState.stream.asBroadcastStream();
  var studyCount = 20, _learnedIndex = 0;

  static WordProvider? _instance;
  WordProvider._internal() {
    _init().then((_) => requestWords());
  }
  static WordProvider get instance => _instance ??= WordProvider._internal();
  factory WordProvider() => instance;

  Future<void> _init() async {
    final maxId = await getMaxId();
    final rng = Random();
    while (_wordIds.length < studyCount) {
      _wordIds.add(rng.nextInt(maxId) + 1);
    }
  }

  Future<void> requestWords() async {
    Exception? error = ApiException('initial');
    while (error != null) {
      try {
        final words = await getWords(_wordIds);
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
        _wordIds.removeAll(errorIds);
        await _init();
        error = e;
      }
    }
  }

  Stream<Vocabulary?> get provideWord async* {
    yield _currentWord;
    yield* _provider;
  }

  Vocabulary? popWord([int? index]) {
    // if (_learnedIndex > _studyWords.length) _learnedIndex = 0;
    final word = _studyWords.elementAtOrNull(index ?? _learnedIndex++);
    if (index == null) {
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
