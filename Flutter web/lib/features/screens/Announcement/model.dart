class AnnouncementModel {
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: _parseInt(json['id'] ?? 0),
      title: _parseString(json['title'] ?? ''),
      content: _parseString(json['content'] ?? ''),
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      isPinned: json['isPinned'] is bool
          ? json['isPinned']
          : (json['isPinned']?.toString().toLowerCase() == 'true'),
      audienceType: _parseInt(json['audienceType'] ?? 0),
      departmentId: _parseNullableInt(json['departmentId']),
      departmentName: json['departmentName']?.toString(),
      yearId: _parseNullableInt(json['yearId']),
      yearName: json['yearName']?.toString(),
      squadronId: _parseNullableInt(json['squadronId']),
      squadronName: json['squadronName']?.toString(),
      courseId: _parseNullableInt(json['courseId']),
      courseTitle: json['courseTitle']?.toString(),
      createdByName: json['createdByName'] ?? json['authorName'] ?? 'Unknown',
      createdByRole: json['createdByRole'] ?? json['authorRole'] ?? '',
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      commentsCount: _parseNullableInt(json['commentsCount']),
      viewsCount: _parseNullableInt(json['viewsCount']),
      createdByImageUrl: json['createdByImageUrl']?.toString(),
    );
  }
  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.description,
    this.imageUrl,
    this.startDate,
    this.endDate,
    required this.isPinned,
    required this.audienceType,
    this.departmentId,
    this.departmentName,
    this.yearId,
    this.yearName,
    this.squadronId,
    this.squadronName,
    this.courseId,
    this.courseTitle,
    required this.createdByName,
    required this.createdByRole,
    required this.createdAt,
    this.commentsCount,
    this.viewsCount, this.createdByImageUrl,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static String _parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  final int id;
  final String title;
  final String content;
  final String? description;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isPinned;
  final int audienceType;
  final int? departmentId;
  final String? departmentName;
  final int? yearId;
  final String? yearName;
  final int? squadronId;
  final String? squadronName;
  final int? courseId;
  final String? courseTitle;
  final String createdByName;
  final String createdByRole;
  final DateTime createdAt;
  final int? commentsCount;
  final int? viewsCount;
  final String? createdByImageUrl;


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isPinned': isPinned,
      'audienceType': audienceType,
      'departmentId': departmentId,
      'yearId': yearId,
      'squadronId': squadronId,
      'courseId': courseId,
      'createdByName': createdByName,
      'createdByRole': createdByRole,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AnnouncementsResponse {
  AnnouncementsResponse({
    required this.items,
    required this.pageIndex,
    required this.totalPages,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory AnnouncementsResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementsResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageIndex: json['pageIndex'] ?? 1,
      totalPages: json['totalPages'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }

  final List<AnnouncementModel> items;
  final int pageIndex;
  final int totalPages;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;
}

/// AudienceType enum mapping
enum AnnouncementAudienceType {
  all(0, 'All'),
  department(1, 'Department'),
  year(2, 'Year'),
  squadron(3, 'Squadron'),
  course(4, 'Course');

  const AnnouncementAudienceType(this.value, this.label);
  final int value;
  final String label;

  static AnnouncementAudienceType fromValue(int value) {
    return AnnouncementAudienceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnnouncementAudienceType.all,
    );
  }
}
