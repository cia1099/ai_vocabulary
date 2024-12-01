part of 'dict_api.dart';

Future<ChatAnswer> chatVocabulary(String vocabulary, String text,
    [bool isHelp = false]) async {
  final url = Uri.https(baseURL, '/chat/$vocabulary');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'text': text, 'is_help': isHelp});
  final res =
      await http.post(url, headers: headers, body: body).timeout(timeOut);
  if (res.statusCode == 200) {
    return ChatAnswer.fromRawJson(res.body);
  } else {
    throw HttpException(res.body, uri: url);
  }
}
