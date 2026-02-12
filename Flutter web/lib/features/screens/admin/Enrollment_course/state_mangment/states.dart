import 'package:equatable/equatable.dart';

abstract class EnrollmentState extends Equatable {
  const EnrollmentState();

  @override
  List<Object?> get props => [];
}

class EnrollmentInitial extends EnrollmentState {}

class EnrollmentLoading extends EnrollmentState {}

class EnrollmentLoaded extends EnrollmentState {
  final List<EnrollmentModel> enrollments;

  const EnrollmentLoaded(this.enrollments);

  @override
  List<Object?> get props => [enrollments];
}

class EnrollmentActionSuccess extends EnrollmentState {
  final String message;

  const EnrollmentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EnrollmentError extends EnrollmentState {
  final String message;

  const EnrollmentError(this.message);

  @override
  List<Object?> get props => [message];
}
class EnrollmentModel {
  final int userId;
  final String userName;
  final int courseId;
  final String courseName;

  const EnrollmentModel({
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.courseName,
  });
}
