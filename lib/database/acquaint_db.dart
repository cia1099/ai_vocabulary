part of 'my_db.dart';

extension AcquaintDB on MyDB {
  void upsertAcquaintance({
    required final int wordId,
    required int acquaint,
    final bool isCorrect = false,
  }) {
    final learnedTime =
        !isCorrect ? null : DateTime.now().millisecondsSinceEpoch ~/ 6e4;
    final dbAcquaintance = getAcquaintance(wordId);
    final dt = (learnedTime ?? 0) - (dbAcquaintance.lastLearnedTime ?? 0);
    //Need review over 12 hours, the acquaint can be update at correctly
    // acquaint = !isCorrect || dt >= 60 * 12 ? acquaint : dbAcquaintance.acquaint;
    if (isCorrect && dt < 60 * 12) {
      acquaint = dbAcquaintance.acquaint;
    }

    final upsert = '''
INSERT INTO acquaintances (
acquaint, last_learned_time, word_id, user_id) VALUES (?, ?, ?, ?) 
ON CONFLICT (word_id, user_id) DO UPDATE SET acquaint=excluded.acquaint
${learnedTime != null ? ', last_learned_time=excluded.last_learned_time' : ''};
''';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    db.execute(upsert, [acquaint, learnedTime, wordId, userID]);
    db.dispose();
    writeToCloud(
      replacePlaceholders(upsert, [acquaint, learnedTime, wordId, userID]),
    );
    Future.microtask(notifyListeners); //I don't know why it has to use Future
  }

  Acquaintance getAcquaintance(final int wordID) {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
      'SELECT * FROM acquaintances WHERE word_id = ? AND user_id = ?',
      [wordID, UserProvider().currentUser?.uid],
    );
    final collects = resultSet.take(1).map((row) => Acquaintance.fromJson(row));
    db.dispose();
    return collects.firstOrNull ?? Acquaintance(wordId: wordID, acquaint: 0);
  }

  Iterable<int> fetchDoneWordIDs() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
      'SELECT word_id FROM acquaintances WHERE acquaintances.acquaint >= ? AND user_id=?',
      [kMaxAcquaintance, UserProvider().currentUser?.uid],
    );
    db.dispose();
    return resultSet.map((row) => row['word_id'] as int);
  }

  Iterable<int> fetchReviewWordIDs() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
      'SELECT word_id FROM acquaintances WHERE acquaint < ? AND last_learned_time IS NOT NULL AND user_id=?',
      [kMaxAcquaintance, UserProvider().currentUser?.uid],
    );
    db.dispose();
    return resultSet.map((row) => row['word_id'] as int);
  }

  Iterable<int> fetchUnknownWordIDs() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
      'SELECT word_id FROM acquaintances WHERE acquaintances.acquaint = ?',
      [0],
    );
    db.dispose();
    return resultSet.map((row) => row['word_id'] as int);
  }

  StudyCount fetchStudyCounts() {
    const query = '''
    SELECT 
      SUM(CASE WHEN acquaint <= 1 AND last_learned_time > ? THEN 1 ELSE 0 END) AS new_count,
      SUM(CASE WHEN acquaint > 1 AND last_learned_time > ? THEN 1 ELSE 0 END) AS review_count
    FROM acquaintances WHERE user_id = ?;
''';
    final db = open(OpenMode.readOnly);
    final today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    final resultSet = db.select(query, [
      ...List.filled(2, today.millisecondsSinceEpoch ~/ 6e4),
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
    return StudyCount.fromJson(resultSet.first);
  }

  Iterable<int> getTodayStudyWordIDs() {
    const query =
        'SELECT word_id FROM acquaintances WHERE last_learned_time > ? AND user_id=?';
    final db = open(OpenMode.readOnly);
    final today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    final resultSet = db.select(query, [
      today.millisecondsSinceEpoch ~/ 6e4,
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
    return resultSet.map((row) => row['word_id'] as int);
  }

  Future<double?> get averageFibonacci async {
    await isReady;
    final db = open(OpenMode.readOnly);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 6e4;
    final userID = UserProvider().currentUser?.uid;
    final resultSet = db.select(avgFib, [now, now, userID]);
    db.dispose();
    return resultSet.firstOrNull?['avgFib'];
  }
}
