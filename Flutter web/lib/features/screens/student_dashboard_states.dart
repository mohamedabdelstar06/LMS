import 'package:equatable/equatable.dart';
import 'package:lms/features/screens/student_dashboard_cubit.dart';

abstract class StudentDashboardState extends Equatable {
  const StudentDashboardState();
  @override
  List<Object?> get props => [];
}

class StudentDashboardInitial extends StudentDashboardState {}

class StudentDashboardLoading extends StudentDashboardState {}

class StudentDashboardLoaded extends StudentDashboardState {
  const StudentDashboardLoaded({
    required this.model,
    required this.analytics,
  });
  final StudentDashboardModel model;
  final StudentAnalyticsModel analytics;
  @override
  List<Object?> get props => [model, analytics];
}

class StudentDashboardError extends StudentDashboardState {
  const StudentDashboardError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
