import 'dart:convert';

class PunchDay {
  final int date;
  final List<int> studyWordIDs;
  final int studyMinute;
  final int punchTime;

  PunchDay({
    required this.date,
    required this.studyWordIDs,
    required this.studyMinute,
    required this.punchTime,
  });

  factory PunchDay.now({
    required Iterable<int> studyWordIDs,
    int studyMinute = 0,
  }) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    final punchTime = now.millisecondsSinceEpoch ~/ 1e3;
    return PunchDay(
      date: date.millisecondsSinceEpoch ~/ 1e3,
      studyWordIDs: studyWordIDs.toList(),
      studyMinute: studyMinute,
      punchTime: punchTime,
    );
  }

  factory PunchDay.fromRawJson(String str) =>
      PunchDay.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PunchDay.fromJson(Map<String, dynamic> json) => PunchDay(
    date: json["date"],
    studyWordIDs: List<int>.from(
      (json["study_word_ids"] as String).split(',').map((x) => int.parse(x)),
    ),
    studyMinute: json["study_minute"],
    punchTime: json["punch_time"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "study_word_ids": studyWordIDs.join(','),
    "study_minute": studyMinute,
    "punch_time": punchTime,
  };
}
