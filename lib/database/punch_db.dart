part of 'my_db.dart';

extension PunchDB on MyDB {
  List<PunchDay> fetchPunchesInThisMonth(int year, int month) {
    const query = "SELECT * FROM punch_days WHERE date >= ? AND date < ?";
    final thisMonth = DateTime(year, month);
    final nextMonth = DateTime(year, month + 1);
    final db = open(OpenMode.readOnly);
    final resultSets = db.select(query, [
      thisMonth.millisecondsSinceEpoch ~/ 1e3,
      nextMonth.millisecondsSinceEpoch ~/ 1e3,
    ]);
    db.dispose();
    return resultSets.map((json) => PunchDay.fromJson(json)).toList();
  }

  void insertPunch([int studyMinute = 0]) {
    const insert =
        'INSERT INTO punch_days (date, study_word_ids, study_minute, punch_time) VALUES (?, ?, ?, ?)';
    final now = DateTime.now();
    final date =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1e3;
    final studyWordIDs = getTodayStudyWordIDs().join(',');
    final punchTime = now.millisecondsSinceEpoch ~/ 1e3;
    final db = open(OpenMode.readWrite);
    try {
      db.execute(insert, [date, studyWordIDs, studyMinute, punchTime]);
    } on SqliteException catch (e) {
      debugPrint('SQL error(${e.resultCode}): ${e.message}');
      updatePunch(
        date: date,
        studyWordIDs: studyWordIDs,
        studyMinute: studyMinute,
        punchTime: punchTime,
      );
    }
    db.dispose();
  }

  void updatePunch({
    required int date,
    String? studyWordIDs,
    int? punchTime,
    int studyMinute = 0,
  }) {
    const update =
        'UPDATE punch_days SET study_word_ids=?,study_minute=?,punch_time=? WHERE date=?';
    punchTime ??= DateTime.now().millisecondsSinceEpoch ~/ 1e3;
    studyWordIDs ??= getTodayStudyWordIDs().join(',');
    final db = open(OpenMode.readWrite);
    db
      ..execute(update, [studyWordIDs, studyMinute, punchTime, date])
      ..dispose();
  }
}
