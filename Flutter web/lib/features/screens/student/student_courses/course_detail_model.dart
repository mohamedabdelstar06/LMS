import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart'
    as admin_courses;

class CourseDetailModel {

  CourseDetailModel({
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
    this.createdAt,
    this.updatedAt,
    required this.lecturesCount,
    required this.quizzesCount,
    required this.assignmentsCount,
    required this.progressPercentage,
    this.lastAccessedAt,
    this.instructor,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
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
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      lecturesCount: json['lecturesCount'] ?? 0,
      quizzesCount: json['quizzesCount'] ?? 0,
      assignmentsCount: json['assignmentsCount'] ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.tryParse(json['lastAccessedAt'])
          : null,
      instructor: json['instructor'] != null
          ? InstructorModel.fromJson(json['instructor'])
          : null,
    );
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int lecturesCount;
  final int quizzesCount;
  final int assignmentsCount;
  final double progressPercentage;
  final DateTime? lastAccessedAt;
  final InstructorModel? instructor;

  /// Bridges this student-facing model to the admin-side [GetCoursesModel]
  /// that `LectureCubit` / `LecturesScreen` expect. Both models come from
  /// the exact same `GET /api/Course/{id}` payload, so this is a 1:1 field
  /// mapping — no data loss, just satisfying a different constructor shape.
  admin_courses.GetCoursesModel toGetCoursesModel() {
    return admin_courses.GetCoursesModel(
      id: id,
      title: title,
      description: description,
      departmentId: departmentId,
      departmentName: departmentName,
      yearId: yearId,
      yearName: yearName,
      creditHours: creditHours,
      enrolledStudentsCount: enrolledStudentsCount,
      imageUrl: imageUrl,
      instructorId: instructorId,
      instructorName: instructorName,
      // GetCoursesModel.createdAt is non-nullable — fall back to "now" in
      // the (unexpected) case the API omitted it, rather than crashing.
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
      lecturesCount: lecturesCount,
      quizzesCount: quizzesCount,
      assignmentsCount: assignmentsCount,
      progressPercentage: progressPercentage,
      lastAccessedAt: lastAccessedAt,
      instructor: instructor?.toAdminInstructorModel(),
    );
  }
}

class InstructorModel {

  InstructorModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.city,
    this.profileImageUrl,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      city: json['city'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
  final int id;
  final String fullName;
  final String email;
  final String? city;
  final String? profileImageUrl;

  /// Maps to the admin-side `InstructorModel` (different class, same name,
  /// defined in admin_courses model.dart) so it can be embedded inside the
  /// converted [admin_courses.GetCoursesModel].
  admin_courses.InstructorModel toAdminInstructorModel() {
    return admin_courses.InstructorModel(
      id: id,
      fullName: fullName,
      email: email,
      city: city,
      profileImageUrl: profileImageUrl,
    );
  }
}
