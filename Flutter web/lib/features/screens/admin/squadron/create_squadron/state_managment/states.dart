import 'package:equatable/equatable.dart';

abstract class SquadronState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SquadronInitial extends SquadronState {}

class SquadronLoading extends SquadronState {}

class SquadronSuccess extends SquadronState {
  SquadronSuccess(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class SquadronError extends SquadronState {
  SquadronError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}