part of 'word_provider.dart';

extension PublicWordProvider on WordProvider {
  void nextStudyWord([int? index]) {
    if (index == null) {
      _learnedIndex = min(_learnedIndex + 1, _studyWords.length);
    }
    final word = _studyWords.elementAtOrNull(index ?? _learnedIndex);
    _currentWord = word;
    _providerState.add(word);
    if (word != null) {
      _remindIDs.add(word.wordId);
    }
    if (_studyWords.isNotEmpty) {
      if (_learnedIndex == _studyWords.length) {
        Future.delayed(Durations.extralong4, () => _subscript.pause());
      } else {
        _subscript.resume();
      }
    }
  }

  bool shouldRemind() {
    return _remindIDs.isNotEmpty && _remindIDs.length % kRemindLength == 0 ||
        _learnedIndex == _studyWords.length - 1 ||
        _learnedIndex == reviewCount - 1;
  }

  List<Vocabulary> remindWords() {
    final reminds =
        _studyWords.where((w) => _remindIDs.contains(w.wordId)).toList();
    _remindIDs.clear();
    return reminds;
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
        final resampleIDs = await _sampleWordIds(wordIds, errorIds.length);
        wordIds.addAll(resampleIDs);
        error = e;
      }
    }
    return words;
  }

  List<Vocabulary> subList([int start = 0, int? end]) {
    return _studyWords.sublist(start, end);
  }
}
