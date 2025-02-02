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
    // Future.microtask(notifyListeners); //I don't know why it has to use Future
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
        'SELECT word_id FROM acquaintances WHERE acquaint < ? AND acquaint > ?',
        [kMaxAcquaintance, 0]);
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
}
