import 'package:equatable/equatable.dart';

import '../all_model/model.dart';

abstract class DepartmentsState extends Equatable {
  const DepartmentsState();

  @override
  List<Object?> get props => [];
}

class DepartmentsInitial extends DepartmentsState {}

class DepartmentsLoading extends DepartmentsState {}

class DepartmentsLoaded extends DepartmentsState {

  const DepartmentsLoaded(this.departments);
  final List<GetAllDepartmentModel> departments;

  @override
  List<Object?> get props => [departments];
}

class DepartmentsError extends DepartmentsState {
  const DepartmentsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class DeleteDepartmentLoading extends DepartmentsState {}

class DeleteDepartmentSuccess extends DepartmentsState {
  const DeleteDepartmentSuccess(this.message);
  final String message;
}

class DeleteDepartmentError extends DepartmentsState {
  const DeleteDepartmentError(this.message);
  final String message;
}

class UpdateDepartmentLoading extends DepartmentsState {}

class UpdateDepartmentSuccess extends DepartmentsState {
  const UpdateDepartmentSuccess(this.message);
  final String message;
}

class UpdateDepartmentError extends DepartmentsState {
  const UpdateDepartmentError(this.message);
  final String message;
}

class DepartmentByIdLoading extends DepartmentsState {}
class DepartmentByIdLoaded extends DepartmentsState {

  const DepartmentByIdLoaded(this.department);
  final GetAllDepartmentModel department;

  @override
  List<Object?> get props => [department];
}
class DepartmentByIdError extends DepartmentsState {
  const DepartmentByIdError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

