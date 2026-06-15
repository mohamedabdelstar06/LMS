import 'dart:io';
import 'package:dio/dio.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';

class AssignmentRepository {
  final Dio _dio;

  AssignmentRepository(this._dio);

  // GET /api/courses/{courseId}/assignments
  Future<List<AssignmentModel>> getCourseAssignments(int courseId) async {
    final response = await _dio.get('courses/$courseId/assignments');
    final List data = response.data is List
        ? response.data
        : (response.data['data'] ?? response.data['assignments'] ?? []);
    return data.map((e) => AssignmentModel.fromJson(e)).toList();
  }

  // GET /api/assignments/{id}
  Future<AssignmentModel> getAssignmentById(int id) async {
    final response = await _dio.get('assignments/$id');
    return AssignmentModel.fromJson(response.data['data'] ?? response.data);
  }

  // POST /api/courses/{courseId}/assignments
  Future<AssignmentModel> createAssignment({
    required int courseId,
    required String title,
    required String description,
    required String instructions,
    required int maxGrade,
    required bool allowLateSubmission,
    required bool isVisible,
    int? targetSquadronId,
    required List<File> files,
    required void Function(String fileName, double progress) onFileProgress,
  }) async {
    final formData = FormData();
    formData.fields.addAll([
      MapEntry('courseId', courseId.toString()),
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('instructions', instructions),
      MapEntry('maxGrade', maxGrade.toString()),
      MapEntry('allowLateSubmission', allowLateSubmission.toString()),
      MapEntry('isVisible', isVisible.toString()),
      if (targetSquadronId != null)
        MapEntry('targetSquadronId', targetSquadronId.toString()),
    ]);

    for (final file in files) {
      final fileName = file.path.split('/').last;
      formData.files.add(
        MapEntry(
          'AssignmentFiles',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: DioMediaType.parse(_getMimeType(fileName)),
          ),
        ),
      );
    }

    final response = await _dio.post(
      'courses/$courseId/assignments',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) {
          // Report overall progress — per-file progress tracked in cubit
        }
      },
    );

    return AssignmentModel.fromJson(response.data['data'] ?? response.data);
  }

  // PUT /api/assignments/{id}
  Future<AssignmentModel> updateAssignment({
    required int id,
    required int courseId,
    required String title,
    required String description,
    required String instructions,
    required int maxGrade,
    required bool allowLateSubmission,
    required bool isVisible,
    int? targetSquadronId,
    List<File> newFiles = const [],
  }) async {
    final formData = FormData();
    formData.fields.addAll([
      MapEntry('courseId', courseId.toString()),
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('instructions', instructions),
      MapEntry('maxGrade', maxGrade.toString()),
      MapEntry('allowLateSubmission', allowLateSubmission.toString()),
      MapEntry('isVisible', isVisible.toString()),
      if (targetSquadronId != null)
        MapEntry('targetSquadronId', targetSquadronId.toString()),
    ]);

    for (final file in newFiles) {
      final fileName = file.path.split('/').last;
      formData.files.add(
        MapEntry(
          'AssignmentFiles',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    final response = await _dio.put('assignments/$id', data: formData);
    return AssignmentModel.fromJson(response.data['data'] ?? response.data);
  }

  // DELETE /api/assignments/{id}
  Future<void> deleteAssignment(int id) async {
    await _dio.delete('assignments/$id');
  }

  // POST /api/assignments/{id}/submit
  Future<void> submitAssignment({
    required int assignmentId,
    required List<File> files,
    required void Function(String fileName, double progress) onFileProgress,
  }) async {
    final formData = FormData();
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = file.path.split('/').last;
      formData.files.add(
        MapEntry(
          'File',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    await _dio.post(
      'assignments/$assignmentId/submit',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final progress = sent / total;
          for (final file in files) {
            onFileProgress(file.path.split('/').last, progress);
          }
        }
      },
    );
  }

  // POST /api/assignments/{id}/grade/{studentId}
  Future<void> gradeSubmission({
    required int assignmentId,
    required int studentId,
    required int grade,
    required String feedback,
  }) async {
    await _dio.post(
      'assignments/$assignmentId/grade/$studentId',
      data: {'grade': grade, 'feedback': feedback},
    );
  }

  // GET /api/assignments/{id}/submissions
  Future<List<SubmissionModel>> getSubmissions(int assignmentId) async {
    final response = await _dio.get('assignments/$assignmentId/submissions');
    final List data = response.data is List
        ? response.data
        : (response.data['data'] ?? response.data['submissions'] ?? []);
    return data.map((e) => SubmissionModel.fromJson(e)).toList();
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const map = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'zip': 'application/zip',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}
