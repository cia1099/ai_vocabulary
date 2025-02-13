import 'dart:convert';

class Acquaintance {
  final int wordId;
  final String? userId;
  final int? lastLearnedTime;
  int acquaint;

  Acquaintance({
    required this.wordId,
    required this.acquaint,
    this.lastLearnedTime,
    this.userId,
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

class StudyCount {
  int newCount;
  int reviewCount;

  StudyCount({
    this.newCount = 0,
    this.reviewCount = 0,
  });

  factory StudyCount.fromRawJson(String str) =>
      StudyCount.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudyCount.fromJson(Map<String, dynamic> json) => StudyCount(
        newCount: json["new_count"],
        reviewCount: json["review_count"],
      );

  Map<String, dynamic> toJson() => {
        "new_count": newCount,
        "review_count": reviewCount,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StudyCount) return false;
    return newCount == other.newCount && reviewCount == other.reviewCount;
  }

  @override
  int get hashCode => reviewCount.hashCode ^ newCount.hashCode;
}
