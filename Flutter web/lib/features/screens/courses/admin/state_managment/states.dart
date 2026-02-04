import 'package:lms/features/draft/test_models.dart';

import '../model/model.dart';


abstract class GetCourseState {}

class GetCourseInitial extends GetCourseState {}

class GetCourseLoading extends GetCourseState {}

class GetCourseSuccess extends GetCourseState {
  final List<GetCourseModel> courses;
  GetCourseSuccess(this.courses);
}

class GetCourseError extends GetCourseState {
  final String message;
  GetCourseError(this.message);
}

