part of 'dict_api.dart';

Future<ApiResponse> getPayments([String? lang]) {
  final url = Uri.https(baseURL, '/dict/subscript/prices', {"lang": lang});
  return _httpGet(url);
}

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
