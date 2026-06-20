import 'package:lms/features/screens/student/student_courses/student_assignment_model.dart';


abstract class AssignmentStudentState {}

class AssignmentStudentInitial extends AssignmentStudentState {}

// ── List ─────────────────────────────────────────────
class AssignmentListLoading extends AssignmentStudentState {}

class AssignmentListSuccess extends AssignmentStudentState {
  final List<StudentAssignmentModel> assignments;
  AssignmentListSuccess(this.assignments);
}

class AssignmentListError extends AssignmentStudentState {
  final String message;
  AssignmentListError(this.message);
}

// ── Detail ───────────────────────────────────────────
class AssignmentDetailLoading extends AssignmentStudentState {}

class AssignmentDetailSuccess extends AssignmentStudentState {
  final StudentAssignmentModel assignment;
  AssignmentDetailSuccess(this.assignment);
}

class AssignmentDetailError extends AssignmentStudentState {
  final String message;
  AssignmentDetailError(this.message);
}

// ── Submission ───────────────────────────────────────
class AssignmentSubmitting extends AssignmentStudentState {
  final double progress; // 0.0 - 1.0
  AssignmentSubmitting(this.progress);
}

class AssignmentSubmitSuccess extends AssignmentStudentState {}

class AssignmentSubmitError extends AssignmentStudentState {
  final String message;
  AssignmentSubmitError(this.message);
}
