part of 'dict_api.dart';

Future<ApiResponse> writeToCloud(String sqlQuery) async {
  final url = Uri.http(baseURL, '/dict/supabase/write');
  final accessToken = UserProvider().currentUser?.accessToken;
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'text/plain',
      'Authorization': 'Bearer $accessToken',
    },
    body: sqlQuery,
  );
  if (response.statusCode == 200) {
    return ApiResponse.fromRawJson(response.body);
  } else if (response.statusCode == 406) {
    return ApiResponse(status: 406, content: response.body);
  } else {
    throw HttpException(response.body, uri: url);
  }
}
