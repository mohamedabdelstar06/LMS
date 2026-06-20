import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/student/student_courses/student_quiz_model.dart';
import 'package:lms/features/screens/student/student_courses/student_quiz_repository.dart';


import 'student_quiz_states.dart';

class StudentQuizCubit extends Cubit<StudentQuizState> {
  StudentQuizCubit({StudentQuizRepository? repository})
      : _repo = repository ?? StudentQuizRepository(),
        super(StudentQuizInitial());

  final StudentQuizRepository _repo;
  Timer? _autoSaveTimer;
  int? _activeQuizId;

  // ── List ─────────────────────────────────────────────
  Future<void> loadQuizzes(int courseId) async {
    emit(QuizListLoading());
    try {
      final quizzes = await _repo.getCourseQuizzes(courseId);
      emit(QuizListSuccess(quizzes));
    } on DioException catch (e) {
      emit(QuizListError(_readable(e)));
    } catch (e) {
      emit(QuizListError(e.toString()));
    }
  }

  // ── Entry point from "Start Quiz" button ──────────────
  /// Checks my-result first:
  ///  - If an attempt exists with status == InProgress -> resume it
  ///    (restore answers if the API returned them; otherwise start the
  ///    take-session fresh but keep attemptNumber/flag so UI can show
  ///    "Resuming previous attempt").
  ///  - If a finished attempt exists (Submitted/Graded) -> go straight
  ///    to the result screen instead of re-opening the quiz.
  ///  - If no attempt exists (404) -> start a brand new attempt.
  Future<void> beginOrResumeQuiz(int quizId) async {
    emit(QuizPrecheckLoading());
    try {
      final existing = await _repo.getMyResult(quizId);

      if (existing != null && !existing.isInProgress) {
        // Already finished — show the result instead of retaking.
        emit(QuizResultLoaded(existing));
        return;
      }

      emit(QuizSessionLoading());
      final session = await _repo.startQuiz(quizId);
      _activeQuizId = quizId;

      final answers = <int, QuizAnswerDraft>{
        for (final q in session.questions) q.id: QuizAnswerDraft(questionId: q.id),
      };

      // Restore previously saved answers if the in-progress attempt
      // returned any (API contract allows `answers: null` even while
      // InProgress, e.g. before the first auto-save has fired).
      if (existing != null && existing.answers != null) {
        for (final saved in existing.answers!) {
          if (answers.containsKey(saved.questionId)) {
            answers[saved.questionId] = QuizAnswerDraft(
              questionId: saved.questionId,
              selectedOptionId: saved.selectedOptionId,
              writtenAnswer: saved.writtenAnswer,
            );
          }
        }
      }

      emit(QuizSessionActive(
        session: session,
        answers: answers,
        isResumed: existing != null && existing.isInProgress,
      ));
      _startAutoSaveTimer(quizId);
    } on DioException catch (e) {
      emit(QuizSessionError(_readable(e)));
    } catch (e) {
      emit(QuizSessionError(e.toString()));
    }
  }

  // ── Answering ──────────────────────────────────────────
  void updateAnswer({
    required int questionId,
    int? selectedOptionId,
    String? writtenAnswer,
  }) {
    final current = state;
    if (current is! QuizSessionActive) return;
    final existing = current.answers[questionId] ?? QuizAnswerDraft(questionId: questionId);
    existing.selectedOptionId = selectedOptionId ?? existing.selectedOptionId;
    if (writtenAnswer != null) existing.writtenAnswer = writtenAnswer;
    if (selectedOptionId != null) existing.writtenAnswer = null;

    final updated = Map<int, QuizAnswerDraft>.from(current.answers)..[questionId] = existing;
    emit(current.copyWith(answers: updated));
  }

  void toggleFlag(int questionId) {
    final current = state;
    if (current is! QuizSessionActive) return;
    final existing = current.answers[questionId] ?? QuizAnswerDraft(questionId: questionId);
    existing.isFlagged = !existing.isFlagged;
    final updated = Map<int, QuizAnswerDraft>.from(current.answers)..[questionId] = existing;
    emit(current.copyWith(answers: updated));
  }

  void _startAutoSaveTimer(int quizId) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 20), (_) => _performAutoSave(quizId));
  }

  Future<void> _performAutoSave(int quizId) async {
    final current = state;
    if (current is! QuizSessionActive) return;
    emit(current.copyWith(isAutoSaving: true));
    try {
      await _repo.autoSave(quizId: quizId, answers: current.answers.values.toList());
    } catch (_) {
      // silent — retried on next tick
    } finally {
      if (state is QuizSessionActive) {
        emit((state as QuizSessionActive).copyWith(isAutoSaving: false));
      }
    }
  }

  // ── Submit ────────────────────────────────────────────
  Future<void> submitQuiz() async {
    final current = state;
    if (current is! QuizSessionActive || _activeQuizId == null) return;
    _autoSaveTimer?.cancel();
    emit(current.copyWith(isSubmitting: true));
    try {
      final result = await _repo.submitQuiz(
        quizId: _activeQuizId!,
        answers: current.answers.values.toList(),
      );
      emit(QuizResultLoaded(result));
    } on DioException catch (e) {
      emit(QuizSessionError(_readable(e)));
    } catch (e) {
      emit(QuizSessionError(e.toString()));
    }
  }

  // ── Result (direct view, e.g. from list "View Result") ──
  Future<void> loadMyResult(int quizId) async {
    emit(QuizResultLoading());
    try {
      final result = await _repo.getMyResult(quizId);
      if (result == null) {
        emit(QuizResultError('No attempt found for this quiz yet.'));
        return;
      }
      emit(QuizResultLoaded(result));
    } on DioException catch (e) {
      emit(QuizResultError(_readable(e)));
    } catch (e) {
      emit(QuizResultError(e.toString()));
    }
  }

  String _readable(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    if (status == 401) return 'Session expired — please log in again';
    if (status == 403) return "You don't have permission for this";
    if (status == 404) return 'Quiz not found';
    if (status == 500) return 'Server error — try again later';
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Network error — check your connection';
    }
    return e.message ?? 'Something went wrong';
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}
