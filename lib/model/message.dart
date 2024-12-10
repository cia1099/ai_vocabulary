import 'dart:convert';

abstract class Message {
  final String content;
  final int timeStamp;
  final int wordID;
  final String? userID;

  Message(
      {this.wordID = -1,
      required this.content,
      required this.timeStamp,
      this.userID});
}

class TextMessage extends Message {
  final Iterable<String> patterns;
  TextMessage(
      {required super.content,
      required super.timeStamp,
      required super.wordID,
      this.patterns = const Iterable.empty(),
      super.userID})
      : assert(wordID > 0);

  factory TextMessage.fromRawJson(String str) =>
      TextMessage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TextMessage.fromJson(Map<String, dynamic> json) => TextMessage(
        userID: json["user_id"]?.toString(),
        wordID: json["word_id"],
        timeStamp: json["time_stamp"],
        content: json["content"],
        patterns: (json["patterns"] as String? ?? '').split(', '),
      );

  Map<String, dynamic> toJson() => {
        "user_id": userID,
        "word_id": wordID,
        "time_stamp": timeStamp,
        "content": content,
        "patterns": patterns.join(', '),
      };
}

class InfoMessage extends Message {
  InfoMessage({
    required super.content,
    required super.timeStamp,
  });
}

class RequireMessage extends Message {
  final String vocabulary;
  RequireMessage({
    required this.vocabulary,
    required super.wordID,
    required super.content,
    super.timeStamp = -1,
  });
}
