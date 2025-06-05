part of 'my_db.dart';

extension ChatMsgDB on MyDB {
  Iterable<TextMessage> fetchMessages(int wordID) {
    const query =
        'SELECT * FROM text_messages WHERE word_id = ? AND owner_id=?';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query, [
      wordID,
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
    return resultSet.map((row) => TextMessage.fromJson(row));
  }

  Future<void> insertMessages(Stream<TextMessage> messages) async {
    final ownerID = UserProvider().currentUser?.uid;
    final upsert =
        '''
INSERT INTO text_messages 
(time_stamp, content, word_id, patterns, user_id, owner_id) VALUES
${await messages.map((m) => "(${m.timeStamp},'${m.content.replaceAll("'", "''")}',${m.wordID},'${m.patterns.join(', ')}','${m.userID}','$ownerID')").join(',')}
ON CONFLICT (time_stamp, owner_id) DO NOTHING;
''';
    final db = open(OpenMode.readWrite);
    db.execute(upsert);
    final resultSet = db.select("SELECT changes() AS inserted");
    final inserted = (resultSet.firstOrNull?['inserted'] ?? 0) as int;
    db.dispose();
    if (inserted > 0) {
      notifyListeners();
    }
  }

  void removeMessagesByWordID(int wordID) {
    final db = open(OpenMode.readWrite);
    const query =
        'SELECT time_stamp FROM text_messages WHERE word_id = ? AND owner_id=?';
    final ownerID = UserProvider().currentUser?.uid;
    final resultSet = db.select(query, [wordID, ownerID]);
    for (final stamp in resultSet.map((row) => row['time_stamp'] as int)) {
      final file = File(p.join(appDirectory, 'audio', '$stamp.wav'));
      file.exists().then((value) {
        if (value) file.delete();
      });
    }
    const expression =
        'DELETE FROM text_messages WHERE word_id = ? AND owner_id=?';
    db.execute(expression, [wordID, ownerID]);
    db.dispose();
  }

  Future<Iterable<AlphabetModel>> fetchAlphabetModels() async {
    await isReady;
    const query = '''
      SELECT words.id AS word_id, words.word, assets.filename, 
      max(text_messages.time_stamp) AS time_stamp 
      FROM words LEFT OUTER JOIN assets ON assets.word_id = words.id 
      JOIN text_messages ON text_messages.word_id = words.id
      WHERE words.id IN (SELECT word_id FROM text_messages WHERE owner_id=? GROUP BY word_id) 
      GROUP BY words.id
      ''';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query, [UserProvider().currentUser?.uid]);
    db.dispose();

    return Iterable.generate(
      resultSet.length,
      (index) => AlphabetModel(
        id: resultSet[index]['word_id'] as int,
        name: resultSet[index]['word'] as String,
        avatarUrl: resultSet[index]['filename'] as String?,
        lastTimeStamp: resultSet[index]['time_stamp'] as int,
      ),
    );
  }
}
