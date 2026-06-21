// ============================================================
// student_activities_grades_models.dart
// ============================================================

// ── Activity Model ────────────────────────────────────────────
class StudentActivity {
  final int id;
  final String title;
  final String activityType;
  final String status;
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

// ── Grades Models ─────────────────────────────────────────────

/// Matches API:
/// { quizId, quizTitle, score, maxScore, scorePercent, status, submittedAt }
class QuizGradeItem {
  final int quizId;
  final String quizTitle;

  /// Nullable — null means the quiz hasn't been submitted/graded yet.
  final double? score;
  final double maxScore;

  /// Nullable — null when status is InProgress (not submitted).
  final double? scorePercent;

  /// e.g. "Graded", "InProgress"
  final String status;
  final String? submittedAt;

  const QuizGradeItem({
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.maxScore,
    required this.scorePercent,
    required this.status,
    this.submittedAt,
  });

  factory QuizGradeItem.fromJson(Map<String, dynamic> j) => QuizGradeItem(
    quizId: j['quizId'] ?? 0,
    quizTitle: j['quizTitle'] ?? '',
    score: j['score'] != null ? (j['score'] as num).toDouble() : null,
    maxScore: (j['maxScore'] as num? ?? 100).toDouble(),
    scorePercent: j['scorePercent'] != null
        ? (j['scorePercent'] as num).toDouble()
        : null,
    status: j['status'] ?? '',
    submittedAt: j['submittedAt'],
  );

  /// Returns [scorePercent] if available, otherwise 0.
  double get percent => scorePercent ?? 0;

  bool get isGraded => status == 'Graded';
  bool get isInProgress => status == 'InProgress';

  /// Passed = graded AND score >= 60 % of maxScore.
  bool get passed => isGraded && scorePercent != null && scorePercent! >= 60;
}

/// Matches API:
/// { assignmentId, assignmentTitle, grade, maxGrade, status, submittedAt }
class AssignmentGradeItem {
  final int assignmentId;
  final String assignmentTitle;

  /// Nullable — null means not graded yet.
  final double? grade;
  final double maxGrade;

  /// e.g. "Submitted", "Graded", "Pending"
  final String status;
  final String? submittedAt;
  final String? feedback;

  const AssignmentGradeItem({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.grade,
    required this.maxGrade,
    required this.status,
    this.submittedAt,
    this.feedback,
  });

  factory AssignmentGradeItem.fromJson(Map<String, dynamic> j) =>
      AssignmentGradeItem(
        assignmentId: j['assignmentId'] ?? 0,
        assignmentTitle: j['assignmentTitle'] ?? '',
        grade: j['grade'] != null ? (j['grade'] as num).toDouble() : null,
        maxGrade: (j['maxGrade'] as num? ?? 100).toDouble(),
        status: j['status'] ?? '',
        submittedAt: j['submittedAt'],
        feedback: j['feedback'],
      );

  /// Percentage (0–100). Returns 0 if not graded yet.
  double get percent =>
      (grade != null && maxGrade > 0) ? (grade! / maxGrade) * 100 : 0;

  bool get isGraded => status == 'Graded';

  /// Passed = graded AND percent >= 60.
  bool get passed => isGraded && percent >= 60;
}

// ── CourseGrades ──────────────────────────────────────────────
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

  // ── Averages consider only graded items ──────────────────────

  double get overallAverage {
    final all = [
      ...quizGrades.where((e) => e.isGraded).map((e) => e.percent),
      ...assignmentGrades.where((e) => e.isGraded).map((e) => e.percent),
    ];
    if (all.isEmpty) return 0;
    return all.reduce((a, b) => a + b) / all.length;
  }

  double get quizAverage {
    final graded = quizGrades.where((e) => e.isGraded).toList();
    if (graded.isEmpty) return 0;
    return graded.map((e) => e.percent).reduce((a, b) => a + b) / graded.length;
  }

  double get assignmentAverage {
    final graded = assignmentGrades.where((e) => e.isGraded).toList();
    if (graded.isEmpty) return 0;
    return graded.map((e) => e.percent).reduce((a, b) => a + b) / graded.length;
  }

  int get pendingQuizzes => quizGrades.where((e) => e.isInProgress).length;

  int get pendingAssignments =>
      assignmentGrades.where((e) => !e.isGraded).length;
}
