import 'dart:convert';

import 'package:flutter/material.dart';

abstract class Message {
  final String content;
  final int timeStamp;
  final int wordID;
  final String? userID;

  Message({
    this.wordID = -1,
    required this.content,
    this.userID,
    int? timeStamp,
  }) : timeStamp = timeStamp ?? DateTime.now().millisecondsSinceEpoch;
}

class TextMessage extends Message with ChangeNotifier {
  final Iterable<String> patterns;
  var _hasError = false;
  TextMessage({
    required super.content,
    required super.wordID,
    this.patterns = const Iterable.empty(),
    super.timeStamp,
    super.userID,
  }) : assert(wordID > 0);
  bool get hasError => _hasError;
  set hasError(bool error) {
    if (_hasError ^ error) {
      _hasError = error;
      notifyListeners();
    }
  }

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
  InfoMessage({required super.content, super.timeStamp});
}

class RequireMessage extends Message {
  final String vocabulary;
  final TextMessage srcMsg;
  RequireMessage({required this.srcMsg})
    : vocabulary = srcMsg.patterns.join(', '),
      super(wordID: srcMsg.wordID, content: srcMsg.content);
}

class ErrorMessage extends Message {
  final TextMessage srcMsg;

  ErrorMessage({required super.content, required this.srcMsg});
}
