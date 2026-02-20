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
  final List<GetAllYearModel> years;

  const YearsLoaded(this.years);

  @override
  List<Object?> get props => [years];
}

class YearsError extends AllYearsState {
  final String message;
  final int? statusCode;
  const YearsError(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message];
}

class DeleteYearLoading extends AllYearsState {}

class DeleteYearSuccess extends AllYearsState {
  final String message;
  const DeleteYearSuccess(this.message);
}

class DeleteYearError extends AllYearsState {
  final String message;
  const DeleteYearError(this.message);
}

class UpdateYearLoading extends AllYearsState {}

class UpdateYearSuccess extends AllYearsState {
  final String message;
  const UpdateYearSuccess(this.message);
}

class UpdateYearError extends AllYearsState {
  final String message;
  final int? statusCode;
  const UpdateYearError(this.message, {this.statusCode});
}

class YearByIdLoading extends AllYearsState {}
class YearByIdLoaded extends AllYearsState {
  final GetAllYearModel year;

  const YearByIdLoaded(this.year);

  @override
  List<Object?> get props => [year];
}
class YearByIdError extends AllYearsState {
  final String message;
  final int? statusCode;
  const YearByIdError(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message];
}
