import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;

const baseURL = 'www.cia1099.cloudns.ch';
const timeOut = Duration(seconds: 5);

Future<ApiResponse> retrievalWord(String word) async {
  final url = Uri.https(baseURL, '/dict/retrieval', {'word': word});
  try {
    final res = await http.get(url).timeout(timeOut);
    return ApiResponse.fromRawJson(res.body);
  } on TimeoutException {
    rethrow;
  } on http.ClientException catch (e) {
    throw TimeoutException("$e");
  } catch (e) {
    return ApiResponse(status: 500, content: '$e');
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
  final res = await retrievalWord("shit");
  print(res.toRawJson());
}
