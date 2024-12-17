import 'dart:collection';
import 'dart:io';

import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../model/alphabet.dart';
import '../model/collect_word.dart';
import 'sql_expression.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'collect_db.dart';
part 'chat_msg_db.dart';

class MyDB with ChangeNotifier {
  late final String _appDirectory;

  /// Singleton pattern
  static const _dbName = 'my.db';
  static MyDB? _instance;
  MyDB._internal() {
    _init();
  }
  static MyDB get instance => _instance ??= MyDB._internal();
  factory MyDB() => instance;

  Database open(OpenMode mode) =>
      sqlite3.open(p.join(appDirectory, _dbName), mode: mode);
  String get appDirectory => _appDirectory;
  Future<String> get futureAppDirectory async =>
      getApplicationDocumentsDirectory().then((value) => value.path);

  Future<void> _init() async {
    // _appDirectory = '';
    final documentsDirectory = await getApplicationDocumentsDirectory();
    print("Application directory: $documentsDirectory");
    _appDirectory = documentsDirectory.path;
    final dbPath = p.join(appDirectory, _dbName);
    if (File(dbPath).existsSync()) return;
    final db = sqlite3.open(dbPath);
    db.execute(createDictionary);
    db.dispose();
  }

  void insertWords(Stream<Vocabulary> words) async {
    final db = open(OpenMode.readWrite);
    final insert = [
      insertWord,
      insertDefinition,
      insertExplanation,
      insertExample,
      insertAsset,
      insertCollectWord
    ];
    final stmts = db.prepareMultiple(insert.join(';'));
    await for (final word in words) {
      try {
        stmts[0].execute([word.wordId, word.word]);
        for (final definition in word.definitions) {
          final definitionID = stmts[1].select([
            word.wordId,
            definition.partOfSpeech,
            definition.inflection,
            definition.phoneticUs,
            definition.phoneticUk,
            definition.audioUs,
            definition.audioUk,
            definition.translate
          ]).first['id'] as int;
          for (final explanation in definition.explanations) {
            final explanationID = stmts[2].select([
              word.wordId,
              definitionID,
              explanation.explain,
              explanation.subscript
            ]).first['id'] as int;
            for (final example in explanation.examples) {
              stmts[3].execute([word.wordId, explanationID, example]);
            } //for example
          } //for explanation
        } //for definition
        if (word.asset != null) {
          stmts[4].execute([word.wordId, word.asset]);
        }
        stmts[5].execute([word.wordId, null]);
      } on SqliteException {
        continue;
      }
    }
    for (var stmt in stmts) {
      stmt.dispose();
    }
    db.dispose();
  }

  List<Vocabulary> fetchWords(Iterable<int> wordIds) {
    final fetchWordId = '''
SELECT words.id, words.word, assets.filename, definitions.part_of_speech, definitions.inflection, definitions.alphabet_uk, definitions.alphabet_us, definitions.audio_uk, definitions.audio_us, definitions.translate, explanations.subscript, explanations.explain, examples.example 
FROM words LEFT OUTER JOIN assets ON assets.word_id = words.id JOIN definitions ON words.id = definitions.word_id JOIN explanations ON explanations.definition_id = definitions.id LEFT OUTER JOIN examples ON examples.explanation_id = explanations.id 
WHERE words.id IN (${wordIds.map((_) => '?').join(',')})
''';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(fetchWordId, wordIds.toList());
    final wordMaps = <Map<String, dynamic>>[];
    for (final row in resultSet) {
      final wordMap = traceWord(
          Queue.of([
            {
              'word_id': row['id'],
              'word': row['word'],
              'asset': row['filename']
            },
            {'part_of_speech': row['part_of_speech']},
            {
              "part_of_speech": row['part_of_speech'],
              "inflection": row['inflection'],
              "phonetic_uk": row['alphabet_uk'],
              "phonetic_us": row['alphabet_us'],
              "audio_uk": row['audio_uk'],
              "audio_us": row['audio_us'],
              "translate": row['translate'],
            },
            {
              "part_of_speech": row['part_of_speech'],
              "explain": row['explain'],
              "subscript": row['subscript'],
            },
            {
              "part_of_speech": row['part_of_speech'],
              "explain": row['explain'],
              "example": row['example'],
            },
          ]),
          wordMaps);
      if (!wordMaps.any(((w) => w['word_id'] == row['id']))) {
        wordMaps.add(wordMap);
      }
    }
    db.dispose();
    return wordMaps.map((json) => Vocabulary.fromJson(json)).toList();
  }

  // void dispose() {
  //   _database?.dispose();
  // }
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

Map<String, dynamic> traceWord(
    Queue<Map<String, dynamic>> nodes, List<Map<String, dynamic>> cache) {
  final node = nodes.removeLast();
  if (nodes.isEmpty) {
    return cache.firstWhere((row) => row["word_id"] == node['word_id'],
        orElse: () => node..addAll({'definitions': <Map<String, dynamic>>[]}));
  }

  final obj = traceWord(nodes, cache);
  final definitions = obj['definitions'] as List<Map<String, dynamic>>;
  if (node.length == 1) {
    if (definitions
            .indexWhere((d) => d['part_of_speech'] == node['part_of_speech']) <
        0) {
      definitions.add(node..addAll({"explanations": <Map<String, dynamic>>[]}));
    }
  } else {
    final partOfSpeech = node.remove('part_of_speech') as String;
    final definition =
        definitions.firstWhere((d) => d['part_of_speech'] == partOfSpeech);
    if (node.containsKey('inflection')) {
      if (definition.keys.every((key) => !node.containsKey(key))) {
        definition.addAll(node);
      }
    }
    final explanations =
        definition['explanations'] as List<Map<String, dynamic>>;
    if (node.containsKey('explain') && node.containsKey('subscript')) {
      if (!explanations.any((e) => e['explain'] == node['explain'])) {
        explanations.add(node..addAll({'examples': []}));
      }
    }
    if (node['example'] != null) {
      for (final explanation in explanations) {
        if (explanation['explain'] == node['explain']) {
          explanation['examples'] += [node['example']];
        }
      }
    }
  }
  return obj;
}

void main() {
  final myDB = MyDB();
  // myDB.insertWords(Stream.fromIterable([apple, apple]));
  // final words = myDB.fetchWords([12316]);
  // for (final word in words) {
  //   print(word.toRawJson());
  // }
  final db = myDB.open(OpenMode.readWrite);
  final stmt = db.prepare(insertCollectWord);
  stmt.execute([123, null]);
  db.dispose();
}
