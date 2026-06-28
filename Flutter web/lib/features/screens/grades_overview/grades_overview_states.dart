import 'course_grades_model.dart';
import 'grades_overview_cubit.dart' show CourseOption;

abstract class GradesOverviewState {}

class GradesOverviewInitial extends GradesOverviewState {}

class GradesOverviewLoading extends GradesOverviewState {}

class GradesOverviewCoursesLoaded extends GradesOverviewState {
  GradesOverviewCoursesLoaded(this.courses);
  final List<CourseOption> courses;
}

class GradesOverviewGradesLoaded extends GradesOverviewState {
  GradesOverviewGradesLoaded({
    required this.courses,
    required this.selectedCourse,
    required this.grades,
  });
  final List<CourseOption> courses;
  final CourseOption selectedCourse;
  final CourseGradesOverviewModel grades;
}

class GradesOverviewError extends GradesOverviewState {
  GradesOverviewError(this.message);
  final String message;
}
