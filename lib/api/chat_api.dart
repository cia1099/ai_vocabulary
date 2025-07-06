part of 'dict_api.dart';

Future<ChatAnswer> chatVocabulary(
  String vocabulary,
  String text, {
  String lang = 'en-US',
  AzureVoicer sound = AzureVoicer.Ava,
  bool isHelp = false,
  void Function(Object? e)? onError,
}) async {
  final url = Uri.https(baseURL, '/dict/chat/$vocabulary');
  final headers = {
    'Content-Type': 'application/json',
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };
  final body = jsonEncode({'text': text, 'is_help': isHelp});
  final client = http.Client();
  try {
    final chatResponse = await client
        .post(url, headers: headers, body: body)
        .timeout(kHttpTimeOut * 2);
    if (chatResponse.statusCode == 200) {
      final url = Uri.https(baseURL, '/dict/azure/audio');
      final ans = ChatAnswer.fromRawJson(chatResponse.body);
      final body = jsonEncode({
        'text': ans.answer,
        'lang': lang,
        'gender': sound.gender,
        'name': sound.name,
      });
      final res = await client
          .post(url, headers: headers, body: body)
          .timeout(kHttpTimeOut * 2)
          .onError<TimeoutException>((e, _) => http.Response("$e", 408));
      if (res.statusCode == 200) {
        bytesPlay(res.bodyBytes);
      } else {
        onError?.call(res.body);
      }
      return ans;
    } else {
      throw HttpException(chatResponse.body, uri: url);
    }
  } catch (_) {
    rethrow;
  } finally {
    client.close();
  }
}
