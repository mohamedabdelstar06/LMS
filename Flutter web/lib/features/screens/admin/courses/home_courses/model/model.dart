class GetCoursesModel {

  factory GetCoursesModel.fromJson(Map<String, dynamic> json) {
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
      lecturesCount: json['lecturesCount'] ?? 0,
      quizzesCount: json['quizzesCount'] ?? 0,
      assignmentsCount: json['assignmentsCount'] ?? 0,
      progressPercentage: json['progressPercentage'] != null
          ? (json['progressPercentage'] as num).toDouble()
          : null,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'])
          : null,

      instructor: json['instructor'] != null
          ? InstructorModel.fromJson(json['instructor'])
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
    this.instructor,
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

  final InstructorModel? instructor;

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
      'instructor': instructor?.toJson(),
    };
  }
}
class InstructorModel {

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      city: json['city'],
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'],
      isActivated: json['isActivated'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }
  InstructorModel({
    this.id,
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.profileImageUrl,
    this.isActive,
    this.isActivated,
    this.createdAt,
    this.lastLoginAt,
  });

  final int? id;
  final String? fullName;
  final String? email;
  final DateTime? dateOfBirth;
  final dynamic gender;
  final String? city;
  final String? profileImageUrl;
  final bool? isActive;
  final bool? isActivated;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'city': city,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'isActivated': isActivated,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}