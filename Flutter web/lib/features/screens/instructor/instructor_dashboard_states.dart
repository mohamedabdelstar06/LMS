import 'instructor_dashboard_model.dart';

abstract class InstructorDashboardState {}

class InstructorDashboardInitial extends InstructorDashboardState {}

class InstructorDashboardLoading extends InstructorDashboardState {}

class InstructorDashboardLoaded extends InstructorDashboardState {
  final InstructorDashboardModel model;
  InstructorDashboardLoaded(this.model);
}

class InstructorDashboardError extends InstructorDashboardState {
  final String message;
  InstructorDashboardError(this.message);
}
/*import 'instructor_dashboard_model.dart';

abstract class InstructorDashboardState {}

class InstructorDashboardInitial extends InstructorDashboardState {}

class InstructorDashboardLoading extends InstructorDashboardState {}

class InstructorDashboardLoaded extends InstructorDashboardState {
  final InstructorDashboardModel model;
  InstructorDashboardLoaded(this.model);
}

class InstructorDashboardError extends InstructorDashboardState {
  final String message;
  InstructorDashboardError(this.message);
}
*/