// ============================================================
// student_activities_grades_models.dart
// ============================================================

// ── Activity Model ────────────────────────────────────────────
class StudentActivity {
  final int id;
  final String title;
  final String activityType; // Quiz, Assignment, Lecture, etc.
  final String status;       // Completed, Pending, Overdue, etc.
  final String courseTitle;
  final int? courseId;
  final String? dueDate;
  final String? completedAt;
  final double? score;
  final double? maxScore;

  const StudentActivity({
    required this.id,
    required this.title,
    required this.activityType,
    required this.status,
    required this.courseTitle,
    this.courseId,
    this.dueDate,
    this.completedAt,
    this.score,
    this.maxScore,
  });

  factory StudentActivity.fromJson(Map<String, dynamic> j) => StudentActivity(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        activityType: j['activityType'] ?? '',
        status: j['status'] ?? '',
        courseTitle: j['courseTitle'] ?? '',
        courseId: j['courseId'],
        dueDate: j['dueDate'],
        completedAt: j['completedAt'],
        score: j['score'] != null ? (j['score']).toDouble() : null,
        maxScore: j['maxScore'] != null ? (j['maxScore']).toDouble() : null,
      );

  double? get scorePercent =>
      (score != null && maxScore != null && maxScore! > 0)
          ? (score! / maxScore!) * 100
          : null;
}

class StudentActivitiesPage {
  final List<StudentActivity> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  const StudentActivitiesPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory StudentActivitiesPage.fromJson(Map<String, dynamic> j) =>
      StudentActivitiesPage(
        items: (j['items'] as List? ?? [])
            .map((e) => StudentActivity.fromJson(e))
            .toList(),
        totalCount: j['totalCount'] ?? 0,
        page: j['page'] ?? 1,
        pageSize: j['pageSize'] ?? 20,
        totalPages: j['totalPages'] ?? 0,
      );
}

// ── Grades Model ──────────────────────────────────────────────
class QuizGradeItem {
  final int quizId;
  final String quizTitle;
  final double score;
  final double maxScore;
  final bool passed;
  final String? submittedAt;

  const QuizGradeItem({
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.maxScore,
    required this.passed,
    this.submittedAt,
  });

  factory QuizGradeItem.fromJson(Map<String, dynamic> j) => QuizGradeItem(
        quizId: j['quizId'] ?? 0,
        quizTitle: j['quizTitle'] ?? '',
        score: (j['score'] ?? 0).toDouble(),
        maxScore: (j['maxScore'] ?? 100).toDouble(),
        passed: j['passed'] ?? false,
        submittedAt: j['submittedAt'],
      );

  double get percent => maxScore > 0 ? (score / maxScore) * 100 : 0;
}

class AssignmentGradeItem {
  final int assignmentId;
  final String assignmentTitle;
  final double score;
  final double maxScore;
  final String status;
  final String? submittedAt;
  final String? feedback;

  const AssignmentGradeItem({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.score,
    required this.maxScore,
    required this.status,
    this.submittedAt,
    this.feedback,
  });

  factory AssignmentGradeItem.fromJson(Map<String, dynamic> j) =>
      AssignmentGradeItem(
        assignmentId: j['assignmentId'] ?? 0,
        assignmentTitle: j['assignmentTitle'] ?? '',
        score: (j['score'] ?? 0).toDouble(),
        maxScore: (j['maxScore'] ?? 100).toDouble(),
        status: j['status'] ?? '',
        submittedAt: j['submittedAt'],
        feedback: j['feedback'],
      );

  double get percent => maxScore > 0 ? (score / maxScore) * 100 : 0;
}

class CourseGrades {
  final int courseId;
  final String courseName;
  final List<QuizGradeItem> quizGrades;
  final List<AssignmentGradeItem> assignmentGrades;

  const CourseGrades({
    required this.courseId,
    required this.courseName,
    required this.quizGrades,
    required this.assignmentGrades,
  });

  factory CourseGrades.fromJson(Map<String, dynamic> j) => CourseGrades(
        courseId: j['courseId'] ?? 0,
        courseName: j['courseName'] ?? '',
        quizGrades: (j['quizGrades'] as List? ?? [])
            .map((e) => QuizGradeItem.fromJson(e))
            .toList(),
        assignmentGrades: (j['assignmentGrades'] as List? ?? [])
            .map((e) => AssignmentGradeItem.fromJson(e))
            .toList(),
      );

  double get overallAverage {
    final all = [
      ...quizGrades.map((e) => e.percent),
      ...assignmentGrades.map((e) => e.percent),
    ];
    if (all.isEmpty) return 0;
    return all.reduce((a, b) => a + b) / all.length;
  }

  double get quizAverage {
    if (quizGrades.isEmpty) return 0;
    return quizGrades.map((e) => e.percent).reduce((a, b) => a + b) /
        quizGrades.length;
  }

  double get assignmentAverage {
    if (assignmentGrades.isEmpty) return 0;
    return assignmentGrades.map((e) => e.percent).reduce((a, b) => a + b) /
        assignmentGrades.length;
  }
}
