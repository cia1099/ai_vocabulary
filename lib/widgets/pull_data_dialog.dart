import 'package:ai_vocabulary/api/dict_api.dart' show pullFromCloud;
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:ai_vocabulary/utils/enums.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqlite3/sqlite3.dart' show OpenMode;

class PullDataDialog extends StatelessWidget {
  const PullDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.sizeOf(context).width / 16;
    final textTheme = CupertinoTheme.of(context).textTheme;
    var hasError = false;
    String handleError(Object? e, StackTrace s) {
      hasError = true;
      return messageExceptions(e);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitFadingFour(color: CupertinoColors.white),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: StreamBuilder(
            stream: (Stream pulls) async* {
              yield await pullCollections().onError(handleError);
              await for (final text in pulls) {
                yield text;
              }
              yield await Future.delayed(
                Duration(milliseconds: 350),
                () => 'Complete synchronization',
              );
              if (context.mounted) {
                Navigator.maybePop(context, true);
              }
            }(
              Stream.fromFutures([
                pullAcquaintances().onError(handleError),
                pullPunchDays().onError(handleError),
                pullCollectWords().onError(handleError),
              ]),
            ),
            builder: (context, snapshot) {
              final text = snapshot.data ?? 'Start pulling...';
              final color =
                  hasError && !(hasError ^= true)
                      ? CupertinoColors.destructiveRed.resolveFrom(context)
                      : CupertinoColors.white;
              return Text(text, style: textTheme.textStyle.apply(color: color));
            },
          ),
        ),
      ],
    );
  }

  Future<String> pullAcquaintances() async {
    final userID = UserProvider().currentUser?.uid;
    final query =
        "SELECT word_id AS id FROM acquaintances WHERE user_id='$userID'";
    String generateInsert(List<Map<String, dynamic>> data) {
      transform(Map<String, dynamic> map) =>
          "(${map["acquaint"]},${map["last_learned_time"]},${map["word_id"]},'$userID')";
      return '''
      INSERT INTO acquaintances (
      acquaint, last_learned_time, word_id, user_id) VALUES
      ${data.map(transform).join(",")} 
      ON CONFLICT DO NOTHING;
      ''';
    }

    await pullCloudDB(
      tableName: TableName.acquaintances,
      queryIDs: query,
      generateInsert: generateInsert,
    );

    return 'Acquaintances synchronize done';
  }

  Future<String> pullPunchDays() async {
    final userID = UserProvider().currentUser?.uid;
    final query = "SELECT date AS id FROM punch_days WHERE user_id='$userID'";
    String generateInsert(List<Map<String, dynamic>> data) {
      transform(Map<String, dynamic> map) =>
          "(${map["date"]},${map["study_minute"]},'${map["study_word_ids"]}',${map["punch_time"]},'$userID')";
      return '''
      INSERT INTO punch_days (
      date, study_minute, study_word_ids, punch_time, user_id) VALUES
      ${data.map(transform).join(",")} 
      ON CONFLICT DO NOTHING;
      ''';
    }

    await pullCloudDB(
      tableName: TableName.punchDays,
      queryIDs: query,
      generateInsert: generateInsert,
    );

    return 'Punch Days synchronize done';
  }

  Future<String> pullCollections() async {
    final userID = UserProvider().currentUser?.uid;
    final query = "SELECT id FROM collections WHERE user_id='$userID'";
    String generateInsert(List<Map<String, dynamic>> data) {
      transform(Map<String, dynamic> map) =>
          "(${map["id"]},${map["index"]},'${map["name"]}',${map["icon"]},${map["color"]},'$userID')";
      return '''
      INSERT INTO collections (
      id, "index", name, icon, color, user_id) VALUES
      ${data.map(transform).join(",")} 
      ON CONFLICT DO NOTHING;
      ''';
    }

    await pullCloudDB(
      tableName: TableName.collections,
      queryIDs: query,
      generateInsert: generateInsert,
    );

    return 'Collections synchronize done';
  }

  Future<String> pullCollectWords() async {
    final userID = UserProvider().currentUser?.uid;
    // final _ = await pullCollections();
    final validIDs = await MyDB().readLocal(
        "SELECT id FROM collections WHERE user_id='$userID'",
      )
      ..add(0);
    final query =
        "SELECT word_id AS id FROM collect_words WHERE user_id='$userID'";
    String generateInsert(List<Map<String, dynamic>> data) {
      transform(Map<String, dynamic> map) =>
          "(${map["word_id"]},${map["collection_id"]},'$userID')";
      return '''
      INSERT INTO collect_words (
      word_id, collection_id, user_id) VALUES
      ${data.where((d) => validIDs.contains(d["collection_id"])).map(transform).join(",")} 
      ON CONFLICT DO NOTHING;
      ''';
    }

    await pullCloudDB(
      tableName: TableName.collectWords,
      queryIDs: query,
      generateInsert: generateInsert,
    );

    return 'Collected Words synchronize done';
  }

  Future<void> pullCloudDB({
    required TableName tableName,
    required final String queryIDs,
    required final String Function(List<Map<String, dynamic>>) generateInsert,
  }) async {
    final excludeIDs = await MyDB().readLocal(queryIDs);
    for (var page = 0, data = []; page == 0 || data.isNotEmpty; page++) {
      data = await pullFromCloud(
        tableName: tableName,
        excludeIDs: excludeIDs,
        page: page,
      );
      if (data.isNotEmpty) {
        final insert = generateInsert(data.cast<Map<String, dynamic>>());
        MyDB().writeToLocal(insert);
      }
    }
  }
}

extension _VanillaSQL on MyDB {
  void writeToLocal(final String sqlQuery) {
    final db = open(OpenMode.readWrite);
    db.execute(sqlQuery);
    db.dispose();
  }

  Future<List<int>> readLocal(final String sqlQuery) async {
    await isReady;
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(sqlQuery);
    db.dispose();
    return resultSet.map((row) => row['id'] as int).toList();
  }
}
