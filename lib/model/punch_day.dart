import 'dart:convert';

class PunchDay {
  int date;
  List<int> studyWordIDs;
  int studyMinute;
  int punchTime;

  PunchDay({
    required this.date,
    required this.studyWordIDs,
    required this.studyMinute,
    required this.punchTime,
  });

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
