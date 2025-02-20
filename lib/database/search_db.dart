part of 'my_db.dart';

extension SearchDB on MyDB {
  List<Vocabulary> fetchHistorySearches() {
    const historyCTE = '''WITH historyCTE AS ($fetchWordInID
  (SELECT word_id FROM history_searches ORDER BY time_stamp DESC LIMIT 100)
)''';
    const query = """$historyCTE
SELECT * FROM historyCTE hCTE JOIN history_searches hs ON hCTE.id = hs.word_id
ORDER BY hs.time_stamp DESC;
""";
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query);
    final wordMaps = buildWordMaps(resultSet);
    db.dispose();
    return wordMaps.map((json) => Vocabulary.fromJson(json)).toList();
  }

  void insertSearchHistory(int wordID) {
    const insert =
        'INSERT INTO history_searches (time_stamp, word_id) VALUES (?, ?)';
    final db = open(OpenMode.readWrite);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1e3;
    try {
      db.execute(insert, [now, wordID]);
    } on SqliteException catch (e) {
      debugPrint('SQL error(${e.resultCode}): ${e.message}=($wordID)');
      const update = 'UPDATE history_searches SET time_stamp=? WHERE word_id=?';
      db.execute(update, [now, wordID]);
    }
    db.dispose();
  }

  void updateHistory(int wordID) {
    const update = 'UPDATE history_searches SET time_stamp=? WHERE word_id=?';
    final db = open(OpenMode.readWrite);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1e3;
    db
      ..execute(update, [now, wordID])
      ..dispose();
  }
}
