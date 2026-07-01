


import 'package:dio/dio.dart';
import 'package:lms/core/helpers/json_list_parser.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

class QuizRepository {
  QuizRepository(this._dio);
  final Dio _dio;

  Future<QuizModel> createQuiz({
    required int courseId,
    required QuizFormData data,
  }) async {
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),
    );
    final res = await _dio.post(
      'courses/$courseId/quizzes',
      data: data.toJson(),
    );
    return QuizModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<QuizModel>> getCourseQuizzes(int courseId) async {
    final res = await _dio.get('courses/$courseId/quizzes');
    return parseJsonObjectList(
      res.data,
      listKeys: const ['data', 'results', 'items', 'value', 'quizzes'],
    ).map(QuizModel.fromJson).toList();
  }

  
  Future<QuizDetailModel> getQuizById(int quizId) async {
    final res = await _dio.get('quizzes/$quizId');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return QuizDetailModel.fromJson(data);
    }
    if (data is List) {
      return QuizDetailModel.fromJson(parseJsonObjectList(data).first);
    }
    throw StateError('Unexpected quiz detail response format');
  }

  
  Future<QuizModel> updateQuiz({
    required int quizId,
    required QuizFormData data,
  }) async {
    final res = await _dio.put('quizzes/$quizId', data: data.toJson());
    return QuizModel.fromJson(res.data as Map<String, dynamic>);
  }

  
  Future<void> deleteQuiz(int quizId) async {
    await _dio.delete('quizzes/$quizId');
  }

  
  Future<QuizModel> generateQuiz(
    GenerateQuizRequest req, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData();
    
    formData.fields
      ..add(MapEntry('CourseId', req.courseId.toString()))
      ..add(MapEntry('QuestionTypes', req.questionTypes))
      ..add(MapEntry('NumberOfQuestions', req.numberOfQuestions.toString()))
      ..add(MapEntry('DifficultyLevel', req.difficultyLevel))
      ..add(MapEntry('QuizScope', req.quizScope))
      ..add(MapEntry('Title', req.title));
    
    for (final lectureId in req.lectureIds) {
      formData.fields.add(MapEntry('LectureIds', lectureId.toString()));
    }
    
    if (req.customPrompt.isNotEmpty) {
      formData.fields.add(MapEntry('CustomPrompt', req.customPrompt));
    }
    if (req.targetSquadronId != null) {
      formData.fields.add(
        MapEntry('TargetSquadronId', req.targetSquadronId!.toString()),
      );
    }
    
    final pdfBytes = req.importedPdfBytes;
    if (pdfBytes != null && pdfBytes.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'ImportedPdf',
          MultipartFile.fromBytes(
            pdfBytes,
            filename: req.importedPdfName ?? 'document.pdf',
          ),
        ),
      );
    }

    final res = await _dio.post(
      'quizzes/generate',
      data: formData,
      onSendProgress: onSendProgress,
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return QuizModel.fromJson(data);
    }
    if (data is List && data.isNotEmpty) {
      return QuizModel.fromJson(parseJsonObjectList(data).first);
    }
    throw StateError('Unexpected quiz generate response format: $data');
  }

  
  Future<QuizTakeSession> startQuiz(int quizId) async {
    final res = await _dio.get('quizzes/$quizId/take');
    return QuizTakeSession.fromJson(res.data as Map<String, dynamic>);
  }

  
  Future<void> autoSave({
    required int quizId,
    required List<QuizAnswer> answers,
  }) async {
    await _dio.post(
      'quizzes/$quizId/auto-save',
      data: {'answers': answers.map((a) => a.toJson()).toList()},
    );
  }

  
  Future<QuizResult> submitQuiz({
    required int quizId,
    required List<QuizAnswer> answers,
  }) async {
    final res = await _dio.post(
      'quizzes/$quizId/submit',
      data: {'answers': answers.map((a) => a.toSubmitJson()).toList()},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return QuizResult.fromJson(data);
    }
    return QuizResult.fromJson(parseJsonObjectList(data).first);
  }

  
  Future<List<QuizResult>> getQuizResults(int quizId) async {
    final res = await _dio.get('quizzes/$quizId/results');
    return parseJsonObjectList(res.data).map(QuizResult.fromJson).toList();
  }

  
  Future<QuizResult> getMyResult(int quizId) async {
    final res = await _dio.get('quizzes/$quizId/my-result');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return QuizResult.fromJson(data);
    }
    final list = parseJsonObjectList(data);
    if (list.isEmpty) {
      throw StateError('No quiz result found');
    }
    return QuizResult.fromJson(list.first);
  }

  
  Future<void> gradeQuiz({
    required int quizId,
    required List<StudentAnswerForGrading> grades,
  }) async {
    await _dio.post(
      'quizzes/$quizId/grade',
      data: {'grades': grades.map((g) => g.toGradeJson()).toList()},
    );
  }

  
  Future<QuizDetailModel> translateQuiz({
    required int quizId,
    String targetLanguage = 'ar',
  }) async {
    final res = await _dio.post(
      'quizzes/$quizId/translate',
      data: {'targetLanguage': targetLanguage},
    );
    return QuizDetailModel.fromJson(res.data as Map<String, dynamic>);
  }
}
