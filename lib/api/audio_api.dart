part of 'dict_api.dart';

Future<void> soundGTTs(String text, [gTTS lang = gTTS.US]) async {
  final url = Uri.http(baseURL, '/dict/gtts/audio');
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
  final url = Uri.http(baseURL, '/dict/azure/audio');
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
  final url = Uri.http(baseURL, '/dict/chat/speech');
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

Future<SpeechRecognition> recognizeSpeechBytes(
  List<int> bytes, {
  String filename = 'temporary.wav',
}) async {
  final url = Uri.http(baseURL, '/dict/chat/speech');
  final accessToken = UserProvider().currentUser?.accessToken;
  final headers = {
    'Content-Type': 'multipart/form-data',
    'Authorization': 'Bearer $accessToken',
  };
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
  if (res.statusCode == 200) {
    final apiResponse = ApiResponse.fromRawJson(body);
    if (apiResponse.status != 200) throw ApiException(apiResponse.content);
    return SpeechRecognition.fromRawJson(apiResponse.content);
  } else {
    throw HttpException(body, uri: url);
  }
}
