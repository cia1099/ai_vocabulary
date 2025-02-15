part of 'my_db.dart';

extension AcquaintDB on MyDB {
  void updateAcquaintance({
    required int wordId,
    required int acquaint,
    bool isCorrect = false,
  }) {
    final lastLearnedTime =
        !isCorrect ? null : DateTime.now().millisecondsSinceEpoch ~/ 6e4;
    final expression =
        'UPDATE acquaintances SET acquaint=?${isCorrect ? ',last_learned_time=?' : ''} WHERE acquaintances.word_id=?';
    final db = open(OpenMode.readWrite);
    db.execute(expression,
        [acquaint, lastLearnedTime, wordId]..removeWhere((e) => e == null));
    db.dispose();
    Future.microtask(notifyListeners); //I don't know why it has to use Future
  }

  Acquaintance getAcquaintance(int wordID) {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
        'SELECT * FROM acquaintances WHERE acquaintances.word_id = ?',
        [wordID]);
    final collects = resultSet.take(1).map((row) => Acquaintance.fromJson(row));
    db.dispose();
    return collects.firstOrNull ?? Acquaintance(wordId: wordID, acquaint: 0);
  }

  Iterable<int> fetchDoneWordIDs() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
        'SELECT word_id FROM acquaintances WHERE acquaintances.acquaint >= ?',
        [kMaxAcquaintance]);
    db.dispose();
    return resultSet.map((row) => row['word_id'] as int);
  }

  Iterable<int> fetchReviewWordIDs() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
        'SELECT word_id FROM acquaintances WHERE acquaint < ? AND last_learned_time IS NOT NULL',
        [kMaxAcquaintance]);
    db.dispose();
    return resultSet.map((row) => row['word_id'] as int);
  }

  Iterable<int> fetchUnknownWordIDs() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
        'SELECT word_id FROM acquaintances WHERE acquaintances.acquaint = ?',
        [0]);
    db.dispose();
    return resultSet.map((row) => row['word_id'] as int);
  }

  StudyCount fetchStudyCounts() {
    const query = '''
    SELECT 
      SUM(CASE WHEN acquaint <= 1 AND last_learned_time > ? THEN 1 ELSE 0 END) AS new_count,
      SUM(CASE WHEN acquaint > 1 AND last_learned_time > ? THEN 1 ELSE 0 END) AS review_count
    FROM acquaintances;
''';
    final db = open(OpenMode.readOnly);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final resultSet =
        db.select(query, List.filled(2, today.millisecondsSinceEpoch ~/ 6e4));
    db.dispose();
    return StudyCount.fromJson(resultSet.first);
  }

  Future<double?> get averageFibonacci async {
    await isReady;
    final db = open(OpenMode.readOnly);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 6e4;
    final resultSet = db.select(avgFib, [now, now]);
    db.dispose();
    return resultSet.firstOrNull?['avgFib'];
  }
}
