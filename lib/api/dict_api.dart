import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:http/http.dart' as http;
import 'package:text2speech/text2speech.dart';

const baseURL = 'www.cia1099.cloudns.ch';
const timeOut = Duration(seconds: 5);

Future<List<Vocabulary>> retrievalWord(String word) async {
  final url = Uri.https(baseURL, '/dict/retrieval', {'word': word});
  final res = await _httpGet(url);
  if (res.status == 200) {
    return List<Vocabulary>.from(
        json.decode(res.content).map((json) => Vocabulary.fromJson(json)));
  } else {
    throw ApiException(res.content);
  }
}

Future<int> getMaxId() async {
  final url = Uri.https(baseURL, '/dict/words/max_id');
  final res = await _httpGet(url);
  if (res.status == 200) {
    return int.parse(res.content);
  } else {
    throw ApiException(res.content);
  }
}

Future<List<Vocabulary>> getWords(Iterable<int> ids) async {
  final query = ids.map((id) => 'id=$id').join('&');
  const path = '/dict/words';
  final url = Uri.parse('https://$baseURL$path?$query');
  // final url = Uri.https(baseURL, path, {"id": query});
  final res = await _httpGet(url);
  if (res.status == 200) {
    return List<Vocabulary>.from(
        json.decode(res.content).map((json) => Vocabulary.fromJson(json)));
  } else {
    throw ApiException(res.content);
  }
}

Future<Vocabulary> getWordById(int id) async {
  final url = Uri.https(baseURL, '/dict/word_id/$id');
  final res = await _httpGet(url);
  if (res.status == 200) {
    return Vocabulary.fromRawJson(res.content);
  } else {
    throw ApiException(res.content);
  }
}

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

Future<ApiResponse> _httpGet(Uri url) async {
  try {
    final res = await http.get(url).timeout(timeOut);
    if (res.statusCode != 200) {
      throw HttpException(res.body, uri: url);
    }
    return ApiResponse.fromRawJson(res.body);
  } on TimeoutException {
    rethrow;
  } on http.ClientException catch (e) {
    throw TimeoutException("$e");
  } catch (_) {
    rethrow;
  }
}

class ApiResponse {
  final int status;
  final String content;

  ApiResponse({
    required this.status,
    required this.content,
  });

  factory ApiResponse.fromRawJson(String str) =>
      ApiResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        status: json["status"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "content": content,
      };
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);
  @override
  String toString() {
    return message.isEmpty ? "ApiException" : "ApiException: $message";
  }
}

void main() async {
  // final res = await retrievalWord("shit");
  // print(res.toRawJson());
  final word = await getWords([16852 + 1]);
  print(word);
}
