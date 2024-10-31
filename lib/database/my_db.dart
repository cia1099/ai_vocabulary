import 'sql_expression.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class MyDB {
  var appDirectory = '';

  /// Singleton pattern
  static const _dbName = 'my.db';
  static MyDB? _instance;
  MyDB._internal() {
    _init();
  }
  static MyDB get instance => _instance ??= MyDB._internal();
  factory MyDB() => instance;

  Future<void> _init() async {
    // final documentsDirectory = await getApplicationDocumentsDirectory();
    // print("Application directory: $documentsDirectory");
    // appDirectory = documentsDirectory.path;
    final dbPath = p.join(appDirectory, _dbName);
    final db = sqlite3.open(dbPath);
    db.execute(createDictionary);
    db.dispose();
  }

  // void dispose() {
  //   _database?.dispose();
  // }
}

void main() {
  final myDB = MyDB();
}
