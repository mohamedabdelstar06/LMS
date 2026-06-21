import 'course_detail_model.dart';

abstract class CourseDetailState {}

class CourseDetailInitial extends CourseDetailState {}

class CourseDetailLoading extends CourseDetailState {}

class CourseDetailSuccess extends CourseDetailState {
  final CourseDetailModel course;
  CourseDetailSuccess(this.course);
}

class CourseDetailError extends CourseDetailState {
  final String message;
  CourseDetailError(this.message);
}
