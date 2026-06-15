import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignmnet_repo.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/state_mangmnet/assignments_state.dart';


class AssignmentCubit extends Cubit<AssignmentState> {
  final AssignmentRepository _repository;
  final int courseId;

  AssignmentCubit({
    required AssignmentRepository repository,
    required this.courseId,
  })  : _repository = repository,
        super(const AssignmentState());

  Future<void> loadAssignments() async {
    emit(state.copyWith(status: AssignmentStatus.loading, errorMessage: null));
    try {
      final assignments = await _repository.getCourseAssignments(courseId);
      emit(state.copyWith(
        status: AssignmentStatus.success,
        assignments: assignments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AssignmentStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadAssignmentDetail(int assignmentId) async {
    emit(state.copyWith(actionStatus: AssignmentActionStatus.loading));
    try {
      final assignment = await _repository.getAssignmentById(assignmentId);
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.success,
        selectedAssignment: assignment,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.failure,
        actionError: e.toString(),
      ));
    }
  }

  Future<void> createAssignment({
    required String title,
    required String description,
    required String instructions,
    required int maxGrade,
    required bool allowLateSubmission,
    required bool isVisible,
    int? targetSquadronId,
    required List<File> files,
  }) async {
    // Initialize per-file progress
    final progresses = files
        .map((f) => UploadFileProgress(fileName: f.path.split('/').last))
        .toList();
    emit(state.copyWith(
      actionStatus: AssignmentActionStatus.loading,
      uploadProgresses: progresses,
      isUploadingFiles: files.isNotEmpty,
      actionError: null,
    ));

    try {
      // Simulate per-file progress (Dio's onSendProgress gives overall)
      // We stagger the file progress animations
      if (files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          _simulateFileProgress(i, files[i].path.split('/').last);
        }
      }

      final assignment = await _repository.createAssignment(
        courseId: courseId,
        title: title,
        description: description,
        instructions: instructions,
        maxGrade: maxGrade,
        allowLateSubmission: allowLateSubmission,
        isVisible: isVisible,
        targetSquadronId: targetSquadronId,
        files: files,
        onFileProgress: (fileName, progress) => _updateFileProgress(fileName, progress),
      );

      final updatedList = [...state.assignments, assignment];
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.success,
        assignments: updatedList,
        uploadProgresses: [],
        isUploadingFiles: false,
      ));
    } catch (e) {
      final failedProgresses = state.uploadProgresses
          .map((p) => p.copyWith(hasError: true))
          .toList();
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.failure,
        actionError: e.toString(),
        uploadProgresses: failedProgresses,
        isUploadingFiles: false,
      ));
    }
  }

  Future<void> updateAssignment({
    required int assignmentId,
    required String title,
    required String description,
    required String instructions,
    required int maxGrade,
    required bool allowLateSubmission,
    required bool isVisible,
    int? targetSquadronId,
    List<File> newFiles = const [],
  }) async {
    emit(state.copyWith(
      actionStatus: AssignmentActionStatus.loading,
      isUploadingFiles: newFiles.isNotEmpty,
      uploadProgresses: newFiles
          .map((f) => UploadFileProgress(fileName: f.path.split('/').last))
          .toList(),
      actionError: null,
    ));

    try {
      for (int i = 0; i < newFiles.length; i++) {
        _simulateFileProgress(i, newFiles[i].path.split('/').last);
      }

      final updated = await _repository.updateAssignment(
        id: assignmentId,
        courseId: courseId,
        title: title,
        description: description,
        instructions: instructions,
        maxGrade: maxGrade,
        allowLateSubmission: allowLateSubmission,
        isVisible: isVisible,
        targetSquadronId: targetSquadronId,
        newFiles: newFiles,
      );

      final updatedList = state.assignments.map((a) {
        return a.id == assignmentId ? updated : a;
      }).toList();

      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.success,
        assignments: updatedList,
        selectedAssignment: updated,
        uploadProgresses: [],
        isUploadingFiles: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.failure,
        actionError: e.toString(),
        isUploadingFiles: false,
      ));
    }
  }

  Future<void> deleteAssignment(int assignmentId) async {
    emit(state.copyWith(
      actionStatus: AssignmentActionStatus.loading,
      actionError: null,
    ));
    try {
      await _repository.deleteAssignment(assignmentId);
      final updatedList =
          state.assignments.where((a) => a.id != assignmentId).toList();
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.success,
        assignments: updatedList,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.failure,
        actionError: e.toString(),
      ));
    }
  }

  Future<void> submitAssignment({
    required int assignmentId,
    required List<File> files,
  }) async {
    final progresses = files
        .map((f) => UploadFileProgress(fileName: f.path.split('/').last))
        .toList();
    emit(state.copyWith(
      actionStatus: AssignmentActionStatus.loading,
      uploadProgresses: progresses,
      isUploadingFiles: true,
      actionError: null,
    ));

    try {
      for (int i = 0; i < files.length; i++) {
        _simulateFileProgress(i, files[i].path.split('/').last);
      }

      await _repository.submitAssignment(
        assignmentId: assignmentId,
        files: files,
        onFileProgress: (fileName, progress) => _updateFileProgress(fileName, progress),
      );

      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.success,
        uploadProgresses: [],
        isUploadingFiles: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.failure,
        actionError: e.toString(),
        isUploadingFiles: false,
      ));
    }
  }

  Future<void> gradeSubmission({
    required int assignmentId,
    required int studentId,
    required int grade,
    required String feedback,
  }) async {
    emit(state.copyWith(
      actionStatus: AssignmentActionStatus.loading,
      actionError: null,
    ));
    try {
      await _repository.gradeSubmission(
        assignmentId: assignmentId,
        studentId: studentId,
        grade: grade,
        feedback: feedback,
      );
      emit(state.copyWith(actionStatus: AssignmentActionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.failure,
        actionError: e.toString(),
      ));
    }
  }

  Future<void> loadSubmissions(int assignmentId) async {
    emit(state.copyWith(
      actionStatus: AssignmentActionStatus.loading,
      actionError: null,
    ));
    try {
      final submissions = await _repository.getSubmissions(assignmentId);
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.success,
        submissions: submissions,
      ));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: AssignmentActionStatus.failure,
        actionError: e.toString(),
      ));
    }
  }

  void _updateFileProgress(String fileName, double progress) {
    final updated = state.uploadProgresses.map((p) {
      if (p.fileName == fileName) {
        return p.copyWith(
          progress: progress,
          isCompleted: progress >= 1.0,
        );
      }
      return p;
    }).toList();
    emit(state.copyWith(uploadProgresses: updated));
  }

  // Simulates staggered per-file progress for visual feedback
  void _simulateFileProgress(int fileIndex, String fileName) async {
    final delay = Duration(milliseconds: fileIndex * 200);
    await Future.delayed(delay);

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      _updateFileProgress(fileName, i / 10.0);
    }
  }

  void resetActionStatus() {
    emit(state.copyWith(
      actionStatus: AssignmentActionStatus.idle,
      actionError: null,
    ));
  }
}