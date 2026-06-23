import 'package:lms/features/screens/student/student_courses/student_assignment_model.dart';


abstract class AssignmentStudentState {}

class AssignmentStudentInitial extends AssignmentStudentState {}

// ── List ─────────────────────────────────────────────
class AssignmentListLoading extends AssignmentStudentState {}

class AssignmentListSuccess extends AssignmentStudentState {
  AssignmentListSuccess(this.assignments);
  final List<StudentAssignmentModel> assignments;
}

class AssignmentListError extends AssignmentStudentState {
  AssignmentListError(this.message);
  final String message;
}

// ── Detail ───────────────────────────────────────────
class AssignmentDetailLoading extends AssignmentStudentState {}

class AssignmentDetailSuccess extends AssignmentStudentState {
  AssignmentDetailSuccess(this.assignment);
  final StudentAssignmentModel assignment;
}

class AssignmentDetailError extends AssignmentStudentState {
  AssignmentDetailError(this.message);
  final String message;
}

// ── Submission ───────────────────────────────────────
class AssignmentSubmitting extends AssignmentStudentState { // 0.0 - 1.0
  AssignmentSubmitting(this.progress);
  final double progress;
}

class AssignmentSubmitSuccess extends AssignmentStudentState {}

class AssignmentSubmitError extends AssignmentStudentState {
  AssignmentSubmitError(this.message);
  final String message;
}
