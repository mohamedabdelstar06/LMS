import 'dart:io';
import 'package:dio/dio.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';

// ignore_for_file: avoid_slow_async_io


class AssignmentRepository {
  final Dio _dio;

  AssignmentRepository(this._dio);

  // ── GET /api/courses/{courseId}/assignments ──────────────────
  Future<List<AssignmentModel>> getCourseAssignments(int courseId) async {
    final response = await _dio.get('courses/$courseId/assignments');
    final List data = response.data is List
        ? response.data
        : (response.data['data'] ?? response.data['assignments'] ?? []);
    return data.map((e) => AssignmentModel.fromJson(e)).toList();
  }

  // ── GET /api/assignments/{id} ────────────────────────────────
  Future<AssignmentModel> getAssignmentById(int id) async {
    final response = await _dio.get('assignments/$id');
    return AssignmentModel.fromJson(response.data['data'] ?? response.data);
  }

  // ── POST /api/courses/{courseId}/assignments ─────────────────
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

    // Text fields
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

    // ✅ FIX: use fromFileSync — no dart:io async, no "unsupported" error
    for (final file in files) {
      final fileName = _fileName(file.path);
      formData.files.add(
        MapEntry(
          'AssignmentFiles',
          MultipartFile.fromFileSync(
            // ← sync, always works on mobile
            file.path,
            filename: fileName,
            contentType: DioMediaType.parse(_mimeType(fileName)),
          ),
        ),
      );
    }

    final totalFiles = files.length;
    final response = await _dio.post(
      'courses/$courseId/assignments',
      data: formData,
      onSendProgress: (sent, total) {
        if (total <= 0) return;
        final progress = sent / total;
        // Distribute real Dio progress across all files
        for (final file in files) {
          onFileProgress(_fileName(file.path), progress);
        }
      },
    );

    return AssignmentModel.fromJson(response.data['data'] ?? response.data);
  }

  // ── PUT /api/assignments/{id} ────────────────────────────────
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

    // ✅ FIX: fromFileSync for update too
    for (final file in newFiles) {
      final fileName = _fileName(file.path);
      formData.files.add(
        MapEntry(
          'AssignmentFiles',
          MultipartFile.fromFileSync(
            file.path,
            filename: fileName,
            contentType: DioMediaType.parse(_mimeType(fileName)),
          ),
        ),
      );
    }

    final response = await _dio.put('assignments/$id', data: formData);
    return AssignmentModel.fromJson(response.data['data'] ?? response.data);
  }

  // ── DELETE /api/assignments/{id} ─────────────────────────────
  Future<void> deleteAssignment(int id) async {
    await _dio.delete('assignments/$id');
  }

  // ── POST /api/assignments/{id}/submit ────────────────────────
  Future<void> submitAssignment({
    required int assignmentId,
    required List<File> files,
    required void Function(String fileName, double progress) onFileProgress,
  }) async {
    final formData = FormData();

    // ✅ FIX: fromFileSync here too
    for (final file in files) {
      final fileName = _fileName(file.path);
      formData.files.add(
        MapEntry(
          'File',
          MultipartFile.fromFileSync(
            file.path,
            filename: fileName,
            contentType: DioMediaType.parse(_mimeType(fileName)),
          ),
        ),
      );
    }

    await _dio.post(
      'assignments/$assignmentId/submit',
      data: formData,
      onSendProgress: (sent, total) {
        if (total <= 0) return;
        final progress = sent / total;
        for (final file in files) {
          onFileProgress(_fileName(file.path), progress);
        }
      },
    );
  }

  // ── POST /api/assignments/{id}/grade/{studentId} ─────────────
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

  // ── GET /api/assignments/{id}/submissions ────────────────────
  Future<List<SubmissionModel>> getSubmissions(int assignmentId) async {
    final response = await _dio.get('assignments/$assignmentId/submissions');
    final List data = response.data is List
        ? response.data
        : (response.data['data'] ?? response.data['submissions'] ?? []);
    return data.map((e) => SubmissionModel.fromJson(e)).toList();
  }

  // ── Helpers ──────────────────────────────────────────────────

  String _fileName(String path) => path.split('/').last;

  String _mimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const map = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'mp4': 'video/mp4',
      'zip': 'application/zip',
      'rar': 'application/x-rar-compressed',
      'txt': 'text/plain',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}
