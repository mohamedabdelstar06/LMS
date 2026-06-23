import 'package:dio/dio.dart';

import '../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import 'student_quiz_model.dart';

class StudentQuizRepository {
  final Dio dio = Dio();

  Future<String> _authOrThrow() async {
    final token = await TokenStorageHelper.getTokenSecure();
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(),
        error: 'You are not authorized. Token missing.',
      );
    }
    return token;
  }

  // ── GET /api/courses/{courseId}/quizzes ─────────────────────
  Future<List<StudentQuizListItem>> getCourseQuizzes(int courseId) async {
    final token = await _authOrThrow();
    final response = await dio.get(
      '${ApiResources.apiUrl}courses/$courseId/quizzes',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final List data = response.data is List
        ? response.data
        : (response.data['data'] ?? response.data['quizzes'] ?? []);
    return data.map((e) => StudentQuizListItem.fromJson(e)).toList();
  }

  // ── GET /api/quizzes/{id}/take ───────────────────────────────
  Future<QuizTakeSession> startQuiz(int quizId) async {
    final token = await _authOrThrow();
    final response = await dio.get(
      '${ApiResources.apiUrl}quizzes/$quizId/take',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return QuizTakeSession.fromJson(response.data);
  }

  // ── GET /api/quizzes/{id}/my-result ──────────────────────────
  /// Used both to show a graded result AND to detect an in-progress
  /// attempt so the take-screen can offer to resume it.
  /// Returns null if the student has no attempt at all (404).
  Future<StudentQuizResult?> getMyResult(int quizId) async {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),
    );
    final token = await _authOrThrow();
    try {
      final response = await dio.get(
        '${ApiResources.apiUrl}quizzes/$quizId/my-result',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return StudentQuizResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> autoSave({
    required int quizId,
    required List<QuizAnswerDraft> answers,
  }) async {
    final token = await _authOrThrow();
    await dio.post(
      '${ApiResources.apiUrl}quizzes/$quizId/auto-save',
      data: {'answers': answers.map((a) => a.toJson()).toList()},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<StudentQuizResult> submitQuiz({
    required int quizId,
    required List<QuizAnswerDraft> answers,
  }) async {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),
    );
    final token = await _authOrThrow();
    final response = await dio.post(
      '${ApiResources.apiUrl}quizzes/$quizId/submit',
      data: {'answers': answers.map((a) => a.toSubmitJson()).toList()},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return StudentQuizResult.fromJson(response.data);
  }
}
