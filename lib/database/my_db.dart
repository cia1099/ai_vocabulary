import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:ai_vocabulary/model/collections.dart';
import 'package:ai_vocabulary/model/message.dart';
import 'package:ai_vocabulary/model/punch_day.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../model/alphabet.dart';
import '../model/acquaintance.dart';
import '../utils/shortcut.dart';
import 'sql_expression.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'acquaint_db.dart';
part 'chat_msg_db.dart';
part 'collection_db.dart';
part 'search_db.dart';
part 'punch_db.dart';

class MyDB with ChangeNotifier {
  late final String _appDirectory;

  /// Singleton pattern
  static const _dbName = 'my.db';
  static MyDB? _instance;
  MyDB._internal() {
    _init()
        .whenComplete(() {
          _completer.complete(true);
        })
        .onError((_, __) {
          _completer.completeError(false);
        });
  }
  static MyDB get instance => _instance ??= MyDB._internal();
  factory MyDB() => instance;

  Database open(OpenMode mode) =>
      sqlite3.open(p.join(appDirectory, _dbName), mode: mode);
  String get appDirectory => _appDirectory;
  // Future<String> get futureAppDirectory async =>
  //     getApplicationDocumentsDirectory().then((value) => value.path);

  Future<void> _init() async {
    // _appDirectory = '';
    final documentsDirectory = await getApplicationDocumentsDirectory();
    debugPrint("Application directory: $documentsDirectory");
    _appDirectory = documentsDirectory.path;
    final dbPath = p.join(appDirectory, _dbName);
    if (File(dbPath).existsSync()) return;
    final db = sqlite3.open(dbPath);
    db.execute(createDictionary);
    db.dispose();
  }

  final _completer = Completer<bool>();
  Future<bool> get isReady => _completer.future;

  Future<void> insertWords(Stream<Vocabulary> words) async {
    final db = open(OpenMode.readWrite);
    final insert = [
      insertWord,
      insertDefinition,
      insertExplanation,
      insertExample,
      insertAsset,
      insertAcquaintance,
    ];
    final stmts = db.prepareMultiple(insert.join(';'));
    await for (final word in words) {
      try {
        _insertVocabulary(word, stmts);
      } on SqliteException catch (e) {
        debugPrint(
          'SQL error(${e.resultCode}): ${e.message}=(${word.wordId})${word.word}',
        );
        db
            .prepareMultiple(deleteVocabulary)
            .forEach(
              (rm) =>
                  rm
                    ..execute([word.wordId])
                    ..dispose(),
            );
        final acStmt = stmts.removeLast();
        _insertVocabulary(word, stmts);
        stmts.add(acStmt);
      }
    }
    for (var stmt in stmts) {
      stmt.dispose();
    }
    db.dispose();
  }

  List<Vocabulary> fetchWords(Iterable<int> wordIds) {
    final fetchWordId = '$fetchWordInID (${wordIds.map((_) => '?').join(',')})';
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(fetchWordId, wordIds.toList());
    final wordMaps = buildWordMaps(resultSet);
    db.dispose();
    return wordMaps.map((json) => Vocabulary.fromJson(json)).toList();
  }

  void _insertVocabulary(Vocabulary word, List<PreparedStatement> stmts) {
    stmts[0].execute([word.wordId, word.word]);
    for (final definition in word.definitions) {
      final definitionID =
          stmts[1].select([
                word.wordId,
                definition.id,
                definition.partOfSpeech,
                definition.inflection,
                definition.phoneticUs,
                definition.phoneticUk,
                definition.audioUs,
                definition.audioUk,
                definition.synonyms,
                definition.antonyms,
              ]).first['id']
              as int;
      for (final explanation in definition.explanations) {
        final explanationID =
            stmts[2].select([
                  word.wordId,
                  definitionID,
                  explanation.explain,
                  explanation.subscript,
                ]).first['id']
                as int;
        for (final example in explanation.examples) {
          stmts[3].execute([word.wordId, explanationID, example]);
        } //for example
      } //for explanation
    } //for definition
    if (word.asset != null) {
      stmts[4].execute([word.wordId, word.asset]);
    }
    if (stmts.length > 5) {
      final userID = UserProvider().currentUser?.uid;
      stmts[5].execute([word.wordId, userID]);
    }
  }

  // void dispose() {
  //   _database?.dispose();
  // }
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

List<Map<String, dynamic>> buildWordMaps(ResultSet resultSet) {
  final wordMaps = <Map<String, dynamic>>[];
  for (final row in resultSet) {
    final wordMap = traceWord(
      Queue.of([
        {
          'word_id': row['word_id'],
          'word': row['word'],
          'asset': row['asset'],
          'acquaint': row['acquaint'],
          'last_learned_time': row['last_learned_time'],
        },
        {'part_of_speech': row['part_of_speech']},
        {
          "definition_id": row['definition_id'],
          "part_of_speech": row['part_of_speech'],
          "inflection": row['inflection'],
          "phonetic_uk": row['alphabet_uk'],
          "phonetic_us": row['alphabet_us'],
          "audio_uk": row['audio_uk'],
          "audio_us": row['audio_us'],
          "synonyms": row['synonyms'],
          "antonyms": row['antonyms'],
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
      wordMaps,
    );
    if (!wordMaps.any(((w) => w['word_id'] == row['word_id']))) {
      wordMaps.add(wordMap);
    }
  }
  return wordMaps;
}

Map<String, dynamic> traceWord(
  Queue<Map<String, dynamic>> nodes,
  List<Map<String, dynamic>> cache,
) {
  final node = nodes.removeLast();
  if (nodes.isEmpty) {
    return cache.firstWhere(
      (row) => row["word_id"] == node['word_id'],
      orElse: () => node..addAll({'definitions': <Map<String, dynamic>>[]}),
    );
  }

  final obj = traceWord(nodes, cache);
  final definitions = obj['definitions'] as List<Map<String, dynamic>>;
  if (node.length == 1) {
    if (definitions.indexWhere(
          (d) => d['part_of_speech'] == node['part_of_speech'],
        ) <
        0) {
      definitions.add(node..addAll({"explanations": <Map<String, dynamic>>[]}));
    }
  } else {
    final partOfSpeech = node.remove('part_of_speech') as String;
    final definition = definitions.firstWhere(
      (d) => d['part_of_speech'] == partOfSpeech,
    );
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
