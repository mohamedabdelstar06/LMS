import 'package:equatable/equatable.dart';

import '../all_model/model.dart';


abstract class AllYearsState extends Equatable {
  const AllYearsState();

  @override
  List<Object?> get props => [];
}

class YearsInitial extends AllYearsState {}

class YearsLoading extends AllYearsState {}

class YearsLoaded extends AllYearsState {

  const YearsLoaded(this.years);
  final List<GetAllYearModel> years;

  @override
  List<Object?> get props => [years];
}

class YearsError extends AllYearsState {
  const YearsError(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message];
}

class DeleteYearLoading extends AllYearsState {}

class DeleteYearSuccess extends AllYearsState {
  const DeleteYearSuccess(this.message);
  final String message;
}

class DeleteYearError extends AllYearsState {
  const DeleteYearError(this.message);
  final String message;
}

class UpdateYearLoading extends AllYearsState {}

class UpdateYearSuccess extends AllYearsState {
  const UpdateYearSuccess(this.message);
  final String message;
}

class UpdateYearError extends AllYearsState {
  const UpdateYearError(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

class YearByIdLoading extends AllYearsState {}
class YearByIdLoaded extends AllYearsState {

  const YearByIdLoaded(this.year);
  final GetAllYearModel year;

  @override
  List<Object?> get props => [year];
}
class YearByIdError extends AllYearsState {
  const YearByIdError(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message];
}
