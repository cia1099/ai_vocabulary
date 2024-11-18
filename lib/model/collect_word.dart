import 'dart:convert';

class CollectWord {
  final int wordId;
  final String? userId;
  int learned;
  bool collect;
  String? bookmark;

  CollectWord({
    required this.wordId,
    required this.userId,
    required this.learned,
    required this.collect,
    required this.bookmark,
  });

  factory CollectWord.fromRawJson(String str) =>
      CollectWord.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CollectWord.fromJson(Map<String, dynamic> json) => CollectWord(
        wordId: json["word_id"],
        userId: json["user_id"],
        learned: json["learned"],
        collect: json["collect"] > 0,
        bookmark: json["bookmark"],
      );

  Map<String, dynamic> toJson() => {
        "word_id": wordId,
        "user_id": userId,
        "learned": learned,
        "collect": collect,
        "bookmark": bookmark,
      };
}
