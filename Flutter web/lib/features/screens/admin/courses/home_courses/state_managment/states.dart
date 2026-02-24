
import '../model/model.dart';


abstract class GetCourseStates {}

class GetCourseInitial extends GetCourseStates {}

class GetCourseLoading extends GetCourseStates {}

class GetCourseSuccess extends GetCourseStates {
  final List<GetCoursesModel> courses;
  GetCourseSuccess(this.courses);
}

class GetCourseError extends GetCourseStates {
  final String message;
  GetCourseError(this.message);
}

class DeleteCourseLoading extends GetCourseStates{}
class DeleteCourseSuccess extends GetCourseStates{
  DeleteCourseSuccess(this.message);
  final String message;
}
class DeleteCourseError extends GetCourseStates{
  DeleteCourseError(this.message);
  final String message;
}


class GetCourseByIdLoading extends GetCourseStates {}
class GetCourseByIdSuccess extends GetCourseStates {
  GetCourseByIdSuccess(this.course);
  final GetCoursesModel course;
}
class GetCourseByIdError extends GetCourseStates {
  GetCourseByIdError(this.message);
  final String message;
}