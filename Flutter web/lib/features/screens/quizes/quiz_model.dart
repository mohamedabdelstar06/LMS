// ============================================================
// quiz_model.dart — matches the real SkyLearn API contract
// ============================================================

// ── Quiz List Item (from GET /courses/{id}/quizzes) ───────────
import 'dart:typed_data';

import 'package:lms/core/helpers/json_list_parser.dart';

class QuizModel {
  const QuizModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.description,
    this.timeLimitMinutes,
    required this.maxAttempts,
    required this.passingScore,
    required this.totalMarks,
    required this.shuffleQuestions,
    required this.shuffleAnswers,
    this.startDate,
    required this.showCorrectAnswers,
    required this.showExplanations,
    required this.isAiGenerated,
    required this.gradingMode,
    required this.quizScope,
    this.difficultyLevel,
    this.deadLineDate,
    this.targetSquadronId,
    this.targetSquadronName,
    required this.questionCount,
    required this.sortOrder,
    required this.isVisible,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
    id: json['id'] as int,
    courseId: json['courseId'] as int,
    courseName: json['courseName'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    timeLimitMinutes: json['timeLimitMinutes'] as int?,
    maxAttempts: json['maxAttempts'] as int? ?? 1,
    passingScore: (json['passingScore'] as num?)?.toDouble() ?? 50.0,
    totalMarks: json['totalMarks'] as int? ?? 0,
    shuffleQuestions: json['shuffleQuestions'] as bool? ?? false,
    shuffleAnswers: json['shuffleAnswers'] as bool? ?? false,
    startDate: json['startDate'] != null
        ? DateTime.tryParse(json['startDate'] as String)
        : null,
    showCorrectAnswers: json['showCorrectAnswers'] as bool? ?? true,
    showExplanations: json['showExplanations'] as bool? ?? true,
    isAiGenerated: json['isAiGenerated'] as bool? ?? false,
    gradingMode: json['gradingMode'] as String? ?? 'Auto',
    quizScope: json['quizScope'] as String? ?? 'Course',
    difficultyLevel: json['difficultyLevel'] as String?,
    deadLineDate: json['deadLineDate'] != null
        ? DateTime.tryParse(json['deadLineDate'] as String)
        : null,
    targetSquadronId: json['targetSquadronId'] as int?,
    targetSquadronName: json['targetSquadronName'] as String?,
    questionCount: json['questionCount'] as int? ?? 0,
    sortOrder: json['sortOrder'] as int? ?? 0,
    isVisible: json['isVisible'] as bool? ?? true,
    createdById: json['createdById'] as int? ?? 0,
    createdByName: json['createdByName'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
  final int id;
  final int courseId;
  final String courseName;
  final String title;
  final String description;
  final int? timeLimitMinutes;
  final int maxAttempts;
  final double passingScore;
  final int totalMarks;
  final bool shuffleQuestions;
  final bool shuffleAnswers;
  final DateTime? startDate;
  final bool showCorrectAnswers;
  final bool showExplanations;
  final bool isAiGenerated;
  final String gradingMode; // "Auto" | "Manual" | "Hybrid"
  final String quizScope; // "Course" | "Lecture" | "Squadron"
  final String? difficultyLevel;
  final DateTime? deadLineDate;
  final int? targetSquadronId;
  final String? targetSquadronName;
  final int questionCount;
  final int sortOrder;
  final bool isVisible;
  final int createdById;
  final String createdByName;
  final DateTime createdAt;

  QuizModel copyWith({
    String? title,
    String? description,
    int? questionCount,
    bool? isVisible,
  }) => QuizModel(
    id: id,
    courseId: courseId,
    courseName: courseName,
    title: title ?? this.title,
    description: description ?? this.description,
    timeLimitMinutes: timeLimitMinutes,
    maxAttempts: maxAttempts,
    passingScore: passingScore,
    totalMarks: totalMarks,
    shuffleQuestions: shuffleQuestions,
    shuffleAnswers: shuffleAnswers,
    startDate: startDate,
    showCorrectAnswers: showCorrectAnswers,
    showExplanations: showExplanations,
    isAiGenerated: isAiGenerated,
    gradingMode: gradingMode,
    quizScope: quizScope,
    difficultyLevel: difficultyLevel,
    deadLineDate: deadLineDate,
    targetSquadronId: targetSquadronId,
    targetSquadronName: targetSquadronName,
    questionCount: questionCount ?? this.questionCount,
    sortOrder: sortOrder,
    isVisible: isVisible ?? this.isVisible,
    createdById: createdById,
    createdByName: createdByName,
    createdAt: createdAt,
  );
}

// ── Question Option (for building/editing) ─────────────────────
class QuestionOptionInput {
  QuestionOptionInput({
    this.optionText = '',
    this.isCorrect = false,
    this.sortOrder = 0,
  });
  String optionText;
  bool isCorrect;
  int sortOrder;

  Map<String, dynamic> toJson() => {
    'optionText': optionText,
    'isCorrect': isCorrect,
    'sortOrder': sortOrder,
  };
}

// ── Question (for building/editing) ─────────────────────────────
class QuestionInput {
  QuestionInput({
    this.questionText = '',
    this.questionType = 'SingleChoice',
    this.marks = 1,
    this.difficultyLevel = 'Medium',
    this.explanation = '',
    this.sourceReference = '',
    this.sortOrder = 0,
    List<QuestionOptionInput>? options,
  }) : options =
           options ??
           [QuestionOptionInput(), QuestionOptionInput(sortOrder: 1)];
  String questionText;
  String
  questionType; // "SingleChoice" | "MultipleChoice" | "TrueFalse" | "ShortAnswer"
  int marks;
  String difficultyLevel; // "Easy" | "Medium" | "Hard"
  String explanation;
  String sourceReference;
  int sortOrder;
  List<QuestionOptionInput> options;

  Map<String, dynamic> toJson() {
    final json = {
      'questionText': questionText,
      'questionType': questionType,
      'marks': marks,
      'difficultyLevel': difficultyLevel,
      'explanation': explanation,
      'sourceReference': sourceReference,
      'sortOrder': sortOrder,
    };

    if (questionType != 'ShortAnswer') {
      json['options'] = options.map((o) => o.toJson()).toList();
    }

    return json;
  }
}

// ── Create/Update Quiz Request body ─────────────────────────────
class QuizFormData {
  QuizFormData({
    this.title = '',
    this.description = '',
    this.timeLimitMinutes,
    this.maxAttempts = 1,
    this.passingScore = 50,
    this.shuffleQuestions = false,
    this.shuffleAnswers = false,
    this.startDate,
    this.showCorrectAnswers = true,
    this.showExplanations = true,
    this.gradingMode = 'Auto',
    this.deadLineDate,
    this.targetSquadronId,
    this.difficultyLevel,
    this.sortOrder = 0,
    this.isVisible = true,
    List<QuestionInput>? questions,
  }) : questions = questions ?? [];
  String title;
  String description;
  int? timeLimitMinutes;
  int maxAttempts;
  double passingScore;
  bool shuffleQuestions;
  bool shuffleAnswers;
  DateTime? startDate;
  bool showCorrectAnswers;
  bool showExplanations;
  String gradingMode;
  DateTime? deadLineDate;
  int? targetSquadronId;
  String? difficultyLevel;
  int sortOrder;
  bool isVisible;
  List<QuestionInput> questions;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'timeLimitMinutes': timeLimitMinutes ?? 0,
    'maxAttempts': maxAttempts,
    'passingScore': passingScore,
    'shuffleQuestions': shuffleQuestions,
    'shuffleAnswers': shuffleAnswers,
    if (startDate != null) 'startDate': startDate!.toUtc().toIso8601String(),
    'showCorrectAnswers': showCorrectAnswers,
    'showExplanations': showExplanations,
    'gradingMode': gradingMode,
    if (deadLineDate != null)
      'deadLineDate': deadLineDate!.toUtc().toIso8601String(),
    'targetSquadronId': targetSquadronId,
    'difficultyLevel': difficultyLevel ?? '',
    'sortOrder': sortOrder,
    'isVisible': isVisible,
    'questions': questions.map((q) => q.toJson()).toList(),
  };
}

// ── Generate Quiz with AI Request ───────────────────────────────
class GenerateQuizRequest {
  const GenerateQuizRequest({
    required this.courseId,
    this.lectureIds = const [],
    this.importedPdfPath,
    this.importedPdfBytes,
    this.importedPdfName,
    required this.questionTypes,
    required this.numberOfQuestions,
    required this.difficultyLevel,
    this.customPrompt = '',
    required this.quizScope,
    this.targetSquadronId,
    required this.title,
  });
  final int courseId;
  final List<int> lectureIds;
  final String? importedPdfPath;
  final Uint8List? importedPdfBytes;
  final String? importedPdfName;
  final String questionTypes; // e.g. "SingleChoice" | "Mixed" | "TrueFalse"
  final int numberOfQuestions;
  final String difficultyLevel; // "Easy" | "Medium" | "Hard"
  final String customPrompt;
  final String quizScope; // "Course" | "Lecture" | "Squadron"
  final int? targetSquadronId;
  final String title;
}

// ── Quiz Detail (full, with questions) — GET /quizzes/{id} ──────
class QuizDetailModel {
  const QuizDetailModel({required this.quiz, required this.questions});

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) =>
      QuizDetailModel(
        quiz: QuizModel.fromJson(
          (json['quiz'] as Map<String, dynamic>?) ?? json,
        ),
        questions: parseJsonObjectList(
          json['questions'] ?? json['data'] ?? json['results'] ?? json['items'],
        ).map(QuestionDetailModel.fromJson).toList(),
      );
  final QuizModel quiz;
  final List<QuestionDetailModel> questions;
}

