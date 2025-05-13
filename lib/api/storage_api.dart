part of 'dict_api.dart';

Future<ApiResponse> writeToCloud(String sqlQuery) async {
  final url = Uri.https(baseURL, '/dict/supabase/write');
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

Future<ApiResponse> eraseCloud(String sqlQuery) async {
  final url = Uri.https(baseURL, '/dict/supabase/erase');
  final accessToken = UserProvider().currentUser?.accessToken;
  final response = await http.delete(
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

// Future<List<Map<String, dynamic>>> pullFromCloud({
Future<List> pullFromCloud({
  required TableName tableName,
  List<int> excludeIDs = const [],
  int page = 0,
}) async {
  final url = Uri.https(baseURL, '/dict/supabase/pull', {'page': '$page'});
  final accessToken = UserProvider().currentUser?.accessToken;
  final userID = UserProvider().currentUser?.uid;
  final response = await http
      .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'tablename': tableName.name,
          'user_id': userID,
          'exclude_ids': excludeIDs,
        }),
      )
      .timeout(kHttpTimeOut);
  if (response.statusCode == 200) {
    final res = ApiResponse.fromRawJson(response.body);
    return jsonDecode(res.content);
  } else if (response.statusCode == 406) {
    return [];
  } else {
    throw HttpException(response.body, uri: url);
  }
}
