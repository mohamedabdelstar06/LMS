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

class QuizCreating extends QuizState {
  const QuizCreating();
}

class QuizCreated extends QuizState {
  final QuizModel quiz;
  const QuizCreated(this.quiz);
}

class QuizUpdating extends QuizState {
  const QuizUpdating();
}

class QuizUpdated extends QuizState {
  final QuizModel quiz;
  const QuizUpdated(this.quiz);
}

class QuizDeleting extends QuizState {
  const QuizDeleting();
}

class QuizDeleted extends QuizState {
  final int quizId;
  const QuizDeleted(this.quizId);
}

class QuizGenerating extends QuizState {
  const QuizGenerating();
}

class QuizGenerated extends QuizState {
  final QuizModel quiz;
  const QuizGenerated(this.quiz);
}

// ── Take Quiz States ──────────────────────────────────────────
class QuizSessionLoading extends QuizState {
  const QuizSessionLoading();
}

class QuizSessionLoaded extends QuizState {
  final QuizTakeSession session;
  final Map<int, dynamic> answers; // questionId -> answer
  final bool autoSaving;

  const QuizSessionLoaded({
    required this.session,
    required this.answers,
    this.autoSaving = false,
  });

  QuizSessionLoaded copyWith({
    QuizTakeSession? session,
    Map<int, dynamic>? answers,
    bool? autoSaving,
  }) =>
      QuizSessionLoaded(
        session: session ?? this.session,
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

class QuizTranslating extends QuizState {
  const QuizTranslating();
}

class QuizTranslated extends QuizState {
  final QuizModel quiz;
  const QuizTranslated(this.quiz);
}
