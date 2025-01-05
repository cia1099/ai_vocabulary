part of 'my_db.dart';

extension CollectionDB on MyDB {
  Iterable<BookMark> fetchMarks() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select('SELECT * FROM collections');
    db.dispose();
    return resultSet.map((row) => CollectionMark.fromJson(row));
  }

  void insertCollection(String name, int index) {
    const expression = 'INSERT INTO collections (name, "index") VALUES (?, ?)';
    final db = open(OpenMode.readWrite);
    db.execute(expression, [name, index]);
    db.dispose();
  }

  void removeMark({required String name}) {
    const expression = 'DELETE FROM collections WHERE name=?';
    final db = open(OpenMode.readWrite);
    db.execute(expression, [name]);
    const removeRelative = 'DELETE FROM collect_words WHERE mark=?';
    db.execute(removeRelative, [name]);
    db.dispose();
  }

  bool renameMark({required String name, required String newName}) {
    final stmt = _updateExpression(['name']);
    final db = open(OpenMode.readWrite);
    bool isSuccess;
    try {
      db.execute(stmt, [newName, name]);
      isSuccess = true;
    } on SqliteException {
      isSuccess = false;
    }
    db.dispose();
    return isSuccess;
  }

  void editMark(
      {required String name, required int? icon, required int? color}) {
    final expression = _updateExpression(['icon', 'color']);
    final db = open(OpenMode.readWrite);
    db.execute(expression, [icon, color, name]);
    db.dispose();
  }

  void updateIndexes(Iterable<BookMark> marks) {
    final expression = _updateExpression(['"index"']);
    final db = open(OpenMode.readWrite);
    final stmt = db.prepare(expression);
    for (final mark in marks) {
      stmt.execute([mark.index, mark.name]);
    }
    stmt.dispose();
    db.dispose();
  }

  String _updateExpression(Iterable<String> argsName) {
    assert(argsName.isNotEmpty);
    const columnName = ['"index"', 'icon', 'color', 'name'];
    final posInput = argsName
        .where((e) => columnName.contains(e))
        .map((e) => '$e=?')
        .join(',');
    return 'UPDATE collections SET $posInput WHERE collections.name=?';
  }

  void addCollectWord(int wordID,
      {Iterable<String> marks = const ['uncategorized']}) {
    if (marks.isEmpty) return;
    const expression =
        'INSERT INTO collect_words (word_id, mark) VALUES (?, ?)';
    final db = open(OpenMode.readWrite);
    final stmt = db.prepare(expression);
    for (final mark in marks) {
      stmt.execute([wordID, mark]);
    }
    stmt.dispose();
    db.dispose();
    notifyListeners();
  }

  Iterable<IncludeWordMark> fetchMarksIncludeWord(int wordID) {
    const expression = '''
  WITH include_word AS (SELECT word_id AS word_id, mark AS mark 
  FROM collect_words WHERE collect_words.word_id = ?) 
  SELECT word_id, collections.name, collections."index" FROM include_word 
  FULL OUTER JOIN collections ON include_word.mark = collections.name 
  ORDER BY collections."index"
''';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(expression, [wordID]);
    db.dispose();
    return resultSet.map((row) => IncludeWordMark(
          name: row['name'] ?? 'uncategorized',
          included: row['word_id'] == wordID,
          index: row['index'],
        ));
  }

  void removeCollectWord(int wordID, {Iterable<String> marks = const []}) {
    if (marks.isEmpty) return;
    final expression = '''
    DELETE FROM collect_words 
    WHERE word_id=? AND mark IN (${marks.map((e) => '?').join(',')})
    ''';
    final db = open(OpenMode.readWrite);
    db.execute(expression, [wordID, ...marks]);
    db.dispose();
    notifyListeners();
  }

  bool hasCollectWord(int wordID) {
    const expression =
        'SELECT count(word_id) AS count_word FROM collect_words WHERE word_id=?';
    final db = open(OpenMode.readOnly);
    final result = db.select(expression, [wordID]);
    db.dispose();
    return result.first['count_word'] > 0;
  }
}
