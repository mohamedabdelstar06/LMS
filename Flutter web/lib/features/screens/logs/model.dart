class ActivityLog {

  ActivityLog({
    required this.id,
    required this.time,
    required this.userFullName,
    this.affectedUser,
    required this.eventContext,
    required this.component,
    required this.eventName,
    required this.description,
    required this.origin,
    required this.ipAddress,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      time: DateTime.parse(json['time']),
      userFullName: json['userFullName'] ?? '',
      affectedUser: json['affectedUser'],
      eventContext: json['eventContext'] ?? '',
      component: json['component'] ?? '',
      eventName: json['eventName'] ?? '',
      description: json['description'] ?? '',
      origin: json['origin'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
    );
  }
  final int id;
  final DateTime time;
  final String userFullName;
  final String? affectedUser;
  final String eventContext;
  final String component;
  final String eventName;
  final String description;
  final String origin;
  final String ipAddress;
}

class ActivityLogsResponse {

  ActivityLogsResponse({
    required this.logs,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory ActivityLogsResponse.fromJson(Map<String, dynamic> json) {
    return ActivityLogsResponse(
      logs: (json['logs'] as List).map((e) => ActivityLog.fromJson(e)).toList(),
      totalCount: json['totalCount'],
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
      hasPreviousPage: json['hasPreviousPage'],
    );
  }
  final List<ActivityLog> logs;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
}