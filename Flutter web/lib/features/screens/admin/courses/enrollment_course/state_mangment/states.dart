import 'package:equatable/equatable.dart';

abstract class EnrollmentState extends Equatable {
  const EnrollmentState();

  @override
  List<Object?> get props => [];
}

class EnrollmentInitial extends EnrollmentState {}

class EnrollmentLoading extends EnrollmentState {}

class EnrollmentLoaded extends EnrollmentState {

  const EnrollmentLoaded(this.enrollments);
  final List<EnrollmentModel> enrollments;

  @override
  List<Object?> get props => [enrollments];
}

class EnrollmentActionSuccess extends EnrollmentState {

  const EnrollmentActionSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class EnrollmentError extends EnrollmentState {

  const EnrollmentError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
class EnrollmentModel {

  const EnrollmentModel({
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.courseName,
  });
  final int userId;
  final String userName;
  final int courseId;
  final String courseName;
}
