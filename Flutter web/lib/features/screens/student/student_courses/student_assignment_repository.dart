import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import 'student_assignment_model.dart';

class StudentAssignmentRepository {
  final Dio dio = Dio();
  

  Future<String> _authHeaderOrThrow() async {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),
    );
    final token = await TokenStorageHelper.getTokenSecure();
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(),
        error: 'You are not authorized. Token missing.',
      );
    }
    return token;
  }

  Future<List<StudentAssignmentModel>> getCourseAssignments(int courseId) async {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),
    );
    final token = await _authHeaderOrThrow();
    final response = await dio.get(
      '${ApiResources.apiUrl}courses/$courseId/assignments',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    debugPrint('URL: $response');
    debugPrint('Token: $token');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.data}');
    final List data = response.data is List
        ? response.data
        : (response.data['data'] ?? response.data['assignments'] ?? []);
    return data.map((e) => StudentAssignmentModel.fromJson(e)).toList();
  }

  Future<StudentAssignmentModel> getAssignmentById(int id) async {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ),
    );
    final token = await _authHeaderOrThrow();
    final response = await dio.get(
      '${ApiResources.apiUrl}assignments/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    debugPrint('URL: $response');
    debugPrint('Token: $token');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.data}');
    return StudentAssignmentModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<void> submitAssignment({
    
    required int assignmentId,
    required List<PickedSubmissionFile> files,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final token = await _authHeaderOrThrow();
    final formData = FormData();

    for (final file in files) {
      formData.files.add(
        MapEntry(
          'File',
          MultipartFile.fromBytes(
            file.bytes,
            filename: file.name,
          ),
        ),
      );
    }

    await dio.post(
      '${ApiResources.apiUrl}assignments/$assignmentId/submit',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      onSendProgress: onSendProgress,
    );
  }
}


class PickedSubmissionFile {

  PickedSubmissionFile({
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.bytes,
  });
  final String name;
  final String extension;
  final int sizeBytes;
  final List<int> bytes;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get icon {
    const map = {
      'pdf': '📄',
      'doc': '📝', 'docx': '📝',
      'ppt': '📊', 'pptx': '📊',
      'xls': '📈', 'xlsx': '📈',
      'jpg': '🖼️', 'jpeg': '🖼️', 'png': '🖼️', 'gif': '🖼️',
      'mp4': '🎬', 'mov': '🎬',
      'zip': '🗜️', 'rar': '🗜️',
      'txt': '📃',
    };
    return map[extension.toLowerCase()] ?? '📎';
  }
}
