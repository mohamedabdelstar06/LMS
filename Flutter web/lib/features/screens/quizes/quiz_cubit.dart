// ============================================================
// quiz_cubit.dart
// ============================================================
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';
import 'package:lms/features/screens/quizes/quiz_repository.dart';

import 'quiz_state.dart';

enum UserRole { admin, student }

class QuizCubit extends Cubit<QuizState> {
  final QuizRepository _repo;
  final int courseId;
  final UserRole role;

  List<QuizModel> _quizzes = [];
  Timer? _autoSaveTimer;
  int? _activeQuizId;

  QuizCubit({
    required QuizRepository repository,
    required this.courseId,
    this.role = UserRole.admin,
  })  : _repo = repository,
        super(const QuizInitial());

  List<QuizModel> get quizzes => _quizzes;
  int get quizCount => _quizzes.length;

  // ── Load quizzes list ────────────────────────────────────
  Future<void> loadQuizzes() async {
    emit(const QuizLoading());
    try {
      _quizzes = await _repo.getCourseQuizzes(courseId);
      emit(QuizLoaded(_quizzes));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }
  // ── Grade quiz (manual grading for short answers) ────────────
  Future<bool> gradeQuiz({
    required int quizId,
    required List<StudentAnswerForGrading> grades,
  }) async {
    emit(const QuizActionInProgress('Submitting grades...'));
    try {
      await _repo.gradeQuiz(quizId: quizId, grades: grades);
      emit(const QuizActionSuccess('Grades submitted successfully'));
      emit(QuizLoaded(_quizzes));
      return true;
    } catch (e) {
      emit(QuizError(_parseError(e)));
      emit(QuizLoaded(_quizzes));
      return false;
    }
  }

  // ── Create quiz (manual, with questions) ──────────────────
  Future<bool> createQuiz(QuizFormData data) async {
    emit(const QuizActionInProgress('Creating quiz...'));
    try {
      final quiz = await _repo.createQuiz(courseId: courseId, data: data);
      _quizzes = [quiz, ..._quizzes];
      emit(QuizActionSuccess('Quiz "${quiz.title}" created successfully'));
      emit(QuizLoaded(_quizzes));
      return true;
    } catch (e) {
      emit(QuizError(_parseError(e)));
      emit(QuizLoaded(_quizzes));
      return false;
    }
  }

  // ── Load full quiz detail (for edit) ───────────────────────
  Future<QuizDetailModel?> loadQuizDetail(int quizId) async {
    emit(const QuizDetailLoading());
    try {
      final detail = await _repo.getQuizById(quizId);
      emit(QuizDetailLoaded(detail));
      return detail;
    } catch (e) {
      emit(QuizError(_parseError(e)));
      return null;
    }
  }

  // ── Update quiz ─────────────────────────────────────────────
  Future<bool> updateQuiz({
    required int quizId,
    required QuizFormData data,
  }) async {
    emit(const QuizActionInProgress('Saving changes...'));
    try {
      final updated = await _repo.updateQuiz(quizId: quizId, data: data);
      _quizzes = _quizzes.map((q) => q.id == quizId ? updated : q).toList();
      emit(QuizActionSuccess('Quiz updated successfully'));
      emit(QuizLoaded(_quizzes));
      return true;
    } catch (e) {
      emit(QuizError(_parseError(e)));
      emit(QuizLoaded(_quizzes));
      return false;
    }
  }

  // ── Delete quiz ──────────────────────────────────────────────
  Future<bool> deleteQuiz(int quizId) async {
    emit(const QuizActionInProgress('Deleting quiz...'));
    try {
      await _repo.deleteQuiz(quizId);
      _quizzes = _quizzes.where((q) => q.id != quizId).toList();
      emit(const QuizActionSuccess('Quiz deleted permanently'));
      emit(QuizLoaded(_quizzes));
      return true;
    } catch (e) {
      emit(QuizError(_parseError(e)));
      emit(QuizLoaded(_quizzes));
      return false;
    }
  }

  // ── Toggle visibility (quick action) ─────────────────────────
  Future<void> toggleVisibility(QuizModel quiz) async {
    final data = QuizFormData(
      title: quiz.title,
      description: quiz.description,
      timeLimitMinutes: quiz.timeLimitMinutes,
      maxAttempts: quiz.maxAttempts,
      passingScore: quiz.passingScore,
      shuffleQuestions: quiz.shuffleQuestions,
      shuffleAnswers: quiz.shuffleAnswers,
      startDate: quiz.startDate,
      showCorrectAnswers: quiz.showCorrectAnswers,
      showExplanations: quiz.showExplanations,
      gradingMode: quiz.gradingMode,
      deadLineDate: quiz.deadLineDate,
      targetSquadronId: quiz.targetSquadronId,
      difficultyLevel: quiz.difficultyLevel,
      sortOrder: quiz.sortOrder,
      isVisible: !quiz.isVisible,
    );
    // optimistic update
    _quizzes = _quizzes
        .map((q) => q.id == quiz.id ? q.copyWith(isVisible: !quiz.isVisible) : q)
        .toList();
    emit(QuizLoaded(_quizzes));
    try {
      await _repo.updateQuiz(quizId: quiz.id, data: data);
    } catch (e) {
      // revert on failure
      _quizzes = _quizzes
          .map((q) => q.id == quiz.id ? q.copyWith(isVisible: quiz.isVisible) : q)
          .toList();
      emit(QuizError(_parseError(e)));
      emit(QuizLoaded(_quizzes));
    }
  }

  // ── Generate quiz with AI (multipart) ──────────────────────
  Future<bool> generateQuiz(GenerateQuizRequest req) async {
    emit(const QuizGenerating(progress: 0));
    try {
      final quiz = await _repo.generateQuiz(
        req,
        onSendProgress: (sent, total) {
          if (total > 0) {
            emit(QuizGenerating(progress: sent / total));
          }
        },
      );
      _quizzes = [quiz, ..._quizzes];
      emit(QuizGenerated(quiz));
      emit(QuizLoaded(_quizzes));
      return true;
    } catch (e) {
      emit(QuizError(_parseError(e)));
      emit(QuizLoaded(_quizzes));
      return false;
    }
  }

  // ── Start taking a quiz (student) ───────────────────────────
  Future<void> startQuiz(int quizId) async {
    emit(const QuizSessionLoading());
    try {
      final session = await _repo.startQuiz(quizId);
      _activeQuizId = quizId;
      final initialAnswers = <int, QuizAnswer>{
        for (final q in session.questions) q.id: QuizAnswer(questionId: q.id),
      };
      emit(QuizSessionLoaded(session: session, answers: initialAnswers));
      _startAutoSave(quizId);
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  void updateAnswer({
    required int questionId,
    int? selectedOptionId,
    String? writtenAnswer,
  }) {
    final current = state;
    if (current is! QuizSessionLoaded) return;
    final existing =
        current.answers[questionId] ?? QuizAnswer(questionId: questionId);
    final updated = existing.copyWith(
      selectedOptionId: selectedOptionId,
      writtenAnswer: writtenAnswer,
    );
    final newAnswers = Map<int, QuizAnswer>.from(current.answers)
      ..[questionId] = updated;
    emit(current.copyWith(answers: newAnswers));
  }

  void toggleFlag(int questionId) {
    final current = state;
    if (current is! QuizSessionLoaded) return;
    final existing =
        current.answers[questionId] ?? QuizAnswer(questionId: questionId);
    final updated = existing.copyWith(isFlagged: !existing.isFlagged);
    final newAnswers = Map<int, QuizAnswer>.from(current.answers)
      ..[questionId] = updated;
    emit(current.copyWith(answers: newAnswers));
  }

  void _startAutoSave(int quizId) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _performAutoSave(quizId),
    );
  }

  Future<void> _performAutoSave(int quizId) async {
    final current = state;
    if (current is! QuizSessionLoaded) return;
    emit(current.copyWith(autoSaving: true));
    try {
      await _repo.autoSave(
        quizId: quizId,
        answers: current.answers.values.toList(),
      );
    } catch (_) {
      // silent fail — will retry next cycle
    } finally {
      if (state is QuizSessionLoaded) {
        emit((state as QuizSessionLoaded).copyWith(autoSaving: false));
      }
    }
  }

  Future<void> submitQuiz() async {
    final current = state;
    if (current is! QuizSessionLoaded || _activeQuizId == null) return;
    _autoSaveTimer?.cancel();
    emit(const QuizSubmitting());
    try {
      final result = await _repo.submitQuiz(
        quizId: _activeQuizId!,
        answers: current.answers.values.toList(),
      );
      emit(QuizResultLoaded(result));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Results (admin: all submissions) ────────────────────────
  Future<void> loadResults(int quizId) async {
    emit(const QuizLoading());
    try {
      final results = await _repo.getQuizResults(quizId);
      emit(QuizResultsLoaded(results));
    } catch (e) {
      emit(QuizError(_parseError(e)));
      emit(QuizLoaded(_quizzes));
    }
  }

  // ── My result (student) ──────────────────────────────────────
  Future<void> loadMyResult(int quizId) async {
    emit(const QuizLoading());
    try {
      final result = await _repo.getMyResult(quizId);
      emit(QuizResultLoaded(result));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Translate ──────────────────────────────────────────────
  Future<void> translateQuiz(int quizId, {String lang = 'ar'}) async {
    emit(const QuizActionInProgress('Translating...'));
    try {
      final detail =
          await _repo.translateQuiz(quizId: quizId, targetLanguage: lang);
      emit(QuizDetailLoaded(detail));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  String _parseError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is Map && data['title'] != null) {
        return data['title'].toString();
      }
      if (e.response?.statusCode == 401) {
        return 'Session expired. Please log in again.';
      }
      if (e.response?.statusCode == 403) {
        return 'You don\'t have permission to do this.';
      }
      if (e.response?.statusCode == 404) {
        return 'Quiz not found.';
      }
      return e.message ?? 'Network error. Please try again.';
    }
    return e.toString();
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}
