import '../../home_courses/model/model.dart';

abstract class CourseDetailsState {}

class CourseDetailsInitial extends CourseDetailsState {}

class CourseDetailsLoading extends CourseDetailsState {}

class CourseDetailsLoaded extends CourseDetailsState {
  CourseDetailsLoaded({required this.course, this.activeTab = 0, required this.courseId});
  final GetCoursesModel course;
  final int activeTab;
  final int courseId ;

  CourseDetailsLoaded copyWith({GetCoursesModel? course, int? activeTab, int ? courseId}) =>
      CourseDetailsLoaded(
        course: course ?? this.course,
        activeTab: activeTab ?? this.activeTab,
        courseId: courseId?? this.courseId
      );
}

class CourseDetailsError extends CourseDetailsState {
  CourseDetailsError(this.message);
  final String message;
}