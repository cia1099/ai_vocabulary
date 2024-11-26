abstract class Message {
  final String content;
  final int timeStamp;
  final int wordID;
  final String? userID;

  Message(
      {required this.wordID,
      required this.content,
      required this.timeStamp,
      this.userID});
}

class TextMessage extends Message {
  TextMessage(
      {required super.content,
      required super.timeStamp,
      required super.wordID,
      super.userID});
}

class InfoMessage extends Message {
  InfoMessage({
    required super.content,
    required super.timeStamp,
    required super.wordID,
  });
}
