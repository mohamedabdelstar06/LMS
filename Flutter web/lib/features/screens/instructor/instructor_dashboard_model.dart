class InstructorDashboardModel {
  final int totalCourses;
  final int totalStudents;
  final int totalActivities;
  final List<InstructorRecentCourse> recentCourses;
  final List<InstructorRecentActivity> recentActivities;
  final List<InstructorRecentSubmission> recentSubmissions;
  final List<InstructorWeeklyEngagement> weeklyEngagement;

  InstructorDashboardModel({
    required this.totalCourses,
    required this.totalStudents,
    required this.totalActivities,
    required this.recentCourses,
    required this.recentActivities,
    required this.recentSubmissions,
    required this.weeklyEngagement,
  });

  factory InstructorDashboardModel.fromJson(Map<String, dynamic> json) {
    return InstructorDashboardModel(
      totalCourses: json['totalCourses'] as int? ?? 0,
      totalStudents: json['totalStudents'] as int? ?? 0,
      totalActivities: json['totalActivities'] as int? ?? 0,
      recentCourses: (json['recentCourses'] as List<dynamic>? ?? [])
          .map((e) => InstructorRecentCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivities: (json['recentActivities'] as List<dynamic>? ?? [])
          .map((e) => InstructorRecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentSubmissions: (json['recentSubmissions'] as List<dynamic>? ?? [])
          .map((e) => InstructorRecentSubmission.fromJson(e as Map<String, dynamic>))
          .toList(),
      weeklyEngagement: (json['weeklyEngagement'] as List<dynamic>? ?? [])
          .map((e) => InstructorWeeklyEngagement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InstructorRecentCourse {
  final int id;
  final String title;
  final String imageUrl;
  final String departmentName;
  final int enrolledStudentsCount;

  InstructorRecentCourse({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.departmentName,
    required this.enrolledStudentsCount,
  });

  factory InstructorRecentCourse.fromJson(Map<String, dynamic> json) {
    return InstructorRecentCourse(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      departmentName: json['departmentName'] as String? ?? '',
      enrolledStudentsCount: json['enrolledStudentsCount'] as int? ?? 0,
    );
  }
}

class InstructorRecentActivity {
  final int id;
  final String title;
  final String courseTitle;
  final DateTime createdAt;
  final String description;
  final bool isVisible;
  final String? startDate;
  final String? deadLineDate;

  InstructorRecentActivity({
    required this.id,
    required this.title,
    required this.courseTitle,
    required this.createdAt,
    required this.description,
    required this.isVisible,
    this.startDate,
    this.deadLineDate,
  });

  factory InstructorRecentActivity.fromJson(Map<String, dynamic> json) {
    return InstructorRecentActivity(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      courseTitle: json['courseTitle'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      description: json['description'] as String? ?? '',
      isVisible: json['isVisible'] as bool? ?? false,
      startDate: json['startDate'] as String?,
      deadLineDate: json['deadLineDate'] as String?,
    );
  }
}

class InstructorRecentSubmission {
  final int id;
  final String studentName;
  final String activityTitle;
  final String courseTitle;
  final DateTime submittedAt;

  InstructorRecentSubmission({
    required this.id,
    required this.studentName,
    required this.activityTitle,
    required this.courseTitle,
    required this.submittedAt,
  });

  factory InstructorRecentSubmission.fromJson(Map<String, dynamic> json) {
    return InstructorRecentSubmission(
      id: json['id'] as int? ?? 0,
      studentName: json['studentName'] as String? ?? '',
      activityTitle: json['activityTitle'] as String? ?? '',
      courseTitle: json['courseTitle'] as String? ?? '',
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class InstructorWeeklyEngagement {
  final String day;
  final int submissions;

  InstructorWeeklyEngagement({
    required this.day,
    required this.submissions,
  });

  factory InstructorWeeklyEngagement.fromJson(Map<String, dynamic> json) {
    return InstructorWeeklyEngagement(
      day: json['day'] as String? ?? '',
      submissions: json['submissions'] as int? ?? 0,
    );
  }
}
