part of 'my_db.dart';

extension AcquaintDB on MyDB {
  void updateAcquaintance({
    required int wordId,
    int? acquaint,
    bool? collect,
    String? bookmark,
  }) {
    final inputs = <dynamic>[acquaint, collect, bookmark];
    final posInput = List.generate(inputs.length, (i) {
      final input = inputs.elementAt(i);
      if (input == null) return input;
      switch (i) {
        case 0:
          return 'acquaint=?';
        case 1:
          return 'collect=?';
        case 2:
          return 'bookmark=?';
        default:
          return input;
      }
    }).expand((e) sync* {
      if (e != null) yield e;
    }).join(',');

    if (posInput.isEmpty) return;
    final expression =
        'UPDATE acquaintances SET $posInput WHERE acquaintances.word_id=?';
    final db = open(OpenMode.readWrite);
    db.execute(
        expression,
        inputs.expand((e) sync* {
              if (e != null) yield e;
            }).toList() +
            [wordId]);
    db.dispose();
  }

  Acquaintance getAcquaintance(int wordID) {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
        'SELECT * FROM acquaintances WHERE acquaintances.word_id = ?',
        [wordID]);
    final collects = resultSet.take(1).map((row) => Acquaintance.fromJson(row));
    db.dispose();
    return collects.first;
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
