import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:ai_vocabulary/model/chat_answer.dart';
import 'package:ai_vocabulary/model/phrase.dart';
import 'package:ai_vocabulary/model/user.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:path/path.dart' as p;
import 'package:text2speech/text2speech.dart';

import '../model/audio_player.dart';
import '../utils/enums.dart';

part 'audio_api.dart';
part 'auth_api.dart';
part 'chat_api.dart';

const baseURL = 'www.cia1099.cloudns.ch';
// const baseURL = '127.0.0.1:8000';
const punchCardUrl = "http://$baseURL/dict/imagen/punch/card";
const kHttpTimeOut = Duration(seconds: 5);

Future<List<Vocabulary>> retrievalWord(
  String word, {
  TranslateLocate? locate,
}) async {
  // final url = Uri.http(baseURL, '/dict/retrieval', {'word': word});
  final query = 'word=$word${locate != null ? '&lang=${locate.lang}' : ''}';
  const path = '/dict/retrieval';
  final url = Uri.parse('http://$baseURL$path?$query');
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };
  final res = await _httpGet(url, headers: headers);
  if (res.status == 200) {
    return List<Vocabulary>.from(
      json.decode(res.content).map((json) => Vocabulary.fromJson(json)),
    );
  } else {
    throw ApiException(res.content);
  }
}

Future<List<Vocabulary>> searchWord({
  required String word,
  int page = 0,
}) async {
  final query = 'word=$word&page=$page';
  const path = '/dict/search';
  final url = Uri.parse('http://$baseURL$path?$query');
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };
  final res = await _httpGet(url, headers: headers);
  if (res.status == 200) {
    return List<Vocabulary>.from(
      json.decode(res.content).map((json) => Vocabulary.fromJson(json)),
    );
  } else {
    throw ApiException(res.content);
  }
}

Future<int> getMaxId() async {
  final url = Uri.http(baseURL, '/dict/words/max_id');
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };
  final res = await _httpGet(url, headers: headers);
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
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };
  final res = await _httpGet(url, headers: headers);
  if (res.status == 200) {
    return List<Vocabulary>.from(
      json.decode(res.content).map((json) => Vocabulary.fromJson(json)),
    );
  } else {
    throw ApiException(res.content);
  }
}

Future<Vocabulary> getWordById(int id) async {
  final url = Uri.http(baseURL, '/dict/word_id/$id');
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };
  final res = await _httpGet(url, headers: headers);
  if (res.status == 200) {
    return Vocabulary.fromRawJson(res.content);
  } else {
    throw ApiException(res.content);
  }
}

Future<List<Phrase>> getPhrases(int wordID) async {
  final url = Uri.http(baseURL, '/dict/phrases', {'word_id': '$wordID'});
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };
  final res = await _httpGet(url, headers: headers);
  if (res.status == 200) {
    return List<Phrase>.from(
      json.decode(res.content).map((json) => Phrase.fromJson(json)),
    );
  } else {
    throw ApiException(res.content);
  }
}

Future<String> definitionTranslation(
  int definitionID,
  TranslateLocate locate,
) async {
  final url = Uri.http(baseURL, '/dict/definition/translation');
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
    'Content-Type': 'application/json',
  };
  final res = await http.post(
    url,
    headers: headers,
    body: jsonEncode({"definition_id": definitionID, "lang": locate.lang}),
  );
  if (res.statusCode == 200) {
    return ApiResponse.fromRawJson(utf8.decode(res.bodyBytes)).content;
  } else if (res.statusCode == 403) {
    throw ApiException("Permission deny");
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<AudioPlayer> getAudioPlayer(String audioUrl) async {
  final url = Uri.parse(audioUrl);
  final res = await http.get(url);
  if (res.statusCode == 200) {
    return AudioPlayer(
      bytes: res.bodyBytes,
      mimeType: res.headers['content-type'],
    );
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<ApiResponse> _httpGet(Uri url, {Map<String, String>? headers}) async {
  try {
    final res = await http.get(url, headers: headers).timeout(kHttpTimeOut);
    if (res.statusCode != 200) {
      throw HttpException(res.body, uri: url);
    }
    return ApiResponse.fromRawJson(res.body);
  } catch (e) {
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

  ApiResponse({required this.status, required this.content});

  factory ApiResponse.fromRawJson(String str) =>
      ApiResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      ApiResponse(status: json["status"], content: json["content"]);

  Map<String, dynamic> toJson() => {"status": status, "content": content};
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
