import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'package:lms/features/screens/student/student_courses/state_managment/states.dart';
import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../model/view.dart';

class GetCourseStudentCubit extends Cubit<GetCourseStudentState> {
  GetCourseStudentCubit() : super(GetCourseStudentInitial());

  final Dio dio = Dio();

  Future<void> getCourses() async {
    emit(GetCourseStudentLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(GetCourseStudentError("You are not authorized. Token missing."));
        return;
      }

      final response = await dio.get(
        "${ApiResources.apiUrl}${ApiResources.getCourseStudentEndPoint}",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;

        final List<CourseEnrollmentModel> courses = data
            .map<CourseEnrollmentModel>(
                (e) => CourseEnrollmentModel.fromJson(e))
            .toList();

        emit(GetCourseStudentSuccess(courses));
      } else if (response.statusCode == 401) {
        emit(GetCourseStudentError("Unauthorized. Please login again."));
      } else {
        emit(GetCourseStudentError("Failed to load courses"));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(GetCourseStudentError("Unauthorized. Please login again."));
      } else {
        emit(GetCourseStudentError(e.message ?? "Something went wrong"));
      }
    } catch (e) {
      emit(GetCourseStudentError(e.toString()));
    }
  }
}