class QuestionDetailModel {
  const QuestionDetailModel({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.marks,
    this.difficultyLevel,
    this.explanation,
    this.sourceReference,
    required this.sortOrder,
    required this.options,
  });

  factory QuestionDetailModel.fromJson(Map<String, dynamic> json) =>
      QuestionDetailModel(
        id: json['id'] as int,
        questionText: json['questionText'] as String? ?? '',
        questionType: json['questionType'] as String? ?? 'SingleChoice',
        marks: json['marks'] as int? ?? 1,
        difficultyLevel: json['difficultyLevel'] as String?,
        explanation: json['explanation'] as String?,
        sourceReference: json['sourceReference'] as String?,
        sortOrder: json['sortOrder'] as int? ?? 0,
        options: parseJsonObjectList(
          json['options'] ?? json['data'] ?? json['results'] ?? json['items'],
        ).map(OptionDetailModel.fromJson).toList(),
      );
  final int id;
  final String questionText;
  final String questionType;
  final int marks;
  final String? difficultyLevel;
  final String? explanation;
  final String? sourceReference;
  final int sortOrder;
  final List<OptionDetailModel> options;
}

class OptionDetailModel {
  const OptionDetailModel({
    required this.id,
    required this.optionText,
    this.isCorrect,
    required this.sortOrder,
  });

