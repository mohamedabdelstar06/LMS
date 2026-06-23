import 'package:equatable/equatable.dart';

abstract class DepartmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DepartmentInitial extends DepartmentState {}

class DepartmentLoading extends DepartmentState {}

class DepartmentSuccess extends DepartmentState {
  DepartmentSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class DepartmentError extends DepartmentState {
  DepartmentError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}