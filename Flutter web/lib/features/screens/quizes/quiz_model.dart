// ============================================================
// quiz_model.dart
// ============================================================

class QuizModel {
  final int id;
  final String title;
  final String? description;
  final int courseId;
  final int questionsCount;
  final int durationMinutes;
  final double passingScore;
  final bool isPublished;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime createdAt;

  const QuizModel({
    required this.id,
    required this.title,
    this.description,
    required this.courseId,
    required this.questionsCount,
    required this.durationMinutes,
    required this.passingScore,
    required this.isPublished,
    this.startsAt,
    this.endsAt,
    required this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        courseId: json['courseId'] as int,
        questionsCount: json['questionsCount'] as int? ?? 0,
        durationMinutes: json['durationMinutes'] as int? ?? 30,
        passingScore: (json['passingScore'] as num?)?.toDouble() ?? 50.0,
        isPublished: json['isPublished'] as bool? ?? false,
        startsAt: json['startsAt'] != null
            ? DateTime.tryParse(json['startsAt'] as String)
            : null,
        endsAt: json['endsAt'] != null
            ? DateTime.tryParse(json['endsAt'] as String)
            : null,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'courseId': courseId,
        'durationMinutes': durationMinutes,
        'passingScore': passingScore,
        'isPublished': isPublished,
        if (startsAt != null) 'startsAt': startsAt!.toIso8601String(),
        if (endsAt != null) 'endsAt': endsAt!.toIso8601String(),
      };

  QuizModel copyWith({
    int? id,
    String? title,
    String? description,
    int? courseId,
    int? questionsCount,
    int? durationMinutes,
    double? passingScore,
    bool? isPublished,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? createdAt,
  }) =>
      QuizModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        courseId: courseId ?? this.courseId,
        questionsCount: questionsCount ?? this.questionsCount,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        passingScore: passingScore ?? this.passingScore,
        isPublished: isPublished ?? this.isPublished,
        startsAt: startsAt ?? this.startsAt,
        endsAt: endsAt ?? this.endsAt,
        createdAt: createdAt ?? this.createdAt,
      );
}

// ── Quiz Question (for taking) ────────────────────────────────
class QuizQuestion {
  final int id;
  final String text;
  final String type; // 'mcq' | 'true_false' | 'short'
  final List<QuizOption> options;
  final int? points;

  const QuizQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as int,
        text: json['text'] as String,
        type: json['type'] as String? ?? 'mcq',
        options: (json['options'] as List<dynamic>? ?? [])
            .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        points: json['points'] as int?,
      );
}

class QuizOption {
  final int id;
  final String text;

  const QuizOption({required this.id, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      QuizOption(id: json['id'] as int, text: json['text'] as String);
}

// ── Quiz Take Session ─────────────────────────────────────────
class QuizTakeSession {
  final int attemptId;
  final QuizModel quiz;
  final List<QuizQuestion> questions;
  final DateTime startedAt;
  final DateTime endsAt;

  const QuizTakeSession({
    required this.attemptId,
    required this.quiz,
    required this.questions,
    required this.startedAt,
    required this.endsAt,
  });

  factory QuizTakeSession.fromJson(Map<String, dynamic> json) =>
      QuizTakeSession(
        attemptId: json['attemptId'] as int,
        quiz: QuizModel.fromJson(json['quiz'] as Map<String, dynamic>),
        questions: (json['questions'] as List<dynamic>)
            .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        startedAt: DateTime.parse(json['startedAt'] as String),
        endsAt: DateTime.parse(json['endsAt'] as String),
      );
}

// ── Quiz Result ───────────────────────────────────────────────
class QuizResult {
  final int attemptId;
  final double score;
  final double passingScore;
  final bool passed;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTakenSeconds;
  final DateTime submittedAt;

  const QuizResult({
    required this.attemptId,
    required this.score,
    required this.passingScore,
    required this.passed,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTakenSeconds,
    required this.submittedAt,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        attemptId: json['attemptId'] as int,
        score: (json['score'] as num).toDouble(),
        passingScore: (json['passingScore'] as num).toDouble(),
        passed: json['passed'] as bool,
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        timeTakenSeconds: json['timeTakenSeconds'] as int? ?? 0,
        submittedAt: DateTime.parse(json['submittedAt'] as String),
      );
}

// ── Generate Request ──────────────────────────────────────────
class GenerateQuizRequest {
  final int courseId;
  final String topic;
  final int questionsCount;
  final String difficulty; // 'easy' | 'medium' | 'hard'

  const GenerateQuizRequest({
    required this.courseId,
    required this.topic,
    required this.questionsCount,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'topic': topic,
        'questionsCount': questionsCount,
        'difficulty': difficulty,
      };
}
