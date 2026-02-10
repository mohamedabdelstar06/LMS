import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:lms/features/screens/student/student_courses/state_managment/states.dart';
import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../model/view.dart';

class GetCourseStudentCubit extends Cubit<GetCourseStudentState> {
  GetCourseStudentCubit() : super(GetCourseStudentInitial());

  Future<void> getCourses() async {
    emit(GetCourseStudentLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(GetCourseStudentError("You are not authorized. Token missing."));
        return;
      }

      final response = await http.get(
        Uri.parse("${ApiResources.apiUrl}${ApiResources.getCourseStudentEndPoint}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        final List<CourseEnrollmentModel> courses = data
            .map<CourseEnrollmentModel>((e) => CourseEnrollmentModel.fromJson(e))
            .toList();

        emit(GetCourseStudentSuccess(courses));
      } else if (response.statusCode == 401) {
        emit(GetCourseStudentError("Unauthorized. Please login again."));
      } else {
        emit(GetCourseStudentError("Failed to load courses"));
      }
    } catch (e) {
      emit(GetCourseStudentError(e.toString()));
    }
  }
}

