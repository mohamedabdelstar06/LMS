import 'course_detail_model.dart';

abstract class CourseDetailState {}

class CourseDetailInitial extends CourseDetailState {}

class CourseDetailLoading extends CourseDetailState {}

class CourseDetailSuccess extends CourseDetailState {
  CourseDetailSuccess(this.course);
  final CourseDetailModel course;
}

class CourseDetailError extends CourseDetailState {
  CourseDetailError(this.message);
  final String message;
}
