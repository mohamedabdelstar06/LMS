import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model.dart';

class ActivityLogsRepository {
  static const String _baseUrl = 'https://skylearn.runasp.net/api/ActivityLogs';

  Future<ActivityLogsResponse> fetchLogs({
    required String token,
    int pageNumber = 1,
    int pageSize = 20,
    String? component,
    String? origin,
    String? search,
  }) async {
    final queryParams = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (component != null && component.isNotEmpty) 'component': component,
      if (origin != null && origin.isNotEmpty) 'origin': origin,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ActivityLogsResponse.fromJson(json);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token expired or invalid.');
    } else {
      throw Exception('Failed to load activity logs: ${response.statusCode}');
    }
  }
}