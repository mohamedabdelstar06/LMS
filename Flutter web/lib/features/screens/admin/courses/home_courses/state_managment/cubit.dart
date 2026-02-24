import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import '../../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';

import '../model/model.dart';


class GetCoursesCubit extends Cubit<GetCourseStates> {
  List<GetCoursesModel> currentCourses = [];

  GetCoursesCubit() : super(GetCourseInitial());

  final Dio dio = Dio();

  Future<void> getCourses() async {
    emit(GetCourseLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(GetCourseError('You are not authorized. Token missing.'));
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
        emit(GetCourseError('Unauthorized. Please login again.'));
      } else {
        emit(GetCourseError('Failed to load courses'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(GetCourseError('Unauthorized. Please login again.'));
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
        emit( DeleteCourseError('Unauthorized: Please login again.'));
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
        emit( DeleteCourseSuccess(
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
      emit( DeleteCourseError('An unexpected error occurred.'));
    }
  }


  Future<void> fetchCourseById(int id) async {
    emit(GetCourseByIdLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit( GetCourseByIdError('Unauthorized: Please login again.'));
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
}