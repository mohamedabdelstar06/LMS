class CourseGradesOverviewModel {
  const CourseGradesOverviewModel({
    required this.courseId,
    required this.courseName,
    required this.totalStudents,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.students,
  });

  factory CourseGradesOverviewModel.fromJson(Map<String, dynamic> json) {
    return CourseGradesOverviewModel(
      courseId: json['courseId'] ?? 0,
      courseName: json['courseName'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
      students: (json['students'] as List<dynamic>?)
              ?.map((e) => StudentCourseGradeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  final int courseId;
  final String courseName;
  final int totalStudents;
  final int page;
  final int pageSize;
  final int totalPages;
  final List<StudentCourseGradeModel> students;

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'totalStudents': totalStudents,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'students': students.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentCourseGradeModel {
  const StudentCourseGradeModel({
    required this.studentId,
    required this.studentName,
    required this.totalLectures,
    required this.viewedLectures,
    required this.lectureProgressPercent,
    required this.quizGrades,
    required this.assignmentGrades,
  });

  factory StudentCourseGradeModel.fromJson(Map<String, dynamic> json) {
    return StudentCourseGradeModel(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      totalLectures: json['totalLectures'] ?? 0,
      viewedLectures: json['viewedLectures'] ?? 0,
      lectureProgressPercent: (json['lectureProgressPercent'] as num?)?.toDouble() ?? 0.0,
      quizGrades: (json['quizGrades'] as List<dynamic>?)
              ?.map((e) => QuizGradeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      assignmentGrades: (json['assignmentGrades'] as List<dynamic>?)
              ?.map((e) => AssignmentGradeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  final int studentId;
  final String studentName;
  final int totalLectures;
  final int viewedLectures;
  final double lectureProgressPercent;
  final List<QuizGradeModel> quizGrades;
  final List<AssignmentGradeModel> assignmentGrades;

  double get averageQuizPercent {
    if (quizGrades.isEmpty) return 0.0;
    return quizGrades.map((e) => e.scorePercent).reduce((a, b) => a + b) / quizGrades.length;
  }

  double? get averageAssignmentPercent {
    if (assignmentGrades.isEmpty) return null;
    final graded = assignmentGrades.where((e) => e.grade != null).toList();
    if (graded.isEmpty) return null;
    return graded.map((e) => e.gradePercent).reduce((a, b) => a + b) / graded.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'totalLectures': totalLectures,
      'viewedLectures': viewedLectures,
      'lectureProgressPercent': lectureProgressPercent,
      'quizGrades': quizGrades.map((e) => e.toJson()).toList(),
      'assignmentGrades': assignmentGrades.map((e) => e.toJson()).toList(),
    };
  }
}

class QuizGradeModel {
  const QuizGradeModel({
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.maxScore,
    required this.scorePercent,
    required this.status,
    required this.submittedAt,
  });

  factory QuizGradeModel.fromJson(Map<String, dynamic> json) {
    return QuizGradeModel(
      quizId: json['quizId'] ?? 0,
      quizTitle: json['quizTitle'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 0.0,
      scorePercent: (json['scorePercent'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
    );
  }

  final int quizId;
  final String quizTitle;
  final double score;
  final double maxScore;
  final double scorePercent;
  final String status;
  final DateTime? submittedAt;

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'maxScore': maxScore,
      'scorePercent': scorePercent,
      'status': status,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }
}

class AssignmentGradeModel {
  const AssignmentGradeModel({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.grade,
    required this.maxGrade,
    required this.status,
    required this.submittedAt,
  });

  factory AssignmentGradeModel.fromJson(Map<String, dynamic> json) {
    return AssignmentGradeModel(
      assignmentId: json['assignmentId'] ?? 0,
      assignmentTitle: json['assignmentTitle'] ?? '',
      grade: json['grade'] != null ? (json['grade'] as num).toDouble() : null,
      maxGrade: (json['maxGrade'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
    );
  }

  final int assignmentId;
  final String assignmentTitle;
  final double? grade;
  final double maxGrade;
  final String status;
  final DateTime? submittedAt;

  double get gradePercent {
    if (maxGrade == 0 || grade == null) return 0.0;
    return (grade! / maxGrade) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'assignmentTitle': assignmentTitle,
      'grade': grade,
      'maxGrade': maxGrade,
      'status': status,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }
}
