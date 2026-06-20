// ============================================================
// student_quiz_model.dart
// Matches the real student-facing endpoints:
//   GET /api/courses/{courseId}/quizzes   -> List<StudentQuizListItem>
//   GET /api/quizzes/{id}/take            -> QuizTakeSession
//   GET /api/quizzes/{id}/my-result       -> StudentQuizResult
//   POST /api/quizzes/{id}/auto-save
//   POST /api/quizzes/{id}/submit
// ============================================================

class StudentQuizListItem {
  final int id;
  final int courseId;
  final String courseName;
  final String title;
  final String description;
  final int? timeLimitMinutes;
  final int maxAttempts;
  final double passingScore;
  final int totalMarks;
  final DateTime? startDate;
  final DateTime? deadLineDate;
  final String? targetSquadronName;
  final int questionCount;
  final bool isVisible;
  final String createdByName;
  final DateTime? createdAt;

  StudentQuizListItem({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.description,
    this.timeLimitMinutes,
    required this.maxAttempts,
    required this.passingScore,
    required this.totalMarks,
    this.startDate,
    this.deadLineDate,
    this.targetSquadronName,
    required this.questionCount,
    required this.isVisible,
    required this.createdByName,
    this.createdAt,
  });

  factory StudentQuizListItem.fromJson(Map<String, dynamic> json) {
    return StudentQuizListItem(
      id: json['id'] ?? 0,
      courseId: json['courseId'] ?? 0,
      courseName: json['courseName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeLimitMinutes: json['timeLimitMinutes'],
      maxAttempts: json['maxAttempts'] ?? 1,
      passingScore: (json['passingScore'] as num?)?.toDouble() ?? 50,
      totalMarks: json['totalMarks'] ?? 0,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      deadLineDate: json['deadLineDate'] != null ? DateTime.tryParse(json['deadLineDate']) : null,
      targetSquadronName: json['targetSquadronName'],
      questionCount: json['questionCount'] ?? 0,
      isVisible: json['isVisible'] ?? true,
      createdByName: json['createdByName'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  bool get hasStarted => startDate == null || DateTime.now().isAfter(startDate!);
  bool get hasEnded => deadLineDate != null && DateTime.now().isAfter(deadLineDate!);
  bool get isAvailableNow => hasStarted && !hasEnded;
}

// ── Take Session ────────────────────────────────────────────

class QuizTakeSession {
  final int quizId;
  final String title;
  final String description;
  final int? timeLimitMinutes;
  final int totalMarks;
  final int attemptNumber;
  final List<QuizTakeQuestion> questions;

  QuizTakeSession({
    required this.quizId,
    required this.title,
    required this.description,
    this.timeLimitMinutes,
    required this.totalMarks,
    required this.attemptNumber,
    required this.questions,
  });

  factory QuizTakeSession.fromJson(Map<String, dynamic> json) {
    return QuizTakeSession(
      quizId: json['id'] ?? json['quizId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeLimitMinutes: json['timeLimitMinutes'],
      totalMarks: json['totalMarks'] ?? 0,
      attemptNumber: json['attemptNumber'] ?? 1,
      questions: ((json['questions'] as List?) ?? [])
          .map((q) => QuizTakeQuestion.fromJson(q))
          .toList(),
    );
  }
}

class QuizTakeQuestion {
  final int id;
  final String questionText;
  final String? questionTextAr;
  final String questionType; // SingleChoice | MultipleChoice | TrueFalse | ShortAnswer
  final int marks;
  final int sortOrder;
  final String? imageUrl;
  final List<QuizTakeOption> options;

  QuizTakeQuestion({
    required this.id,
    required this.questionText,
    this.questionTextAr,
    required this.questionType,
    required this.marks,
    required this.sortOrder,
    this.imageUrl,
    required this.options,
  });

  factory QuizTakeQuestion.fromJson(Map<String, dynamic> json) {
    return QuizTakeQuestion(
      id: json['id'] ?? 0,
      questionText: json['questionText'] ?? '',
      questionTextAr: json['questionTextAr'],
      questionType: json['questionType'] ?? 'SingleChoice',
      marks: json['marks'] ?? 1,
      sortOrder: json['sortOrder'] ?? 0,
      imageUrl: json['imageUrl'],
      options: ((json['options'] as List?) ?? [])
          .map((o) => QuizTakeOption.fromJson(o))
          .toList(),
    );
  }
}

class QuizTakeOption {
  final int id;
  final String optionText;
  final String? optionTextAr;
  final int sortOrder;

  QuizTakeOption({
    required this.id,
    required this.optionText,
    this.optionTextAr,
    required this.sortOrder,
  });

  factory QuizTakeOption.fromJson(Map<String, dynamic> json) {
    return QuizTakeOption(
      id: json['id'] ?? 0,
      optionText: json['optionText'] ?? '',
      optionTextAr: json['optionTextAr'],
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}

// ── Answer (auto-save / submit payload) ─────────────────────

class QuizAnswerDraft {
  final int questionId;
  int? selectedOptionId;
  String? writtenAnswer;
  bool isFlagged;

  QuizAnswerDraft({
    required this.questionId,
    this.selectedOptionId,
    this.writtenAnswer,
    this.isFlagged = false,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'writtenAnswer': writtenAnswer ?? '',
        'isFlagged': isFlagged,
      };

  Map<String, dynamic> toSubmitJson() => {
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'writtenAnswer': writtenAnswer ?? '',
      };
}

// ── My Result (also used to detect an in-progress attempt) ───

class StudentQuizResult {
  final int attemptId;
  final int quizId;
  final String quizTitle;
  final int studentId;
  final String studentName;
  final int attemptNumber;
  final double? score;
  final int maxScore;
  final double? scorePercent;
  final String status; // "InProgress" | "Submitted" | "Graded" ...
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int? timeSpentSeconds;
  final List<StudentQuizAnswerResult>? answers;

  StudentQuizResult({
    required this.attemptId,
    required this.quizId,
    required this.quizTitle,
    required this.studentId,
    required this.studentName,
    required this.attemptNumber,
    this.score,
    required this.maxScore,
    this.scorePercent,
    required this.status,
    this.startedAt,
    this.submittedAt,
    this.timeSpentSeconds,
    this.answers,
  });

  factory StudentQuizResult.fromJson(Map<String, dynamic> json) {
    return StudentQuizResult(
      attemptId: json['attemptId'] ?? 0,
      quizId: json['quizId'] ?? 0,
      quizTitle: json['quizTitle'] ?? '',
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      attemptNumber: json['attemptNumber'] ?? 1,
      score: (json['score'] as num?)?.toDouble(),
      maxScore: json['maxScore'] ?? 0,
      scorePercent: (json['scorePercent'] as num?)?.toDouble(),
      status: json['status'] ?? 'InProgress',
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt']) : null,
      submittedAt: json['submittedAt'] != null ? DateTime.tryParse(json['submittedAt']) : null,
      timeSpentSeconds: json['timeSpentSeconds'],
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => StudentQuizAnswerResult.fromJson(a)).toList()
          : null,
    );
  }

  bool get isInProgress => status == 'InProgress';
  bool get isPassed => status == 'Graded' && (scorePercent ?? 0) >= 50;
}

class StudentQuizAnswerResult {
  final int questionId;
  final int? selectedOptionId;
  final String? writtenAnswer;
  final bool? isCorrect;
  final int? marksAwarded;

  StudentQuizAnswerResult({
    required this.questionId,
    this.selectedOptionId,
    this.writtenAnswer,
    this.isCorrect,
    this.marksAwarded,
  });

  factory StudentQuizAnswerResult.fromJson(Map<String, dynamic> json) {
    return StudentQuizAnswerResult(
      questionId: json['questionId'] ?? 0,
      selectedOptionId: json['selectedOptionId'],
      writtenAnswer: json['writtenAnswer'],
      isCorrect: json['isCorrect'],
      marksAwarded: json['marksAwarded'],
    );
  }
}
