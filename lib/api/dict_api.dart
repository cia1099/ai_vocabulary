import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:ai_vocabulary/model/chat_answer.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:path/path.dart' as p;
import 'package:text2speech/text2speech.dart';

part 'audio_api.dart';

const baseURL = 'www.cia1099.cloudns.ch';
// const baseURL = '127.0.0.1:8000';
const kHttpTimeOut = Duration(seconds: 5);

Future<List<Vocabulary>> retrievalWord(String word) async {
  final url = Uri.http(baseURL, '/dict/retrieval', {'word': word});
  final res = await _httpGet(url);
  if (res.status == 200) {
    return List<Vocabulary>.from(
        json.decode(res.content).map((json) => Vocabulary.fromJson(json)));
  } else {
    throw ApiException(res.content);
  }
}

Future<int> getMaxId() async {
  final url = Uri.http(baseURL, '/dict/words/max_id');
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
  final url = Uri.parse('http://$baseURL$path?$query');
  // final url = Uri.http(baseURL, path, {"id": query});
  final res = await _httpGet(url);
  if (res.status == 200) {
    return List<Vocabulary>.from(
        json.decode(res.content).map((json) => Vocabulary.fromJson(json)));
  } else {
    throw ApiException(res.content);
  }
}

Future<Vocabulary> getWordById(int id) async {
  final url = Uri.http(baseURL, '/dict/word_id/$id');
  final res = await _httpGet(url);
  if (res.status == 200) {
    return Vocabulary.fromRawJson(res.content);
  } else {
    throw ApiException(res.content);
  }
}

Future<ChatAnswer> chatVocabulary(String vocabulary, String text,
    [bool isHelp = false]) async {
  final url = Uri.http(baseURL, '/dict/chat/$vocabulary');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'text': text, 'is_help': isHelp});
  final res =
      await http.post(url, headers: headers, body: body).timeout(kHttpTimeOut);
  if (res.statusCode == 200) {
    return ChatAnswer.fromRawJson(res.body);
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<ApiResponse> _httpGet(Uri url) async {
  try {
    final res = await http.get(url).timeout(kHttpTimeOut);
    if (res.statusCode != 200) {
      throw HttpException(res.body, uri: url);
    }
    return ApiResponse.fromRawJson(res.body);
  } catch (_) {
    rethrow;
  }
  // on TimeoutException {
  //   rethrow;
  // }
  // on http.ClientException catch (e) {
  //   throw TimeoutException(e.message);
  // }
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
  final ids = [1, 2, 3, 4, 5];
  final query = ids.map((id) => 'id=$id').join(r'&');
  const path = '/dict/words';
  final url = Uri.parse('https://$baseURL$path?$query');
  final url2 = Uri.http(baseURL, path + r'_?' + query);
  print(url.query);
  print(url2.path);
}
