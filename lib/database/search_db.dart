part of 'my_db.dart';

extension SearchDB on MyDB {
  List<Vocabulary> fetchHistorySearches() {
    const historyCTE = '''WITH historyCTE AS ($fetchWordInID
  (SELECT word_id FROM history_searches ORDER BY time_stamp DESC LIMIT 100)
)''';
    const query = """$historyCTE
SELECT * FROM historyCTE hCTE JOIN history_searches hs ON hCTE.word_id = hs.word_id
ORDER BY hs.time_stamp DESC;
""";
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query);
    final wordMaps = buildWordMaps(resultSet);
    db.dispose();
    return wordMaps.map((json) => Vocabulary.fromJson(json)).toList();
  }

  void upsertSearchHistory(int wordID) {
    const upsert = '''
INSERT INTO history_searches (time_stamp, word_id) VALUES (?, ?)
ON CONFLICT(word_id) DO UPDATE SET time_stamp=excluded.time_stamp;
''';
    final db = open(OpenMode.readWrite);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1e3;
    db.execute(upsert, [now, wordID]);

    db.dispose();
  }
}
