import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/student/student_courses/course_detail_model.dart';

import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import 'course_detail_states.dart';

/// Fetches GET /api/Course/{id} — full course detail for the student-side
/// Course Details screen (overview header + counts used to drive the
/// Assignments / Quizzes / Lectures entry cards).
class CourseDetailCubit extends Cubit<CourseDetailState> {
  CourseDetailCubit() : super(CourseDetailInitial());

  final Dio dio = Dio();

  Future<void> getCourseDetail(int courseId) async {
    emit(CourseDetailLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(CourseDetailError("You are not authorized. Token missing."));
        return;
      }

      final response = await dio.get(
        "${ApiResources.apiUrl}/Course/$courseId",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final course = CourseDetailModel.fromJson(response.data);
        emit(CourseDetailSuccess(course));
      } else if (response.statusCode == 401) {
        emit(CourseDetailError("Unauthorized. Please login again."));
      } else {
        emit(CourseDetailError("Failed to load course details"));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(CourseDetailError("Unauthorized. Please login again."));
      } else if (e.response?.statusCode == 404) {
        emit(CourseDetailError("Course not found."));
      } else {
        emit(CourseDetailError(e.message ?? "Something went wrong"));
      }
    } catch (e) {
      emit(CourseDetailError(e.toString()));
    }
  }
}
