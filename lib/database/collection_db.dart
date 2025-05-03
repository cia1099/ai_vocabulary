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

  void insertCollection(int id, String name, int index) {
    const expression =
        'INSERT INTO collections (id,name, "index", user_id) VALUES (?,?, ?, ?)';
    final db = open(OpenMode.readWrite);
    db
      ..execute(expression, [id, name, index, UserProvider().currentUser?.uid])
      ..dispose();
  }

  void removeMark({required int id}) {
    const expression = 'DELETE FROM collections WHERE id=? AND user_id=?';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    db.execute(expression, [id, userID]);
    const removeRelative =
        'DELETE FROM collect_words WHERE collection_id=? AND user_id=?';
    db
      ..execute(removeRelative, [id, userID])
      ..dispose();
  }

  bool renameMark({required int id, required String newName}) {
    final stmt = _updateExpression(['name']);
    final db = open(OpenMode.readWrite);
    bool isSuccess;
    try {
      db.execute(stmt, [newName, id, UserProvider().currentUser?.uid]);
      isSuccess = true;
    } on SqliteException {
      isSuccess = false;
    }
    db.dispose();
    return isSuccess;
  }

  void editMark({required int id, required int? icon, required int? color}) {
    final expression = _updateExpression(['icon', 'color']);
    final db = open(OpenMode.readWrite);
    db
      ..execute(expression, [icon, color, id, UserProvider().currentUser?.uid])
      ..dispose();
  }

  void updateIndexes(Iterable<BookMark> marks) {
    final expression = _updateExpression(['"index"']);
    final db = open(OpenMode.readWrite);
    final stmt = db.prepare(expression);
    final userID = UserProvider().currentUser?.uid;
    for (final mark in marks) {
      stmt.execute([mark.index, mark.id, userID]);
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
    return 'UPDATE collections SET $posInput WHERE id=? AND user_id=?';
  }

  void addCollectWord(int wordID, {Iterable<int> markIDs = const [0]}) {
    if (markIDs.isEmpty) return;
    final userID = UserProvider().currentUser?.uid;
    final expression = '''
      INSERT INTO collect_words (word_id, user_id, collection_id)
      VALUES ${markIDs.map((id) => '($wordID,"$userID",$id)').join(',')};
    ''';
    final db = open(OpenMode.readWrite);
    db.execute(expression);
    db.dispose();
    notifyListeners();
  }

  Iterable<IncludeWordMark> fetchMarksIncludeWord(int wordID) {
    const expression = '''
  WITH bookmarks AS (SELECT name, "index" AS idx, id
  FROM collections WHERE user_id = ?),
  include_word AS (SELECT word_id, collection_id AS id
  FROM collect_words WHERE user_id=? AND word_id=?)
  SELECT word_id, name, bookmarks.id FROM bookmarks
  FULL JOIN include_word ON include_word.id = bookmarks.id
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
        id: row['id'] ?? 0,
      ),
    );
  }

  void removeCollectWord(int wordID, {Iterable<int> markIDs = const []}) {
    if (markIDs.isEmpty) return;
    final expression = '''
    DELETE FROM collect_words 
    WHERE word_id=? AND user_id=? AND collection_id IN (${markIDs.map((id) => '?').join(',')})
    ''';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    db
      ..execute(expression, [wordID, userID, ...markIDs])
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

  Iterable<Vocabulary> fetchWordsFromMarkID(int markID) {
    const query =
        '$fetchWordInID (SELECT word_id FROM collect_words WHERE collection_id=? AND user_id=?)';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query, [
      markID,
      UserProvider().currentUser?.uid,
    ]);
    final wordMaps = buildWordMaps(resultSet);
    db.dispose();
    return wordMaps.map((json) => Vocabulary.fromJson(json)).toList();
  }
}
