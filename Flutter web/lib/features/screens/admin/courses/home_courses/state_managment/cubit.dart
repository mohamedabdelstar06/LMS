import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import '../../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';

import '../model/model.dart';


class GetCoursesCubit extends Cubit<GetCourseStates> {

  GetCoursesCubit() : super(GetCourseInitial());
  List<GetCoursesModel> currentCourses = [];

  final Dio dio = Dio();

  Future<void> getCourses() async {
    emit(GetCourseLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetCourseError('You are not authorized. Token missing.'));
        return;
      }

      final response = await dio.get(
        '${ApiResources.apiUrl}${ApiResources.getCourseEndPoint}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;

        final List<GetCoursesModel> courses = data
            .map<GetCoursesModel>((e) => GetCoursesModel.fromJson(e))
            .toList();
        currentCourses = courses;

        emit(GetCourseSuccess(courses));
      } else if (response.statusCode == 401) {
        emit(const GetCourseError('Unauthorized. Please login again.'));
      } else {
        emit(const GetCourseError('Failed to load courses'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(const GetCourseError('Unauthorized. Please login again.'));
      } else {
        emit(GetCourseError(e.message ?? 'Something went wrong'));
      }
    } catch (e) {
      emit(GetCourseError(e.toString()));
    }
  }
  Future<void> deleteCourse(int id) async {
    emit(DeleteCourseLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit( const DeleteCourseError('Unauthorized: Please login again.'));
        return;
      }

      final dio = Dio();
      final response = await dio.delete(
        '${ApiResources.apiUrl}${ApiResources.getCourseEndPoint}/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit( const DeleteCourseSuccess(
          'Course deleted successfully',
        ));
        await getCourses();      } else {
        emit(DeleteCourseError('Failed to delete course. Status: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete squadron';
      if (e.response != null) {
        errorMessage = 'Server Error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection Error. Please check the API URL or your network.';
      }
      emit(DeleteCourseError(errorMessage));
    } catch (e) {
      emit( const DeleteCourseError('An unexpected error occurred.'));
    }
  }


  Future<void> fetchCourseById(int id) async {
    emit(GetCourseByIdLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit( const GetCourseByIdError('Unauthorized: Please login again.'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '${ApiResources.apiUrl}${ApiResources.getCourseEndPoint}/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final course = GetCoursesModel.fromJson(response.data);
        emit(GetCourseByIdSuccess(course));
      } else {
        emit(GetCourseByIdError(
          'Failed to load squadron. Status: ${response.statusCode}',
        ));
      }
    } on DioException catch (e) {
      emit(GetCourseByIdError(
        e.response != null
            ? 'Server Error: ${e.response?.statusCode}'
            : 'Connection Error',
      ));
    }
  }

  Future<void> updateCourse({
    required int courseId,
    required Map<String, dynamic> courseData,
  }) async {
    emit(UpdateCourseLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const UpdateCourseError('Unauthorized: Please login again.'));
        return;
      }
      final dio = Dio();

      final formData = FormData.fromMap({
        'Title': courseData['title'],
        'Description': courseData['description'],
        'DepartmentName': courseData['departmentName'],
        'YearName': courseData['yearName'],
        'CreditHours': int.tryParse(courseData['credithours']?.toString() ?? '') ?? 0,
      });

      final Uint8List? imageBytes = courseData['imageFile'];
      if (imageBytes != null) {
        formData.files.add(MapEntry(
          'ImageFile',
          MultipartFile.fromBytes(
            imageBytes,
            filename: 'cover.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        ));
      }

      final response = await dio.put(
        '${ApiResources.apiUrl}${ApiResources.getCourseEndPoint}/$courseId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(UpdateCourseSuccess('Course updated successfully'));
      } else if (response.statusCode == 409) {
        final msg = response.data is Map
            ? (response.data['message'] ?? 'A course with this title already exists')
            : 'A course with this title already exists';
        emit(UpdateCourseError(msg));
      } else {
        emit(UpdateCourseError('Failed to update course (${response.statusCode})'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final data = e.response?.data;
        final msg = data is Map
            ? (data['message'] ?? 'A course with this title already exists')
            : 'A course with this title already exists';
        emit(UpdateCourseError(msg));
      } else {
        emit(UpdateCourseError(
          e.response?.data?['message'] ?? e.message ?? 'Error while updating',
        ));
      }
    } catch (e) {
      emit(UpdateCourseError('Unexpected error: $e'));
    }
  }
}