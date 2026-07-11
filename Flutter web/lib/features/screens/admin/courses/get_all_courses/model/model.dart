class GetCourseModel {
  factory GetCourseModel.fromJson(Map<String, dynamic> json) {
    return GetCourseModel(
      id: _parseInt(json['id']),
      title: _parseString(json['title']),
      description: _parseString(json['description']),
      departmentId: _parseInt(json['departmentId']),
      departmentName: _parseString(json['departmentName']),
      yearId: _parseInt(json['yearId']),
      yearName: _parseString(json['yearName']),
      creditHours: _parseInt(json['creditHours']),
      enrolledStudentsCount: _parseInt(json['enrolledStudentsCount']),
      imageUrl: _parseString(json['imageUrl']),
      instructorId: _parseInt(json['instructorId']),
      instructorName: _parseString(json['instructorName']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  GetCourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.departmentId,
    required this.departmentName,
    required this.yearId,
    required this.yearName,
    required this.creditHours,
    required this.enrolledStudentsCount,
    required this.imageUrl,
    required this.instructorId,
    required this.instructorName,
    required this.createdAt,
    this.updatedAt,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
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
  final String description;
  final int departmentId;
  final String departmentName;
  final int yearId;
  final String yearName;
  final int creditHours;
  final int enrolledStudentsCount;
  final String imageUrl;
  final int instructorId;
  final String instructorName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'yearId': yearId,
      'yearName': yearName,
      'creditHours': creditHours,
      'enrolledStudentsCount': enrolledStudentsCount,
      'imageUrl': imageUrl,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
