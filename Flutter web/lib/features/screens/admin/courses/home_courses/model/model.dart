class GetCoursesModel {

  factory GetCoursesModel.fromJson(Map<String, dynamic> json) {
    print("Full API Response: $json");

    return GetCoursesModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      departmentId: json['departmentId'] ?? 0,
      departmentName: json['departmentName'] ?? '',
      yearId: json['yearId'] ?? 0,
      yearName: json['yearName'] ?? '',
      creditHours: json['creditHours'] ?? 0,
      enrolledStudentsCount: json['enrolledStudentsCount'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      instructorId: json['instructorId'] ?? 0,
      instructorName: json['instructorName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,

      lecturesCount: (json['lecturesCount'] ?? 0) as int,
      quizzesCount: (json['quizzesCount'] ?? 0) as int,
      assignmentsCount: (json['assignmentsCount'] ?? 0) as int,

      progressPercentage: json['progressPercentage'] != null
          ? (json['progressPercentage'] as num).toDouble()
          : null,

      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'])
          : null,
    );

  }
  GetCoursesModel({
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
    required this.lecturesCount,
    required this.quizzesCount,
    required this.assignmentsCount,
    this.progressPercentage,
    this.lastAccessedAt,
  });
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
  final int lecturesCount;
  final int quizzesCount;
  final int assignmentsCount;
  final double? progressPercentage;
  final DateTime? lastAccessedAt;

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
      'lecturesCount': lecturesCount,
      'quizzesCount': quizzesCount,
      'assignmentsCount': assignmentsCount,
      'progressPercentage': progressPercentage,
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    };
  }
}