import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart';

import '../../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../model/model.dart';
import 'lectures_state.dart';


class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://skylearn.runasp.net/api/',
      receiveDataWhenStatusError: true,
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorageHelper.getTokenSecure();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          print('REQUEST => ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('RESPONSE => ${response.statusCode}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        print('ERROR => ${error.message}');
        return handler.next(error);
      },
    ),
  );
}


class LectureCubit extends Cubit<LectureState> {
  LectureCubit({required this.courseModel}) : super(const LectureInitial());


  List<LectureModel> currentLectures = [];
  final GetCoursesModel courseModel;


  Future<void> fetchLectures(int courseId) async {
    emit(const LectureLoading());
    try {
      final response =
      await ApiService.dio.get('courses/$courseId/lectures');

      if (response.statusCode == 200) {
        final List data = response.data as List;
        currentLectures =
            data.map((e) => LectureModel.fromJson(e)).toList();
        emit(LectureLoaded(List.from(currentLectures)));
      } else {
        emit(LectureError(
            'Failed to load lectures (${response.statusCode})'));
      }
    } on DioException catch (e) {
      emit(LectureError(_handleDioError(e)));
    } catch (e) {
      emit(LectureError('Unexpected error: $e'));
    }
  }

  Future<void> createLecture({
    required int courseId,
    required String title,
    required String description,
    required PlatformFile file,
    List<PlatformFile> additionalFiles = const [],
  }) async {
    emit(const LectureCreateLoading(progress: 0.0));
    try {
      final formData = FormData.fromMap({
        'courseId': courseId,
        'title': title,
        'description': description,
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
        if (additionalFiles.isNotEmpty)
          'AdditionalFiles': additionalFiles
              .map((f) => MultipartFile.fromBytes(f.bytes!, filename: f.name))
              .toList(),
      });

      final response = await ApiService.dio.post(
        'courses/$courseId/lectures',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            emit(LectureCreateLoading(progress: sent / total));
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(const LectureCreateSuccess());
        await fetchLectures(courseId);
      } else {
        emit(LectureCreateError(
            'Failed to create lecture (${response.statusCode})'));
      }
    } on DioException catch (e) {
      emit(LectureCreateError(_handleDioError(e)));
    } catch (e) {
      emit(LectureCreateError('Unexpected error: $e'));
    }
  }
  Future<void> updateLecture({
    required int lectureId,
    required int courseId,
    required String title,
    required String description,
    PlatformFile? file,
    List<PlatformFile> additionalFiles = const [],
  }) async {
    emit(const LectureUpdateLoading());


    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        if (file != null)
          'file': MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        if (additionalFiles.isNotEmpty)
          'AdditionalFiles': additionalFiles
              .map((f) => MultipartFile.fromBytes(f.bytes!, filename: f.name))
              .toList(),
      });




      final response = await ApiService.dio.put(
        '/lectures/$lectureId',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            emit(LectureUpdateLoading(progress: sent / total));
          }
        },
      );



      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const LectureUpdateSuccess());
        await fetchLectures(courseId);
      } else {
        debugPrint('✖ Unexpected status: ${response.statusCode}');
        emit(LectureUpdateError('Failed to update lecture (${response.statusCode})'));
      }
    } on DioException catch (e) {
      debugPrint('✖ DioException');
      debugPrint('   type     : ${e.type}');
      debugPrint('   status   : ${e.response?.statusCode}');
      debugPrint('   message  : ${e.message}');
      debugPrint('   response : ${e.response?.data}');
      debugPrint('   headers  : ${e.response?.headers}');
      debugPrint('   realUrl  : ${e.requestOptions.uri}');
      debugPrint('   reqHeaders : ${e.requestOptions.headers}');
      emit(LectureUpdateError(_handleDioError(e)));
    } catch (e, st) {
      debugPrint('✖ Unexpected error: $e');
      debugPrint('$st');
      emit(LectureUpdateError('Unexpected error: $e'));
    }
  }
  Future<void> deleteLecture({
    required int lectureId,
    required int courseId,
  }) async {
    emit(const LectureDeleteLoading());
    try {
      final response =
      await ApiService.dio.delete('lectures/$lectureId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        currentLectures.removeWhere((l) => l.id == lectureId);
        emit(const LectureDeleteSuccess('Lecture deleted successfully'));
        emit(LectureLoaded(List.from(currentLectures)));
      } else {
        emit(LectureDeleteError(
            'Failed to delete lecture (${response.statusCode})'));
      }
    } on DioException catch (e) {
      emit(LectureDeleteError(_handleDioError(e)));
    } catch (e) {
      emit(LectureDeleteError('Unexpected error: $e'));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) return 'Unauthorized. Please login again.';
    if (e.response?.statusCode == 404) return 'Lecture not found.';
    if (e.response?.statusCode == 409) {
      return 'Conflict: ${e.response?.data?['message'] ?? 'Already exists.'}';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Check your internet.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Connection error. Check the API URL.';
    }
    return e.response?.data?['message'] ?? e.message ?? 'Something went wrong.';
  }
}