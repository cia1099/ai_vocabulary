part of 'my_db.dart';

extension CollectionDB on MyDB {
  Iterable<BookMark> fetchMarks() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select('SELECT * FROM collections WHERE user_id=?', [
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
    return resultSet.map((row) => CollectionMark.fromJson(row));
  }

  void insertCollection(String name, int index) {
    const expression =
        'INSERT INTO collections (name, "index", user_id) VALUES (?, ?, ?)';
    final db = open(OpenMode.readWrite);
    db
      ..execute(expression, [name, index, UserProvider().currentUser?.uid])
      ..dispose();
  }

  void removeMark({required String name}) {
    const expression = 'DELETE FROM collections WHERE name=? AND user_id=?';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    db.execute(expression, [name, userID]);
    const removeRelative =
        'DELETE FROM collect_words WHERE mark=? AND user_id=?';
    db
      ..execute(removeRelative, [name, userID])
      ..dispose();
  }

  bool renameMark({required String name, required String newName}) {
    final stmt = _updateExpression(['name']);
    final db = open(OpenMode.readWrite);
    bool isSuccess;
    try {
      db.execute(stmt, [newName, name, UserProvider().currentUser?.uid]);
      isSuccess = true;
    } on SqliteException {
      isSuccess = false;
    }
    db.dispose();
    return isSuccess;
  }

  void editMark({
    required String name,
    required int? icon,
    required int? color,
  }) {
    final expression = _updateExpression(['icon', 'color']);
    final db = open(OpenMode.readWrite);
    db
      ..execute(expression, [
        icon,
        color,
        name,
        UserProvider().currentUser?.uid,
      ])
      ..dispose();
  }

  void updateIndexes(Iterable<BookMark> marks) {
    final expression = _updateExpression(['"index"']);
    final db = open(OpenMode.readWrite);
    final stmt = db.prepare(expression);
    final userID = UserProvider().currentUser?.uid;
    for (final mark in marks) {
      stmt.execute([mark.index, mark.name, userID]);
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
    return 'UPDATE collections SET $posInput WHERE name=? AND user_id=?';
  }

  void addCollectWord(
    int wordID, {
    Iterable<String> marks = const [kUncategorizedName],
  }) {
    if (marks.isEmpty) return;
    const expression =
        'INSERT INTO collect_words (word_id, mark, user_id) VALUES (?, ?,?)';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    final stmt = db.prepare(expression);
    for (final mark in marks) {
      stmt.execute([wordID, mark, userID]);
    }
    stmt.dispose();
    db.dispose();
    notifyListeners();
  }

  Iterable<IncludeWordMark> fetchMarksIncludeWord(int wordID) {
    const expression = '''
  WITH bookmarks AS (SELECT name, "index" AS idx
  FROM collections WHERE user_id = ?),
  include_word AS (SELECT word_id, mark
  FROM collect_words WHERE user_id=? AND word_id=?)
  SELECT word_id, name FROM bookmarks
  FULL JOIN include_word ON include_word.mark = bookmarks.name
  ORDER BY COALESCE(idx, -1)
''';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(expression, [userID, userID, wordID]);
    db.dispose();
    return resultSet.map(
      (row) => IncludeWordMark(
        name: row['name'] ?? kUncategorizedName,
        included: row['word_id'] == wordID,
      ),
    );
  }

  void removeCollectWord(int wordID, {Iterable<String> marks = const []}) {
    if (marks.isEmpty) return;
    final expression = '''
    DELETE FROM collect_words 
    WHERE word_id=? AND user_id=? AND mark IN (${marks.map((e) => '?').join(',')})
    ''';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    db
      ..execute(expression, [wordID, userID, ...marks])
      ..dispose();
    notifyListeners();
  }

  bool hasCollectWord(int wordID) {
    const expression =
        'SELECT count(word_id) AS count_word FROM collect_words WHERE word_id=? AND user_id=?';
    final db = open(OpenMode.readOnly);
    final result = db.select(expression, [
      wordID,
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
    return result.first['count_word'] > 0;
  }

  Iterable<Vocabulary> fetchWordsFromMark(String mark) {
    const query =
        '$fetchWordInID (SELECT word_id FROM collect_words WHERE mark=? AND user_id=?)';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query, [mark, UserProvider().currentUser?.uid]);
    final wordMaps = buildWordMaps(resultSet);
    db.dispose();
    return wordMaps.map((json) => Vocabulary.fromJson(json)).toList();
  }
}
