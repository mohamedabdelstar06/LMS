import 'package:equatable/equatable.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';

enum AssignmentStatus { initial, loading, success, failure }

enum AssignmentActionStatus { idle, loading, success, failure }

class AssignmentState extends Equatable {

  const AssignmentState({
    this.status = AssignmentStatus.initial,
    this.actionStatus = AssignmentActionStatus.idle,
    this.assignments = const [],
    this.selectedAssignment,
    this.submissions = const [],
    this.errorMessage,
    this.actionError,
    this.uploadProgresses = const [],
    this.isUploadingFiles = false,
  });
  final AssignmentStatus status;
  final AssignmentActionStatus actionStatus;
  final List<AssignmentModel> assignments;
  final AssignmentModel? selectedAssignment;
  final List<SubmissionModel> submissions;
  final String? errorMessage;
  final String? actionError;
  final List<UploadFileProgress> uploadProgresses;
  final bool isUploadingFiles;

  AssignmentState copyWith({
    AssignmentStatus? status,
    AssignmentActionStatus? actionStatus,
    List<AssignmentModel>? assignments,
    AssignmentModel? selectedAssignment,
    List<SubmissionModel>? submissions,
    String? errorMessage,
    String? actionError,
    List<UploadFileProgress>? uploadProgresses,
    bool? isUploadingFiles,
  }) => AssignmentState(
    status: status ?? this.status,
    actionStatus: actionStatus ?? this.actionStatus,
    assignments: assignments ?? this.assignments,
    selectedAssignment: selectedAssignment ?? this.selectedAssignment,
    submissions: submissions ?? this.submissions,
    errorMessage: errorMessage ?? this.errorMessage,
    actionError: actionError ?? this.actionError,
    uploadProgresses: uploadProgresses ?? this.uploadProgresses,
    isUploadingFiles: isUploadingFiles ?? this.isUploadingFiles,
  );

  @override
  List<Object?> get props => [
    status,
    actionStatus,
    assignments,
    selectedAssignment,
    submissions,
    errorMessage,
    actionError,
    uploadProgresses,
    isUploadingFiles,
  ];
}
