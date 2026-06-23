import 'package:lms/features/screens/student/student_courses/student_quiz_model.dart';


abstract class StudentQuizState {}

class StudentQuizInitial extends StudentQuizState {}

// ── List ─────────────────────────────────────────────
class QuizListLoading extends StudentQuizState {}

class QuizListSuccess extends StudentQuizState {
  QuizListSuccess(this.quizzes);
  final List<StudentQuizListItem> quizzes;
}

class QuizListError extends StudentQuizState {
  QuizListError(this.message);
  final String message;
}

// ── Pre-check (deciding whether to resume or start fresh) ────
class QuizPrecheckLoading extends StudentQuizState {}

// ── Taking session ───────────────────────────────────
class QuizSessionLoading extends StudentQuizState {}

class QuizSessionActive extends StudentQuizState {

  QuizSessionActive({
    required this.session,
    required this.answers,
    this.isResumed = false,
    this.isAutoSaving = false,
    this.isSubmitting = false,
  });
  final QuizTakeSession session;
  final Map<int, QuizAnswerDraft> answers;
  final bool isResumed;
  final bool isAutoSaving;
  final bool isSubmitting;

  QuizSessionActive copyWith({
    Map<int, QuizAnswerDraft>? answers,
    bool? isAutoSaving,
    bool? isSubmitting,
  }) {
    return QuizSessionActive(
      session: session,
      answers: answers ?? this.answers,
      isResumed: isResumed,
      isAutoSaving: isAutoSaving ?? this.isAutoSaving,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class QuizSessionError extends StudentQuizState {
  QuizSessionError(this.message);
  final String message;
}

// ── Result ───────────────────────────────────────────
class QuizResultLoading extends StudentQuizState {}

class QuizResultLoaded extends StudentQuizState {
  QuizResultLoaded(this.result);
  final StudentQuizResult result;
}

class QuizResultError extends StudentQuizState {
  QuizResultError(this.message);
  final String message;
}
