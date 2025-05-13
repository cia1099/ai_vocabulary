part of 'dict_api.dart';

Future<ApiResponse> getPayments([String? lang]) {
  final url = Uri.https(baseURL, '/dict/subscript/prices', {"lang": lang});
  return _httpGet(url);
}
