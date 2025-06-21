part of 'dict_api.dart';

Future<String> putSharedApp(String appID) async {
  final url = Uri.https(baseURL, '/dict/share/to/app');
  final headers = {
    "Content-Type": "text/plain",
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };
  final res = await http.put(url, headers: headers, body: appID);
  if (res.statusCode == 200) {
    return ApiResponse.fromRawJson(res.body).content;
  } else {
    throw HttpException(res.body, uri: url);
  }
}

Future<int> getTodayShares() async {
  final url = Uri.https(baseURL, '/dict/today/shares');
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
  };

  final res = await _httpGet(url, headers: headers);
  return int.parse(res.content);
}

Future<SignInUser> updateSubscript(Map<String, dynamic> info) async {
  // final base = "localhost:8000";
  final url = Uri.https(baseURL, '/dict/update/subscript/attributes');
  final headers = {
    "Authorization": "Bearer ${UserProvider().currentUser?.accessToken}",
    "Content-Type": "application/json",
  };
  final res = await http.patch(url, headers: headers, body: jsonEncode(info));
  if (res.statusCode != 200) {
    throw HttpException(res.body, uri: url);
  }
  final body = ApiResponse.fromRawJson(res.body);
  if (body.status != 200) throw ApiException(body.content);
  return SignInUser.fromRawJson(body.content);
}
