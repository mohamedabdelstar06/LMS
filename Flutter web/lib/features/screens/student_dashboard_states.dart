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
  final StudentDashboardModel model;
  const StudentDashboardLoaded({required this.model});
  @override
  List<Object?> get props => [model];
}

class StudentDashboardError extends StudentDashboardState {
  final String message;
  const StudentDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
