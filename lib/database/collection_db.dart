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
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    db
      ..execute(expression, [id, name, index, userID])
      ..dispose();
    writeToCloud(replacePlaceholders(expression, [id, name, index, userID]));
  }

  void upsertCollection(CollectionMark mark) {
    const upsert = '''
    INSERT INTO collections (id, name, "index", color, icon, user_id)
    VALUES (?, ?, ?, ?, ?, ?)
    ON CONFLICT (id, user_id) DO UPDATE SET "index"=excluded."index", color=excluded.color, icon=excluded.icon
''';
    final userID = UserProvider().currentUser?.uid;
    final data = [
      mark.id,
      mark.name,
      mark.index,
      mark.color,
      mark.icon,
      userID,
    ];
    final db = open(OpenMode.readWrite);
    db
      ..execute(upsert, data)
      ..dispose();
    writeToCloud(replacePlaceholders(upsert, data));
  }

  void removeMark({required int id}) {
    const expression = 'DELETE FROM collections WHERE id=? AND user_id=?;';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    db.execute('PRAGMA foreign_keys = ON;');
    db.execute(expression, [id, userID]);
    db.dispose();
    // const removeRelative =
    //     'DELETE FROM collect_words WHERE collection_id=? AND user_id=?';
    // db
    //   ..execute(removeRelative, [id, userID])
    //   ..dispose();
    eraseCloud(replacePlaceholders(expression, [id, userID])).then((res) {
      if (res.status == 200) {
        // eraseCloud(replacePlaceholders(expression, [id, userID]));
      }
    }, onError: print);
  }

  bool renameMark({required int id, required String newName}) {
    final stmt = _updateExpression(['name']);
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    bool isSuccess;
    try {
      db.execute(stmt, [newName, id, userID]);
      writeToCloud(replacePlaceholders(stmt, [newName, id, userID]));
      isSuccess = true;
    } on SqliteException {
      isSuccess = false;
    }
    db.dispose();
    return isSuccess;
  }

  void updateIndexes(Iterable<BookMark> marks) {
    final expression = _updateExpression(['"index"']);
    final db = open(OpenMode.readWrite);
    final stmt = db.prepare(expression);
    final userID = UserProvider().currentUser?.uid;
    for (final mark in marks) {
      stmt.execute([mark.index, mark.id, userID]);
      writeToCloud(
        replacePlaceholders(expression, [mark.index, mark.id, userID]),
      );
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

  void addCollectWord(int wordID, {Iterable<int> markIDs = const [0]}) {
    if (markIDs.isEmpty) return;
    final userID = UserProvider().currentUser?.uid;
    final expression =
        '''
      INSERT INTO collect_words (word_id, user_id, collection_id)
      VALUES ${markIDs.map((id) => "($wordID,'$userID',$id)").join(',')}
      ON CONFLICT DO NOTHING;
    ''';
    final db = open(OpenMode.readWrite);
    db.execute(expression);
    db.dispose();
    writeToCloud(expression);
    notifyListeners();
  }

  void removeCollectWord(int wordID, {Iterable<int> markIDs = const []}) {
    if (markIDs.isEmpty) return;
    final expression =
        '''
    DELETE FROM collect_words 
    WHERE word_id=? AND user_id=? AND collection_id IN (${markIDs.map((id) => '?').join(',')})
    ''';
    final userID = UserProvider().currentUser?.uid;
    final db = open(OpenMode.readWrite);
    db
      ..execute(expression, [wordID, userID, ...markIDs])
      ..dispose();
    eraseCloud(replacePlaceholders(expression, [wordID, userID, ...markIDs]));
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

  Iterable<int> fetchWordIDsByMarkID(int markID) {
    const query =
        'SELECT word_id FROM collect_words WHERE collection_id=? AND user_id=?';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query, [
      markID,
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
    return resultSet.map((row) => row["word_id"] as int);
  }
}
