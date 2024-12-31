part of 'my_db.dart';

extension CollectionDB on MyDB {
  Iterable<CollectionMark> fetchMarks() {
    final db = open(OpenMode.readOnly);
    final resultSet = db.select('SELECT * FROM collections');
    db.dispose();
    return resultSet.map((row) => CollectionMark.fromJson(row));
  }

  void insertCollection(String name, int index) {
    const expression = 'INSERT INTO collections (name, index) VALUES (?, ?)';
    final db = open(OpenMode.readWrite);
    db.execute(expression, [name, index]);
    db.dispose();
  }

  void removeMark({required String name}) {
    const expression = 'DELETE FROM collections WHERE name=?';
    final db = open(OpenMode.readWrite);
    db.execute(expression, [name]);
    //TODO: also need to delete relative words in this collection
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

  void updateIndexes(List<CollectionMark> marks) {
    final expression = _updateExpression(['index']);
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
    const columnName = ['index', 'icon', 'color', 'name'];
    final posInput = argsName
        .where((e) => columnName.contains(e))
        .map((e) => '$e=?')
        .join(',');
    return 'UPDATE collections SET $posInput WHERE collections.name=?';
  }
}
