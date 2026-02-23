import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import '../../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';

import '../model/model.dart';

class GetCourseCubit extends Cubit<GetCourseState> {
  GetCourseCubit() : super(GetCourseInitial());

  final Dio dio = Dio();

  Future<void> getCourses() async {
    emit(GetCourseLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(GetCourseError("You are not authorized. Token missing."));
        return;
      }

      final response = await dio.get(
        "${ApiResources.apiUrl}${ApiResources.getCourseEndPoint}",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;

        final List<GetCourseModel> courses = data
            .map<GetCourseModel>((e) => GetCourseModel.fromJson(e))
            .toList();

        emit(GetCourseSuccess(courses));
      } else if (response.statusCode == 401) {
        emit(GetCourseError("Unauthorized. Please login again."));
      } else {
        emit(GetCourseError("Failed to load courses"));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(GetCourseError("Unauthorized. Please login again."));
      } else {
        emit(GetCourseError(e.message ?? "Something went wrong"));
      }
    } catch (e) {
      emit(GetCourseError(e.toString()));
    }
  }
}