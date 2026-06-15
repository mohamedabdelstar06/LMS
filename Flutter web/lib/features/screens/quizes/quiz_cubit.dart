// ============================================================
// quiz_cubit.dart
// ============================================================
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';
import 'package:lms/features/screens/quizes/quiz_repository.dart';

import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizRepository _repo;
  final int courseId;

  List<QuizModel> _quizzes = [];
  Timer? _autoSaveTimer;
  int? _activeQuizId;

  QuizCubit({required QuizRepository repository, required this.courseId})
      : _repo = repository,
        super(const QuizInitial());

  List<QuizModel> get quizzes => _quizzes;
  int get quizCount => _quizzes.length;

  // ── Load quizzes ──────────────────────────────────────────
  Future<void> loadQuizzes() async {
    emit(const QuizLoading());
    try {
      _quizzes = await _repo.getCourseQuizzes(courseId);
      emit(QuizLoaded(_quizzes));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Create quiz ───────────────────────────────────────────
  Future<void> createQuiz(Map<String, dynamic> data) async {
    emit(const QuizCreating());
    try {
      final quiz = await _repo.createQuiz(courseId: courseId, data: data);
      _quizzes = [quiz, ..._quizzes];
      emit(QuizCreated(quiz));
      // Return to loaded state after short delay for UX
      await Future.delayed(const Duration(milliseconds: 100));
      emit(QuizLoaded(_quizzes));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Update quiz ───────────────────────────────────────────
  Future<void> updateQuiz({
    required int quizId,
    required Map<String, dynamic> data,
  }) async {
    emit(const QuizUpdating());
    try {
      final updated = await _repo.updateQuiz(quizId: quizId, data: data);
      _quizzes = _quizzes
          .map((q) => q.id == quizId ? updated : q)
          .toList();
      emit(QuizUpdated(updated));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(QuizLoaded(_quizzes));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Delete quiz ───────────────────────────────────────────
  Future<bool> deleteQuiz(int quizId) async {
    emit(const QuizDeleting());
    try {
      await _repo.deleteQuiz(quizId);
      _quizzes = _quizzes.where((q) => q.id != quizId).toList();
      emit(QuizDeleted(quizId));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(QuizLoaded(_quizzes));
      return true;
    } catch (e) {
      emit(QuizError(_parseError(e)));
      return false;
    }
  }

  // ── Generate quiz with AI ─────────────────────────────────
  Future<void> generateQuiz(GenerateQuizRequest req) async {
    emit(const QuizGenerating());
    try {
      final quiz = await _repo.generateQuiz(req);
      _quizzes = [quiz, ..._quizzes];
      emit(QuizGenerated(quiz));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(QuizLoaded(_quizzes));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Start taking a quiz ───────────────────────────────────
  Future<void> startQuiz(int quizId) async {
    emit(const QuizSessionLoading());
    try {
      final session = await _repo.startQuiz(quizId);
      _activeQuizId = quizId;
      emit(QuizSessionLoaded(session: session, answers: {}));
      _startAutoSave(quizId);
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Update an answer locally ──────────────────────────────
  void updateAnswer(int questionId, dynamic answer) {
    final current = state;
    if (current is! QuizSessionLoaded) return;
    final newAnswers = Map<int, dynamic>.from(current.answers)
      ..[questionId] = answer;
    emit(current.copyWith(answers: newAnswers));
  }

  Map<String, dynamic> _stringifyAnswers(Map<int, dynamic> answers) {
    return answers.map((key, value) => MapEntry(key.toString(), value));
  }

  // ── Auto save every 30 seconds ────────────────────────────
  void _startAutoSave(int quizId) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _performAutoSave(quizId);
    });
  }

  Future<void> _performAutoSave(int quizId) async {
    final current = state;
    if (current is! QuizSessionLoaded) return;
    emit(current.copyWith(autoSaving: true));
    try {
      await _repo.autoSave(
        quizId: quizId,
        answers: _stringifyAnswers(current.answers),
      );
    } catch (_) {
      // Silent fail on auto-save
    } finally {
      if (state is QuizSessionLoaded) {
        emit((state as QuizSessionLoaded).copyWith(autoSaving: false));
      }
    }
  }

  // ── Submit quiz ───────────────────────────────────────────
  Future<void> submitQuiz() async {
    final current = state;
    if (current is! QuizSessionLoaded || _activeQuizId == null) return;
    _autoSaveTimer?.cancel();
    emit(const QuizSubmitting());
    try {
      final result = await _repo.submitQuiz(
        quizId: _activeQuizId!,
        answers: _stringifyAnswers(current.answers),
      );
      emit(QuizResultLoaded(result));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Get all results for a quiz (admin view) ───────────────
  Future<void> loadResults(int quizId) async {
    emit(const QuizLoading());
    try {
      final results = await _repo.getQuizResults(quizId);
      emit(QuizResultsLoaded(results));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Get my result ─────────────────────────────────────────
  Future<void> loadMyResult(int quizId) async {
    emit(const QuizLoading());
    try {
      final result = await _repo.getMyResult(quizId);
      emit(QuizResultLoaded(result));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  // ── Translate quiz ────────────────────────────────────────
  Future<void> translateQuiz({
    required int quizId,
    required String targetLanguage,
  }) async {
    emit(const QuizTranslating());
    try {
      final quiz = await _repo.translateQuiz(
        quizId: quizId,
        targetLanguage: targetLanguage,
      );
      emit(QuizTranslated(quiz));
    } catch (e) {
      emit(QuizError(_parseError(e)));
    }
  }

  String _parseError(Object e) {
    if (e is DioException) {
      final msg = e.response?.data;
      if (msg is Map && msg['message'] != null) return msg['message'] as String;
      return e.message ?? 'Network error';
    }
    return e.toString();
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}
