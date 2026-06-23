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
  const QuizLoaded(this.quizzes);
  final List<QuizModel> quizzes;
}

class QuizError extends QuizState {
  const QuizError(this.message);
  final String message;
}

class QuizActionInProgress extends QuizState { // "Creating...", "Deleting...", etc
  const QuizActionInProgress(this.label);
  final String label;
}

class QuizActionSuccess extends QuizState {
  const QuizActionSuccess(this.message);
  final String message;
}

// ── Detail / Edit ──────────────────────────────────────────────
class QuizDetailLoading extends QuizState {
  const QuizDetailLoading();
}

class QuizDetailLoaded extends QuizState {
  const QuizDetailLoaded(this.detail);
  final QuizDetailModel detail;
}

// ── Generate ──────────────────────────────────────────────────
class QuizGenerating extends QuizState { // 0..1, upload progress
  const QuizGenerating({this.progress = 0});
  final double progress;
}

class QuizGenerated extends QuizState {
  const QuizGenerated(this.quiz);
  final QuizModel quiz;
}

// ── Take Quiz ─────────────────────────────────────────────────
class QuizSessionLoading extends QuizState {
  const QuizSessionLoading();
}

class QuizSessionLoaded extends QuizState {

  const QuizSessionLoaded({
    required this.session,
    required this.answers,
    this.autoSaving = false,
  });
  final QuizTakeSession session;
  final Map<int, QuizAnswer> answers; // questionId -> answer
  final bool autoSaving;

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
  const QuizResultLoaded(this.result);
  final QuizResult result;
}

class QuizResultsLoaded extends QuizState {
  const QuizResultsLoaded(this.results);
  final List<QuizResult> results;
}

// ── Grading ───────────────────────────────────────────────────
class QuizGradingLoaded extends QuizState {
  const QuizGradingLoaded(this.answers);
  final List<StudentAnswerForGrading> answers;
}