  factory OptionDetailModel.fromJson(Map<String, dynamic> json) =>
      OptionDetailModel(
        id: json['id'] as int,
        optionText: json['optionText'] as String? ?? '',
        isCorrect: json['isCorrect'] as bool?,
        sortOrder: json['sortOrder'] as int? ?? 0,
      );
  final int id;
  final String optionText;
  final bool? isCorrect; // hidden from students typically
  final int sortOrder;
}

// ── Take Quiz Session — GET /quizzes/{id}/take ──────────────────
class QuizTakeSession {
  const QuizTakeSession({
    required this.quizId,
    required this.title,
    required this.description,
    this.timeLimitMinutes,
    required this.questions,
  });

  factory QuizTakeSession.fromJson(Map<String, dynamic> json) =>
      QuizTakeSession(
        quizId: json['id'] as int? ?? json['quizId'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        timeLimitMinutes: json['timeLimitMinutes'] as int?,
        questions: parseJsonObjectList(
          json['questions'] ?? json['data'] ?? json['results'] ?? json['items'],
        ).map(QuestionDetailModel.fromJson).toList(),
      );
  final int quizId;
  final String title;
  final String description;
  final int? timeLimitMinutes;
  final List<QuestionDetailModel> questions;
}

// ── Answer (used in auto-save & submit) ──────────────────────────
class QuizAnswer {
  const QuizAnswer({
    required this.questionId,
    this.selectedOptionId,
    this.writtenAnswer,
    this.isFlagged = false,
  });
  final int questionId;
  final int? selectedOptionId;
  final String? writtenAnswer;
  final bool isFlagged;

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

