part of 'dict_api.dart';

Future<ApiResponse> getPayments([String? lang]) {
  final url = Uri.http(baseURL, '/dict/subscript/prices', {"lang": lang});
  return _httpGet(url);
}
