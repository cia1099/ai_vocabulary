part of 'my_db.dart';

extension ChatMsgDB on MyDB {
  Iterable<TextMessage> fetchMessages(int wordID) {
    const query = 'SELECT * FROM text_messages WHERE word_id = ?';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query, [wordID]);
    db.dispose();
    return resultSet.map((row) => TextMessage.fromJson(row));
  }

  Future<void> insertMessages(Stream<TextMessage> messages) async {
    var success = 0;
    final db = open(OpenMode.readWrite);
    final stmt = db.prepare(insertTextMessage);
    await for (final msg in messages) {
      try {
        stmt.execute([
          msg.timeStamp,
          msg.content,
          msg.wordID,
          msg.patterns.join(', '),
          msg.userID
        ]);
        success += 1;
      } on SqliteException {
        continue;
      }
    }
    stmt.dispose();
    db.dispose();
    if (success > 0) {
      notifyListeners();
    }
  }

  void removeMessagesByWordID(int wordID) {
    final db = open(OpenMode.readWrite);
    const query = 'SELECT time_stamp FROM text_messages WHERE word_id = ?';
    final resultSet = db.select(query, [wordID]);
    for (final stamp in resultSet.map((row) => row['time_stamp'] as int)) {
      final file = File(p.join(appDirectory, 'audio', '$stamp.wav'));
      file.exists().then((value) {
        if (value) file.delete();
      });
    }
    const expression = 'DELETE FROM text_messages WHERE word_id = ?';
    db.execute(expression, [wordID]);
    db.dispose();
  }

  Future<Iterable<AlphabetModel>> fetchAlphabetModels() async {
    await isReady;
    const query = '''
      SELECT words.id AS word_id, words.word, assets.filename, 
      max(text_messages.time_stamp) AS time_stamp 
      FROM words LEFT OUTER JOIN assets ON assets.word_id = words.id 
      JOIN text_messages ON text_messages.word_id = words.id
      WHERE words.id IN (SELECT word_id FROM text_messages GROUP BY word_id) 
      GROUP BY words.id
      ''';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query);
    db.dispose();

    return Iterable.generate(
      resultSet.length,
      (index) => AlphabetModel(
          id: resultSet[index]['word_id'] as int,
          name: resultSet[index]['word'] as String,
          avatarUrl: resultSet[index]['filename'] as String?,
          lastTimeStamp: resultSet[index]['time_stamp'] as int),
    );
  }
}
