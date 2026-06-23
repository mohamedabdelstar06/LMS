import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../home_courses/model/model.dart';
import 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  CourseDetailsCubit() : super(CourseDetailsInitial());

  Future<void> loadCourseById(int courseId) async {
    emit(CourseDetailsLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit(CourseDetailsError('Unauthorized'));
        return;
      }

      final response = await DioHelper.dio.get(
        'Course/$courseId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final course = GetCoursesModel.fromJson(response.data);

      emit(CourseDetailsLoaded(
        course: course,
        courseId: courseId,
      ));
    } on DioException catch (e) {
      emit(CourseDetailsError(e.response?.data.toString() ?? e.message ?? 'Error'));
    } catch (e) {
      emit(CourseDetailsError(e.toString()));
    }
  }

  void setTab(int index) {
    if (state is CourseDetailsLoaded) {
      emit((state as CourseDetailsLoaded).copyWith(activeTab: index));
    }
  }
}

class DioHelper {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://skylearn.runasp.net/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
}