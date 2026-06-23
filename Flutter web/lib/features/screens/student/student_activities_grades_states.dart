// ============================================================
// student_activities_grades_states.dart
// ============================================================
import 'package:equatable/equatable.dart';
import 'student_activities_grades_models.dart';

// ── Activities States ─────────────────────────────────────────
abstract class StudentActivitiesState extends Equatable {
  const StudentActivitiesState();
  @override
  List<Object?> get props => [];
}

class StudentActivitiesInitial extends StudentActivitiesState {}

class StudentActivitiesLoading extends StudentActivitiesState {}

class StudentActivitiesLoadingMore extends StudentActivitiesState {
  const StudentActivitiesLoadingMore(this.current);
  final StudentActivitiesPage current;
  @override
  List<Object?> get props => [current];
}

class StudentActivitiesLoaded extends StudentActivitiesState {
  const StudentActivitiesLoaded({
    required this.data,
    this.activeType,
    this.activeStatus,
  });
  final StudentActivitiesPage data;
  final String? activeType;
  final String? activeStatus;
  @override
  List<Object?> get props => [data, activeType, activeStatus];
}

class StudentActivitiesError extends StudentActivitiesState {
  const StudentActivitiesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── Grades States ─────────────────────────────────────────────
abstract class CourseGradesState extends Equatable {
  const CourseGradesState();
  @override
  List<Object?> get props => [];
}

class CourseGradesInitial extends CourseGradesState {}

class CourseGradesLoading extends CourseGradesState {}

class CourseGradesLoaded extends CourseGradesState { // 0 = Overview, 1 = Quizzes, 2 = Assignments
  const CourseGradesLoaded({required this.grades, this.activeTab = 0});
  final CourseGrades grades;
  final int activeTab;
  @override
  List<Object?> get props => [grades, activeTab];

  CourseGradesLoaded copyWith({CourseGrades? grades, int? activeTab}) =>
      CourseGradesLoaded(
        grades: grades ?? this.grades,
        activeTab: activeTab ?? this.activeTab,
      );
}

class CourseGradesError extends CourseGradesState {
  const CourseGradesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
