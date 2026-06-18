import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms/features/screens/admin/Notifications_model.dart';


class NotificationRepository {
  static const String _baseUrl = 'https://skylearn.runasp.net';

  // ── GET /api/notifications ──────────────────────────────────────────────────
  Future<NotificationsResponse> getNotifications({
    required String token,
    int pageNumber = 1,
    int pageSize = 20,
    bool? isRead,
    String? type,
  }) async {
    final queryParams = <String, String>{
      'PageNumber': pageNumber.toString(),
      'PageSize': pageSize.toString(),
    };
    if (isRead != null) queryParams['IsRead'] = isRead.toString();
    if (type != null && type.isNotEmpty) queryParams['Type'] = type;

    final uri = Uri.parse(
      '$_baseUrl/api/notifications',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers(token));

    _checkStatus(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return NotificationsResponse.fromJson(json);
  }

  // ── GET /api/notifications/unread-count ────────────────────────────────────
  Future<int> getUnreadCount({required String token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/notifications/unread-count'),
      headers: _headers(token),
    );

    _checkStatus(response);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['unreadCount'] as int;
  }

  // ── PUT /api/notifications/{id}/read ──────────────────────────────────────
  Future<void> markAsRead({required String token, required int id}) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/notifications/$id/read'),
      headers: _headers(token),
    );
    _checkStatus(response);
  }

  // ── PUT /api/notifications/read-all ───────────────────────────────────────
  Future<void> markAllAsRead({required String token}) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/notifications/read-all'),
      headers: _headers(token),
    );
    _checkStatus(response);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': '*/*',
    'Authorization': 'Bearer $token',
  };

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }
}
