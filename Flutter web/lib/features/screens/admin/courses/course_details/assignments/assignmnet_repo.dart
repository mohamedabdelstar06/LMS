import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';




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
    DateTime? startDate,
    DateTime? deadlineDate,
    required List<PickedFileData> files,
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
      if (startDate != null)
        MapEntry('StartDate', startDate.toIso8601String().split('T').first),
      if (deadlineDate != null)
        MapEntry(
          'DeadLineDate',
          deadlineDate.toIso8601String().split('T').first,
        ),
    ]);

    // ✅ fromBytes — works on ALL Android versions, no path needed,
    //    preserves the original filename the user chose
    for (final file in files) {
      formData.files.add(
        MapEntry(
          'AssignmentFiles',
          MultipartFile.fromBytes(
            file.bytes,
            filename: file.name, // ← real name, not base64
            contentType: DioMediaType.parse(_mimeType(file.extension)),
          ),
        ),
      );
    }

    final response = await _dio.post(
      'courses/$courseId/assignments',
      data: formData,
      onSendProgress: (sent, total) {
        if (total <= 0) return;
        final progress = sent / total;
        for (final f in files) {
          onFileProgress(f.name, progress);
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
    DateTime? startDate,
    DateTime? deadlineDate,
    List<PickedFileData> newFiles = const [],
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
      if (startDate != null)
        MapEntry('StartDate', startDate.toIso8601String().split('T').first),
      if (deadlineDate != null)
        MapEntry(
          'DeadLineDate',
          deadlineDate.toIso8601String().split('T').first,
        ),
    ]);

    for (final file in newFiles) {
      formData.files.add(
        MapEntry(
          'AssignmentFiles',
          MultipartFile.fromBytes(
            file.bytes,
            filename: file.name,
            contentType: DioMediaType.parse(_mimeType(file.extension)),
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
    required List<PickedFileData> files,
    required void Function(String fileName, double progress) onFileProgress,
  }) async {
    final formData = FormData();

    for (final file in files) {
      formData.files.add(
        MapEntry(
          'File',
          MultipartFile.fromBytes(
            file.bytes,
            filename: file.name,
            contentType: DioMediaType.parse(_mimeType(file.extension)),
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
        for (final f in files) {
          onFileProgress(f.name, progress);
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
  String _mimeType(String ext) {
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
    return map[ext.toLowerCase()] ?? 'application/octet-stream';
  }
}
/// Wraps PlatformFile and guarantees bytes are loaded.
/// Use this instead of dart:io File everywhere in the assignments feature.
class PickedFileData {
  final String name;        // original filename e.g. "ENSA_Module_4.pptx"
  final String extension;   // e.g. "pptx"
  final int sizeBytes;
  final List<int> bytes;    // actual file content — always present

  PickedFileData({
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.bytes,
  });

  /// Build from a FilePicker result that was loaded with withData: true
  static PickedFileData? fromPlatformFile(PlatformFile pf) {
    if (pf.bytes == null || pf.bytes!.isEmpty) return null;
    return PickedFileData(
      name: pf.name,
      extension: pf.extension ?? pf.name.split('.').last,
      sizeBytes: pf.size,
      bytes: pf.bytes!,
    );
  }

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get icon {
    const map = {
      'pdf'  : '📄',
      'doc'  : '📝', 'docx': '📝',
      'ppt'  : '📊', 'pptx': '📊',
      'xls'  : '📈', 'xlsx': '📈',
      'jpg'  : '🖼️', 'jpeg': '🖼️', 'png': '🖼️', 'gif': '🖼️',
      'mp4'  : '🎬', 'mov': '🎬',
      'zip'  : '🗜️', 'rar': '🗜️',
      'txt'  : '📃',
    };
    return map[extension.toLowerCase()] ?? '📎';
  }
}