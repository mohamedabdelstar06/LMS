import 'package:equatable/equatable.dart';

import '../model/model.dart';

abstract class GetCourseStates extends Equatable {
  const GetCourseStates();

  @override
  List<Object?> get props => [];
}

class GetCourseInitial extends GetCourseStates {}

class GetCourseLoading extends GetCourseStates {}

class GetCourseSuccess extends GetCourseStates {
  final List<GetCoursesModel> courses;
  const GetCourseSuccess(this.courses);

  @override
  List<Object?> get props => [courses];
}

class GetCourseError extends GetCourseStates {
  final String message;
  const GetCourseError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteCourseLoading extends GetCourseStates {}

class DeleteCourseSuccess extends GetCourseStates {
  final String message;
  const DeleteCourseSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteCourseError extends GetCourseStates {
  final String message;
  const DeleteCourseError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetCourseByIdLoading extends GetCourseStates {}

class GetCourseByIdSuccess extends GetCourseStates {
  final GetCoursesModel course;
  const GetCourseByIdSuccess(this.course);

  @override
  List<Object?> get props => [course];
}

class GetCourseByIdError extends GetCourseStates {
  final String message;
  const GetCourseByIdError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateCourseLoading extends GetCourseStates {}

class UpdateCourseSuccess extends GetCourseStates {
  final String message;
  final DateTime timestamp;
  UpdateCourseSuccess(this.message) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [message, timestamp];
}

class UpdateCourseError extends GetCourseStates {
  const UpdateCourseError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}