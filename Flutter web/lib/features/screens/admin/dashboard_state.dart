part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {

  const DashboardLoaded({required this.stats, required this.overview});
  final DashboardStatsModel stats;
  final DashboardOverviewModel overview;

  @override
  List<Object?> get props => [stats, overview];
}

class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
