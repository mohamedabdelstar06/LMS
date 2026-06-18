class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? readAt;
  final int? referenceActivityId;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.readAt,
    this.referenceActivityId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      referenceActivityId: json['referenceActivityId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      referenceActivityId: referenceActivityId,
      createdAt: createdAt,
    );
  }
}

class NotificationsResponse {
  final List<NotificationModel> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final int unreadCount;

  const NotificationsResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
      unreadCount: json['unreadCount'] as int,
    );
  }
}