  QuizAnswer copyWith({
    int? selectedOptionId,
    String? writtenAnswer,
    bool? isFlagged,
  }) => QuizAnswer(
    questionId: questionId,
    selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    writtenAnswer: writtenAnswer ?? this.writtenAnswer,
    isFlagged: isFlagged ?? this.isFlagged,
  );
}

// ── Quiz Result — GET /quizzes/{id}/my-result ────────────────────
class QuizResult {
  const QuizResult({
    required this.attemptId,
    required this.quizId,
    required this.quizTitle,
    this.studentName,
    required this.score,
    required this.passingScore,
    required this.passed,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalMarks,
    required this.earnedMarks,
    this.timeTakenSeconds,
    this.submittedAt,
    required this.gradingMode,
    required this.isFullyGraded,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    attemptId: json['attemptId'] as int? ?? json['id'] as int? ?? 0,
    quizId: json['quizId'] as int? ?? 0,
    quizTitle: json['quizTitle'] as String? ?? '',
    studentName:
        json['studentName'] as String? ??
        json['userName'] as String? ??
        json['fullName'] as String?,
    score: (json['score'] as num?)?.toDouble() ?? 0,
    passingScore: (json['passingScore'] as num?)?.toDouble() ?? 50,
    passed: json['passed'] as bool? ?? false,
    totalQuestions: json['totalQuestions'] as int? ?? 0,
    correctAnswers: json['correctAnswers'] as int? ?? 0,
    totalMarks: json['totalMarks'] as int? ?? 0,
    earnedMarks: json['earnedMarks'] as int? ?? 0,
    timeTakenSeconds: json['timeTakenSeconds'] as int?,
    submittedAt: json['submittedAt'] != null
        ? DateTime.tryParse(json['submittedAt'] as String)
        : null,
    gradingMode: json['gradingMode'] as String? ?? 'Auto',
    isFullyGraded: json['isFullyGraded'] as bool? ?? true,
  );
  final int attemptId;
  final int quizId;
  final String quizTitle;
  final String? studentName;
  final double score;
  final double passingScore;
  final bool passed;
  final int totalQuestions;
  final int correctAnswers;
  final int totalMarks;
  final int earnedMarks;
  final int? timeTakenSeconds;
  final DateTime? submittedAt;
  final String gradingMode;
  final bool isFullyGraded;
}

// ── Student Answer for grading (admin grade view) ─────────────────
class StudentAnswerForGrading {
  StudentAnswerForGrading({
    required this.studentAnswerId,
    required this.studentName,
    required this.questionText,
    this.writtenAnswer,
    required this.maxMarks,
    this.marksAwarded,
    this.feedback,
  });

  factory StudentAnswerForGrading.fromJson(Map<String, dynamic> json) =>
      StudentAnswerForGrading(
        studentAnswerId: json['studentAnswerId'] as int,
        studentName: json['studentName'] as String? ?? '',
        questionText: json['questionText'] as String? ?? '',
        writtenAnswer: json['writtenAnswer'] as String?,
        maxMarks: json['maxMarks'] as int? ?? 0,
        marksAwarded: json['marksAwarded'] as int?,
        feedback: json['feedback'] as String?,
      );
  final int studentAnswerId;
  final String studentName;
  final String questionText;
  final String? writtenAnswer;
  final int maxMarks;
  int? marksAwarded;
  String? feedback;

  Map<String, dynamic> toGradeJson() => {
    'studentAnswerId': studentAnswerId,
    'marksAwarded': marksAwarded ?? 0,
    'feedback': feedback ?? '',
  };
}
