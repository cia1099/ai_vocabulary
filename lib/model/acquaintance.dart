import 'dart:convert';

class Acquaintance {
  final int wordId;
  final String? userId;
  int acquaint;

  Acquaintance({
    required this.wordId,
    required this.userId,
    required this.acquaint,
  });

  factory Acquaintance.fromRawJson(String str) =>
      Acquaintance.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Acquaintance.fromJson(Map<String, dynamic> json) => Acquaintance(
        wordId: json["word_id"],
        userId: json["user_id"],
        acquaint: json["acquaint"],
      );

  Map<String, dynamic> toJson() => {
        "word_id": wordId,
        "user_id": userId,
        "acquaint": acquaint,
      };
}
