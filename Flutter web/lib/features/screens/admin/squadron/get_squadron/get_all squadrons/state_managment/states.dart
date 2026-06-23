import 'package:equatable/equatable.dart';
import '../../model/view.dart';

abstract class AllSquadronState extends Equatable {
  const AllSquadronState();

  @override
  List<Object?> get props => [];
}

class AllSquadronInitial extends AllSquadronState {}

class AllSquadronLoading extends AllSquadronState {}

class AllSquadronLoaded extends AllSquadronState {

  const AllSquadronLoaded(this.squadrons);
  final List<SquadronModel> squadrons;

  @override
  List<Object?> get props => [squadrons];
}

class AllSquadronError extends AllSquadronState {

  const AllSquadronError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
class GetSquadronByIdLoading extends AllSquadronState {}

class GetSquadronByIdLoaded extends AllSquadronState {

  const GetSquadronByIdLoaded(this.squadron);
  final SquadronModel squadron;
}

class UpdateSquadronLoading extends AllSquadronState {}

class UpdateSquadronSuccess extends AllSquadronState {

  const UpdateSquadronSuccess(this.message);
  final String message;
}

class UpdateSquadronError extends AllSquadronState {

  const UpdateSquadronError(this.message);
  final String message;
}
class DeleteSquadronLoading extends AllSquadronState {}

class DeleteSquadronSuccess extends AllSquadronState {
  const DeleteSquadronSuccess(this.message);
  final String message;
}
class DeleteSquadronError extends AllSquadronState {
  const DeleteSquadronError(this.message);
  final String message;
}


