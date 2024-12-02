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
  TextMessage(
      {required super.content,
      required super.timeStamp,
      required super.wordID,
      super.userID})
      : assert(wordID > 0);
}

class InfoMessage extends Message {
  InfoMessage({
    required super.content,
    required super.timeStamp,
  });
}

class RequireMessage extends Message {
  // final Function(Message)? updateMessage;
  final String vocabulary;
  RequireMessage({
    required this.vocabulary,
    required super.wordID,
    required super.content,
    required super.timeStamp,
    // this.updateMessage,
  });
}
