import 'dart:convert';

class ChatAnswer {
  final bool quiz;
  final String answer;
  final int created;
  final String userId;

  ChatAnswer({
    required this.quiz,
    required this.answer,
    required this.created,
    required this.userId,
  });

  factory ChatAnswer.fromRawJson(String str) =>
      ChatAnswer.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatAnswer.fromJson(Map<String, dynamic> json) => ChatAnswer(
        quiz: json["quiz"],
        answer: json["answer"],
        created: json["created"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "quiz": quiz,
        "answer": answer,
        "created": created,
        "user_id": userId,
      };
}

class SpeechRecognition {
  final String text;
  final bool recognize;

  SpeechRecognition({
    required this.text,
    required this.recognize,
  });

  factory SpeechRecognition.fromRawJson(String str) =>
      SpeechRecognition.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SpeechRecognition.fromJson(Map<String, dynamic> json) =>
      SpeechRecognition(
        text: json["text"],
        recognize: json["recognize"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "recognize": recognize,
      };
}
