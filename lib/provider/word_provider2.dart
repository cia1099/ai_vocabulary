part of 'word_provider.dart';

class RecommendProvider extends WordProvider {
  final BuildContext context;
  RecommendProvider({required this.context}) {
    fetchStudyWords().onError(_onError).whenComplete(() {
      // currentWord = _studyWords.firstOrNull;
      if (!_completer.isCompleted) {
        _completer.complete(true);
      }
    });
  }

  static const kMaxLength = 16;
  Future<void> fetchStudyWords() async {
    await MyDB().isReady;
    final reviewIDs = MyDB().fetchReviewWordIDs();
    final existIDs = _studyWords.map((w) => w.wordId).followedBy(reviewIDs);
    const count = kMaxLength;
    final requestIDs = await sampleWordIds(existIDs, count);

    // throw Exception('error happen');
    final undoneReview =
        context.mounted &&
        AppSettings.of(context).studyState != StudyStatus.completedReview;
    _studyWords.clear();
    final candidateWords = (await Future.wait([
      requestWords(requestIDs),
      if (undoneReview)
        compute(
          sortByRetention,
          MyDB().fetchWords(
            reviewIDs.where(
              (id) => !_studyWords.any((word) => word.wordId == id),
            ),
          ),
        ).then((list) => list.take(count * 2).toList()),
    ])).reduce((a, b) => a + b);
    final selector = WeightedSelector(
      candidateWords,
      candidateWords.map((w) => 1 - calculateRetention(w)),
    );
    final words = selector.sampleN(count);
    _studyWords.addAll(words);
    currentWord = _studyWords.firstOrNull;

    if (_completer.isCompleted) MyDB().notifyListeners();
  }
}

class ReviewProvider extends WordProvider {
  final Iterable<int>? reviewIDs;
  ReviewProvider([this.reviewIDs]) {
    fetchReviewWords().onError(_onError).whenComplete(() {
      // currentWord = _studyWords.firstOrNull;
      if (!_completer.isCompleted) {
        _completer.complete(true);
      }
    });
  }

  Future<void> fetchReviewWords() async {
    await MyDB().isReady;
    final requireIDs = reviewIDs ?? MyDB().fetchReviewWordIDs();
    _studyWords.clear();
    final words = await fetchWords(requireIDs);
    _studyWords.addAll(words);
    currentWord = _studyWords.firstOrNull;
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

mixin OldFetch on RecommendProvider {
  final _stepCount =
      RecommendProvider.kMaxLength ~/ 4; //must be divide to kMaxLength
  var _fetchTime = 0;

  Future<void> oldFetchStudyWords(int index, {bool isReset = false}) async {
    final initCount = 2 * _stepCount; //at least leader double step
    final kMaxLength = RecommendProvider.kMaxLength;
    if (index % kMaxLength ~/ _stepCount != _fetchTime) return;
    final fetchTime = (_fetchTime + 1) % (kMaxLength ~/ _stepCount);
    if (fetchTime == 0) return;
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
          MyDB().fetchWords(
            reviewIDs.where(
              (id) => !_studyWords.any((word) => word.wordId == id),
            ),
          ),
        ).then((list) => list.take(count * 2).toList()),
    ])).reduce((a, b) => a + b);
    final selector = WeightedSelector(
      candidateWords,
      candidateWords.map((w) => 1 - calculateRetention(w)),
    );
    final words = selector.sampleN(count);
    // MyDB().insertWords(
    //   Stream.fromIterable(words.where((w) => requestIDs.contains(w.wordId))),
    // );//Not necessary because loadWordList in fetchWord will write to database
    if (isReset) _studyWords.clear();

    if (_studyWords.length < kMaxLength) {
      _studyWords.addAll(words);
      if (_completer.isCompleted) MyDB().notifyListeners();
    }
    // else {
    //   final insertIndex = fetchTime * _stepCount;
    //   _studyWords.replaceRange(insertIndex, insertIndex + count, words);
    // }
    //when request successfully, update _fetchTime
    _fetchTime = fetchTime;
  }

  Future<void> resetWords() async {
    if (!_completer.isCompleted) return;
    _fetchTime = 0;
    await oldFetchStudyWords(0, isReset: true);
    currentWord = _studyWords.firstOrNull;
    if (!await isReady.onError((_, _) => false)) {
      //reset _completer to rebuild FutureBuilder to replace initialized error
      _completer = Completer<bool>()..complete(true);
    }
  }

  Future<void> bottomRequest() async {
    return oldFetchStudyWords(_fetchTime * _stepCount);
  }
}
