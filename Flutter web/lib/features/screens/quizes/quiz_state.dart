// ============================================================
// quiz_state.dart
// ============================================================


import 'package:lms/features/screens/quizes/quiz_model.dart';

abstract class QuizState {
  const QuizState();
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizLoaded extends QuizState {
  final List<QuizModel> quizzes;
  const QuizLoaded(this.quizzes);
}

class QuizError extends QuizState {
  final String message;
  const QuizError(this.message);
}

class QuizActionInProgress extends QuizState {
  final String label; // "Creating...", "Deleting...", etc
  const QuizActionInProgress(this.label);
}

class QuizActionSuccess extends QuizState {
  final String message;
  const QuizActionSuccess(this.message);
}

// ── Detail / Edit ──────────────────────────────────────────────
class QuizDetailLoading extends QuizState {
  const QuizDetailLoading();
}

class QuizDetailLoaded extends QuizState {
  final QuizDetailModel detail;
  const QuizDetailLoaded(this.detail);
}

// ── Generate ──────────────────────────────────────────────────
class QuizGenerating extends QuizState {
  final double progress; // 0..1, upload progress
  const QuizGenerating({this.progress = 0});
}

class QuizGenerated extends QuizState {
  final QuizModel quiz;
  const QuizGenerated(this.quiz);
}

// ── Take Quiz ─────────────────────────────────────────────────
class QuizSessionLoading extends QuizState {
  const QuizSessionLoading();
}

class QuizSessionLoaded extends QuizState {
  final QuizTakeSession session;
  final Map<int, QuizAnswer> answers; // questionId -> answer
  final bool autoSaving;

  const QuizSessionLoaded({
    required this.session,
    required this.answers,
    this.autoSaving = false,
  });

  QuizSessionLoaded copyWith({
    Map<int, QuizAnswer>? answers,
    bool? autoSaving,
  }) =>
      QuizSessionLoaded(
        session: session,
        answers: answers ?? this.answers,
        autoSaving: autoSaving ?? this.autoSaving,
      );
}

class QuizSubmitting extends QuizState {
  const QuizSubmitting();
}

class QuizResultLoaded extends QuizState {
  final QuizResult result;
  const QuizResultLoaded(this.result);
}

class QuizResultsLoaded extends QuizState {
  final List<QuizResult> results;
  const QuizResultsLoaded(this.results);
}

// ── Grading ───────────────────────────────────────────────────
class QuizGradingLoaded extends QuizState {
  final List<StudentAnswerForGrading> answers;
  const QuizGradingLoaded(this.answers);
}
