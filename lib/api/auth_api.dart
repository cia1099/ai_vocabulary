part of 'dict_api.dart';

Future<SignInUser> loginFirebaseToken(String token) async {
  final url = Uri.http(baseURL, '/dict/firebase/login');
  final headers = {'Authorization': 'Bearer $token'};
  final res = await _httpGet(url, headers: headers);
  if (res.status == 200) {
    return SignInUser.fromRawJson(res.content);
  } else {
    throw ApiException(res.content);
  }
}

Future<void> registerFirebaseToken({required String token, String? name}) {
  final url = Uri.http(baseURL, '/dict/firebase/register', {"name": name});
  final headers = {'Authorization': 'Bearer $token'};
  return _httpGet(url, headers: headers).then((res) {
    if (res.status != 200) {
      throw ApiException(res.content);
    }
  });
}
