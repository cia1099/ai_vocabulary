part of 'dict_api.dart';

Future<SignInUser> loginFirebaseToken(String token) async {
  final url = Uri.https(baseURL, '/dict/firebase/login');
  final headers = {'Authorization': 'Bearer $token'};
  final res = await _httpGet(url, headers: headers);
  if (res.status == 200) {
    return SignInUser.fromRawJson(res.content);
  } else {
    throw ApiException(res.content);
  }
}

Future<void> registerFirebaseToken({required String token, String? name}) {
  final url = Uri.https(baseURL, '/dict/firebase/register', {"name": name});
  final headers = {'Authorization': 'Bearer $token'};
  return _httpGet(url, headers: headers).then((res) {
    if (res.status != 200) {
      throw ApiException(res.content);
    }
  });
}

Future<void> deleteFirebaseAccount() async {
  final url = Uri.https(baseURL, '/dict/firebase/delete');
  final currentUser = UserProvider().currentUser;
  final headers = {'uid': '${currentUser?.uid}'};
  final res = await http.delete(url, headers: headers);
  if (res.statusCode != 200) {
    throw HttpException(res.body, uri: url);
  }
}

Future<void> checkExpire(String accessToken) async {
  final url = Uri.https(baseURL, '/dict/check/access/token');
  final headers = {'Authorization': 'Bearer $accessToken'};
  return _httpGet(url, headers: headers).then((res) {
    if (res.status != 200) {
      throw ApiException(res.content);
    }
  });
}

Future<double?> getConsumeTokens() async {
  final url = Uri.https(baseURL, '/dict/firebase/consume/token');
  final currentUser = UserProvider().currentUser;
  final accessToken = currentUser?.accessToken;
  final headers = {'Authorization': 'Bearer $accessToken'};
  final res = await _httpGet(url, headers: headers);
  if (res.status == 200) {
    return double.tryParse(res.content);
  } else {
    throw ApiException(res.content);
  }
}
