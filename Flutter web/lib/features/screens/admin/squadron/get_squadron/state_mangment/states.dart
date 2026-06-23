import 'package:equatable/equatable.dart';
import '../../get_squadron/model/view.dart';

abstract class GetSquadronsState extends Equatable {
  const GetSquadronsState();

  @override
  List<Object> get props => [];
}

class GetSquadronsInitial extends GetSquadronsState {}

class GetSquadronsLoading extends GetSquadronsState {}

class GetSquadronsLoaded extends GetSquadronsState {

  const GetSquadronsLoaded(this.squadrons);
  final List<SquadronModel> squadrons;

  @override
  List<Object> get props => [squadrons];
}

class GetSquadronsError extends GetSquadronsState {

  const GetSquadronsError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}