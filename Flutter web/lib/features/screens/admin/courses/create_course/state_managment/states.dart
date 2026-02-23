import 'package:equatable/equatable.dart';

abstract class CreateCourseState extends Equatable {
  @override
  List<Object?> get props => [];
}


class CreateCourseInitial extends CreateCourseState {}

class CreateCourseLoading extends CreateCourseState {}

class CreateCourseSuccess extends CreateCourseState {
   CreateCourseSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class CreateCourseError extends CreateCourseState {
   CreateCourseError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

