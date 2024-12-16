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
      } on SqliteException {
        continue;
      }
    }
    stmt.dispose();
    db.dispose();
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
    try {
      appDirectory;
    } on Error {
      // print('error');
      await futureAppDirectory;
    }
    const query =
        'SELECT word_id, max(time_stamp) AS time_stamp FROM text_messages';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query);
    db.dispose();
    final words = fetchWords(resultSet.map((row) => row['word_id'] as int));
    return Iterable.generate(
        words.length,
        (index) => AlphabetModel(
            word: words[index],
            lastTimeStamp: resultSet[index]['time_stamp'] as int));
  }
}
