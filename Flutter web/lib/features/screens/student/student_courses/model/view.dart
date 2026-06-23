class CourseEnrollmentModel {

  CourseEnrollmentModel({
    required this.courseId,
    required this.courseTitle,
    required this.courseDescription,
    required this.imageUrl,
    required this.creditHours,
    required this.enrolledStudentsCount,
    required this.instructorName,
    required this.enrolledAt,
  });

  factory CourseEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return CourseEnrollmentModel(
      courseId: json['courseId'],
      courseTitle: json['courseTitle'],
      courseDescription: json['courseDescription'],
      imageUrl: json['imageUrl'],
      creditHours: json['creditHours'],
      enrolledStudentsCount: json['enrolledStudentsCount'],
      instructorName: json['instructorName'],
      enrolledAt: DateTime.parse(json['enrolledAt']),
    );
  }
  final int courseId;
  final String courseTitle;
  final String courseDescription;
  final String imageUrl;
  final int creditHours;
  final int enrolledStudentsCount;
  final String instructorName;
  final DateTime enrolledAt;

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseTitle': courseTitle,
      'courseDescription': courseDescription,
      'imageUrl': imageUrl,
      'creditHours': creditHours,
      'enrolledStudentsCount': enrolledStudentsCount,
      'instructorName': instructorName,
      'enrolledAt': enrolledAt.toIso8601String(),
    };
  }
}
