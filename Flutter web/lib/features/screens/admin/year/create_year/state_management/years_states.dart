import 'package:equatable/equatable.dart';

abstract class YearState extends Equatable {
  @override
  List<Object?> get props => [];
}

class YearInitial extends YearState {}

class YearLoading extends YearState {}

class YearSuccess extends YearState {
  YearSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class YearError extends YearState {
  YearError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}