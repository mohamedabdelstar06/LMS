
import '../model/view.dart';



abstract class GetCourseStudentState {}

class GetCourseStudentInitial extends GetCourseStudentState {}

class GetCourseStudentLoading extends GetCourseStudentState {}

class GetCourseStudentSuccess extends GetCourseStudentState {
  GetCourseStudentSuccess(this.courses);
  final List<CourseEnrollmentModel> courses;
}

class GetCourseStudentError extends GetCourseStudentState {
  GetCourseStudentError(this.message);
  final String message;
}

