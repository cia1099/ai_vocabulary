part of 'dict_api.dart';

Future<void> soundGTTs(String text, [gTTS lang = gTTS.US]) async {
  final url = Uri.https(baseURL, '/dict/gtts/audio');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'text': text, 'lang': lang.lang});
  final res =
      await http.post(url, headers: headers, body: body).timeout(timeOut);
  if (res.statusCode == 200) {
    bytesPlay(res.bodyBytes);
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<void> soundAzure(String text,
    {String lang = 'en-US',
    String gender = 'Female',
    String name = 'en-US-AvaMultilingualNeural'}) async {
  final url = Uri.https(baseURL, '/dict/azure/audio');
  final headers = {'Content-Type': 'application/json'};
  final body =
      jsonEncode({'text': text, 'lang': lang, 'gender': gender, 'name': name});
  final res =
      await http.post(url, headers: headers, body: body).timeout(timeOut);
  if (res.statusCode == 200) {
    bytesPlay(res.bodyBytes);
  } else {
    throw HttpException(res.body, uri: url);
  }
}
