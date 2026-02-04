class GetCourseModel {
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

  factory GetCourseModel.fromJson(Map<String, dynamic> json) {
    return GetCourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      yearId: json['yearId'],
      yearName: json['yearName'],
      creditHours: json['creditHours'],
      enrolledStudentsCount: json['enrolledStudentsCount'],
      imageUrl: json['imageUrl'],
      instructorId: json['instructorId'],
      instructorName: json['instructorName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

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