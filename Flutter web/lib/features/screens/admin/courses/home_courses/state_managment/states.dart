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
  const GetCourseSuccess(this.courses);
  final List<GetCoursesModel> courses;

  @override
  List<Object?> get props => [courses];
}

class GetCourseError extends GetCourseStates {
  const GetCourseError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class DeleteCourseLoading extends GetCourseStates {}

class DeleteCourseSuccess extends GetCourseStates {
  const DeleteCourseSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class DeleteCourseError extends GetCourseStates {
  const DeleteCourseError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class GetCourseByIdLoading extends GetCourseStates {}

class GetCourseByIdSuccess extends GetCourseStates {
  const GetCourseByIdSuccess(this.course);
  final GetCoursesModel course;

  @override
  List<Object?> get props => [course];
}

class GetCourseByIdError extends GetCourseStates {
  const GetCourseByIdError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class UpdateCourseLoading extends GetCourseStates {}

class UpdateCourseSuccess extends GetCourseStates {
  UpdateCourseSuccess(this.message) : timestamp = DateTime.now();
  final String message;
  final DateTime timestamp;

  @override
  List<Object?> get props => [message, timestamp];
}

class UpdateCourseError extends GetCourseStates {
  const UpdateCourseError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}