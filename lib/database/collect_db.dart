part of 'my_db.dart';

extension CollectDB on MyDB {
  void updateCollectWord({
    required int wordId,
    int? learned,
    bool? collect,
    String? bookmark,
  }) {
    final inputs = <dynamic>[learned, collect, bookmark];
    final posInput = List.generate(inputs.length, (i) {
      final input = inputs.elementAt(i);
      if (input == null) return input;
      switch (i) {
        case 0:
          return 'learned=?';
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
        'UPDATE collect_words SET $posInput WHERE collect_words.word_id=?';
    final db = open(OpenMode.readWrite);
    db.execute(
        expression,
        inputs.expand((e) sync* {
              if (e != null) yield e;
            }).toList() +
            [wordId]);
    db.dispose();
  }

  CollectWord getCollectWord(int wordID) {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(
        'SELECT * FROM collect_words WHERE collect_words.word_id = ?',
        [wordID]);
    final collects = resultSet.take(1).map((row) => CollectWord.fromJson(row));
    db.dispose();
    return collects.first;
  }
}
