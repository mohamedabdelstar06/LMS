// ============================================================
// quiz_repository.dart
// ============================================================
import 'package:dio/dio.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

class QuizRepository {
  final Dio _dio;

  QuizRepository(this._dio);

  // ── POST /api/courses/{courseId}/quizzes ──────────────────
  Future<QuizModel> createQuiz({
    required int courseId,
    required Map<String, dynamic> data,
  }) async {
    final res = await _dio.post('courses/$courseId/quizzes', data: data);
    return QuizModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── GET /api/courses/{courseId}/quizzes ───────────────────
  Future<List<QuizModel>> getCourseQuizzes(int courseId) async {
    final res = await _dio.get('courses/$courseId/quizzes');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/quizzes/{id} ─────────────────────────────────
  Future<QuizModel> getQuizById(int quizId) async {
    final res = await _dio.get('quizzes/$quizId');
    return QuizModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── PUT /api/quizzes/{id} ─────────────────────────────────
  Future<QuizModel> updateQuiz({
    required int quizId,
    required Map<String, dynamic> data,
  }) async {
    final res = await _dio.put('quizzes/$quizId', data: data);
    return QuizModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── DEL /api/quizzes/{id} ─────────────────────────────────
  Future<void> deleteQuiz(int quizId) async {
    await _dio.delete('quizzes/$quizId');
  }

  // ── POST /api/quizzes/generate ────────────────────────────
  Future<QuizModel> generateQuiz(GenerateQuizRequest req) async {
    final res = await _dio.post('quizzes/generate', data: req.toJson());
    return QuizModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── GET /api/quizzes/{id}/take ────────────────────────────
  Future<QuizTakeSession> startQuiz(int quizId) async {
    final res = await _dio.get('quizzes/$quizId/take');
    return QuizTakeSession.fromJson(res.data as Map<String, dynamic>);
  }

  // ── POST /api/quizzes/{id}/auto-save ─────────────────────
  Future<void> autoSave({
    required int quizId,
    required Map<String, dynamic> answers,
  }) async {
    await _dio.post('quizzes/$quizId/auto-save', data: answers);
  }

  // ── POST /api/quizzes/{id}/submit ────────────────────────
  Future<QuizResult> submitQuiz({
    required int quizId,
    required Map<String, dynamic> answers,
  }) async {
    final res = await _dio.post('quizzes/$quizId/submit', data: answers);
    return QuizResult.fromJson(res.data as Map<String, dynamic>);
  }

  // ── GET /api/quizzes/{id}/results ────────────────────────
  Future<List<QuizResult>> getQuizResults(int quizId) async {
    final res = await _dio.get('quizzes/$quizId/results');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/quizzes/{id}/my-result ──────────────────────
  Future<QuizResult> getMyResult(int quizId) async {
    final res = await _dio.get('quizzes/$quizId/my-result');
    return QuizResult.fromJson(res.data as Map<String, dynamic>);
  }

  // ── POST /api/quizzes/{id}/grade ─────────────────────────
  Future<void> gradeQuiz({
    required int quizId,
    required Map<String, dynamic> grades,
  }) async {
    await _dio.post('quizzes/$quizId/grade', data: grades);
  }

  // ── POST /api/quizzes/{id}/translate ─────────────────────
  Future<QuizModel> translateQuiz({
    required int quizId,
    required String targetLanguage,
  }) async {
    final res = await _dio.post(
      'quizzes/$quizId/translate',
      data: {'targetLanguage': targetLanguage},
    );
    return QuizModel.fromJson(res.data as Map<String, dynamic>);
  }
}
