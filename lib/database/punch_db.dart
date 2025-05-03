part of 'my_db.dart';

extension PunchDB on MyDB {
  List<PunchDay> fetchPunchesInThisMonth(int year, int month) {
    const query =
        "SELECT * FROM punch_days WHERE date >= ? AND date < ? AND user_id = ?";
    final thisMonth = DateTime(year, month);
    final nextMonth = DateTime(year, month + 1);
    final db = open(OpenMode.readOnly);
    final resultSets = db.select(query, [
      thisMonth.millisecondsSinceEpoch ~/ 1e3,
      nextMonth.millisecondsSinceEpoch ~/ 1e3,
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
    return resultSets.map((json) => PunchDay.fromJson(json)).toList();
  }

  int getPastPunchDays() {
    const query =
        "SELECT COUNT(date) AS days FROM punch_days WHERE date < ? AND user_id = ?";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final db = open(OpenMode.readOnly);
    final resultSet = db.select(query, [
      today.millisecondsSinceEpoch ~/ 1e3,
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
    return resultSet.firstOrNull?['days'] ?? 0;
  }

  void upsertPunch([int studyMinute = 0]) {
    const upsert = '''
    INSERT INTO punch_days 
    (date, study_word_ids, study_minute, punch_time, user_id) VALUES (?,?,?,?,?)
    ON CONFLICT (date, user_id) DO UPDATE SET study_word_ids=excluded.study_word_ids,
    study_minute=excluded.study_minute, punch_time=excluded.punch_time
    ''';
    final punchDay = PunchDay.now(
      studyWordIDs: getTodayStudyWordIDs(),
      studyMinute: studyMinute,
    );
    final db = open(OpenMode.readWrite);
    db.execute(upsert, [
      ...punchDay.toJson().values,
      UserProvider().currentUser?.uid,
    ]);
    db.dispose();
  }
}
