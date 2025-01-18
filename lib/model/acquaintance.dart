import 'dart:convert';

class Acquaintance {
  final int wordId;
  final String? userId;
  final int? lastLearnedTime;
  int acquaint;

  Acquaintance({
    required this.wordId,
    required this.userId,
    required this.acquaint,
    this.lastLearnedTime,
  });

  factory Acquaintance.fromRawJson(String str) =>
      Acquaintance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Acquaintance.fromJson(Map<String, dynamic> json) => Acquaintance(
        wordId: json["word_id"],
        userId: json["user_id"],
        acquaint: json["acquaint"],
        lastLearnedTime: json["last_learned_time"],
      );

  Map<String, dynamic> toJson() => {
        "word_id": wordId,
        "user_id": userId,
        "acquaint": acquaint,
        "last_learned_time": lastLearnedTime,
      };
}
