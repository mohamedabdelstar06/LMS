class LectureModel {
  const LectureModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.contentType,
    required this.fileUrl,
    this.additionalFileUrls,
    this.thumbnailUrl,
    required this.hasSummary,
    required this.hasTranscript,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    this.updatedAt,
    this.isViewed,
    this.viewedAt,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'] ?? 0,
      courseId: json['courseId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      contentType: json['contentType'] ?? 'Pdf',
      fileUrl: json['fileUrl'] ?? '',
      additionalFileUrls: json['additionalFileUrls'] != null
          ? List<String>.from(json['additionalFileUrls'])
          : null,
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      hasSummary: json['hasSummary'] ?? false,
      hasTranscript: json['hasTranscript'] ?? false,
      createdById: json['createdById'] ?? 0,
      createdByName: json['createdByName'] ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? _parseDate(json['updatedAt'])
          : null,
      isViewed: json['isViewed'],
      viewedAt:
      json['viewedAt'] != null ? _parseDate(json['viewedAt']) : null,
    );
  }

  final int id;
  final int courseId;
  final String title;
  final String description;
  final String contentType;
  final String fileUrl;
  final List<String>? additionalFileUrls;
  final String? thumbnailUrl;
  final bool hasSummary;
  final bool hasTranscript;
  final int createdById;
  final String createdByName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool? isViewed;
  final DateTime? viewedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'title': title,
    'description': description,
    'contentType': contentType,
    'fileUrl': fileUrl,
    'additionalFileUrls': additionalFileUrls,
    'thumbnailUrl': thumbnailUrl,
    'hasSummary': hasSummary,
    'hasTranscript': hasTranscript,
    'createdById': createdById,
    'createdByName': createdByName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isViewed': isViewed,
    'viewedAt': viewedAt?.toIso8601String(),
  };
}

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}