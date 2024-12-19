import 'dart:convert';

class CollectWord {
  final int wordId;
  final String? userId;
  int acquaint;
  bool collect;
  String? bookmark;

  CollectWord({
    required this.wordId,
    required this.userId,
    required this.acquaint,
    required this.collect,
    required this.bookmark,
  });

  factory CollectWord.fromRawJson(String str) =>
      CollectWord.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CollectWord.fromJson(Map<String, dynamic> json) => CollectWord(
        wordId: json["word_id"],
        userId: json["user_id"],
        acquaint: json["acquaint"],
        collect: json["collect"] > 0,
        bookmark: json["bookmark"],
      );

  Map<String, dynamic> toJson() => {
        "word_id": wordId,
        "user_id": userId,
        "acquaint": acquaint,
        "collect": collect,
        "bookmark": bookmark,
      };
}
