import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../home_courses/model/model.dart';
import 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  CourseDetailsCubit() : super(CourseDetailsInitial());

  Future<void> loadCourse(GetCoursesModel course, int courseID ) async {
    emit(CourseDetailsLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit(CourseDetailsError( 'Unauthorized'));
        return;
      }

      await Future.delayed(const Duration(milliseconds: 400));

      emit(CourseDetailsLoaded(course: course, courseId: courseID));
    } catch (e) {
      emit(CourseDetailsError( e.toString()));
    }
  }

  void setTab(int index) {
    if (state is CourseDetailsLoaded) {
      emit((state as CourseDetailsLoaded).copyWith(activeTab: index));
    }
  }
}