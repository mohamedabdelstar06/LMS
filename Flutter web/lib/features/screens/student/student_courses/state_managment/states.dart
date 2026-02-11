import 'package:lms/features/draft/test_models.dart';

import '../model/view.dart';



abstract class GetCourseStudentState {}

class GetCourseStudentInitial extends GetCourseStudentState {}

class GetCourseStudentLoading extends GetCourseStudentState {}

class GetCourseStudentSuccess extends GetCourseStudentState {
  final List<CourseEnrollmentModel> courses;
  GetCourseStudentSuccess(this.courses);
}

class GetCourseStudentError extends GetCourseStudentState {
  final String message;
  GetCourseStudentError(this.message);
}

