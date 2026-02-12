import 'package:equatable/equatable.dart';

abstract class EnrollmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EnrollmentInitial extends EnrollmentState {}

class EnrollmentLoading extends EnrollmentState {}

class EnrollmentSuccess extends EnrollmentState {
  final String message;
  EnrollmentSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class EnrollmentError extends EnrollmentState {
  final String message;
  EnrollmentError(this.message);
  @override
  List<Object?> get props => [message];
}