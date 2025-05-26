part of 'dict_api.dart';

Future<void> soundGTTs(String text, [gTTS lang = gTTS.US]) async {
  final url = Uri.https(baseURL, '/dict/gtts/audio');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'text': text, 'lang': lang.lang});
  final res = await http
      .post(url, headers: headers, body: body)
      .timeout(kHttpTimeOut);
  if (res.statusCode == 200) {
    bytesPlay(res.bodyBytes);
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<void> soundAzure(
  String text, {
  String lang = 'en-US',
  // String gender = 'Female',
  // String name = 'en-US-AvaMultilingualNeural',
  AzureVoicer sound = AzureVoicer.Ava,
}) async {
  final url = Uri.https(baseURL, '/dict/azure/audio');
  final accessToken = UserProvider().currentUser?.accessToken;
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };
  final body = jsonEncode({
    'text': text,
    'lang': lang,
    'gender': sound.gender,
    'name': sound.name,
  });
  final res = await http
      .post(url, headers: headers, body: body)
      .timeout(kHttpTimeOut);
  if (res.statusCode == 200) {
    bytesPlay(res.bodyBytes);
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<SpeechRecognition> recognizeSpeech(String filePath) async {
  final url = Uri.https(baseURL, '/dict/chat/speech');
  final accessToken = UserProvider().currentUser?.accessToken;
  final headers = {
    'Content-Type': 'multipart/form-data',
    'Authorization': 'Bearer $accessToken',
  };
  final request = http.MultipartRequest('POST', url)..headers.addAll(headers);
  request.files.add(
    await http.MultipartFile.fromPath(
      'speech',
      filePath,
      filename: p.basename(filePath),
      contentType: MediaType('audio', p.extension(filePath).substring(1)),
    ),
  );
  final res = await request.send();
  final body = utf8.decode(await res.stream.last);
  if (res.statusCode == 200) {
    final apiResponse = ApiResponse.fromRawJson(body);
    if (apiResponse.status != 200) throw ApiException(apiResponse.content);
    return SpeechRecognition.fromRawJson(apiResponse.content);
  } else {
    throw HttpException(body, uri: url);
  }
}

Future<SpeechRecognition> recognizeSpeechBytes(List<int> bytes) async {
  final url = Uri.https(baseURL, '/dict/chat/speech');
  final res = await postBytes(url, bytes);
  if (res.statusCode == 200) {
    final apiResponse = ApiResponse.fromRawJson(res.body);
    if (apiResponse.status != 200) throw ApiException(apiResponse.content);
    return SpeechRecognition.fromRawJson(apiResponse.content);
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<List<Syllable>> pronunciationWord({
  required String word,
  required List<int> bytes,
}) async {
  final url = Uri.https(baseURL, '/dict/pronunciation', {'word': word});
  final res = await postBytes(url, bytes);
  if (res.statusCode == 200) {
    final apiResponse = ApiResponse.fromRawJson(res.body);
    if (apiResponse.status != 200) throw ApiException(apiResponse.content);
    return List<Syllable>.from(
      jsonDecode(apiResponse.content).map((obj) => Syllable.fromJson(obj)),
    );
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<http.Response> postBytes(
  Uri url,
  List<int> bytes, {
  Map<String, String> headers = const {},
  String filename = 'wave_media.wav',
}) async {
  final accessToken = UserProvider().currentUser?.accessToken;
  headers = {
    'Content-Type': 'multipart/form-data',
    'Authorization': 'Bearer $accessToken',
  }..addAll(headers);
  final request = http.MultipartRequest('POST', url)..headers.addAll(headers);
  request.files.add(
    http.MultipartFile.fromBytes(
      'speech',
      bytes,
      filename: filename,
      contentType: MediaType('audio', p.extension(filename).substring(1)),
    ),
  );
  final res = await request.send();
  final body = utf8.decode(await res.stream.last);
  return http.Response(
    body,
    res.statusCode,
    request: res.request,
    headers: res.headers,
    reasonPhrase: res.reasonPhrase,
    persistentConnection: false,
  );
}
