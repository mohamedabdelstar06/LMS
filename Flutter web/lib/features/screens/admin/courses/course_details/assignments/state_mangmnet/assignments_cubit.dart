import 'dart:async';
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
  }) : _repository = repository,
       super(const AssignmentState());

  // ── Load ────────────────────────────────────────────────────

  Future<void> loadAssignments() async {
    emit(state.copyWith(status: AssignmentStatus.loading, errorMessage: null));
    try {
      final assignments = await _repository.getCourseAssignments(courseId);
      emit(
        state.copyWith(
          status: AssignmentStatus.success,
          assignments: assignments,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AssignmentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadAssignmentDetail(int assignmentId) async {
    emit(state.copyWith(actionStatus: AssignmentActionStatus.loading));
    try {
      final assignment = await _repository.getAssignmentById(assignmentId);
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.success,
          selectedAssignment: assignment,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: e.toString(),
        ),
      );
    }
  }

  // ── Create ──────────────────────────────────────────────────

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
    // Initialise per-file progress entries
    final progresses = files
        .map((f) => UploadFileProgress(fileName: f.path.split('/').last))
        .toList();

    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        uploadProgresses: progresses,
        isUploadingFiles: files.isNotEmpty,
        actionError: null,
      ),
    );

    // ✅ FIX: fire-and-forget the animation timers — don't await them
    //    so they run concurrently with the real Dio upload
    if (files.isNotEmpty) {
      _startProgressAnimations(
        files.map((f) => f.path.split('/').last).toList(),
      );
    }

    try {
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
        // Real Dio progress drives these updates too
        onFileProgress: (fileName, progress) =>
            _updateSingleFileProgress(fileName, progress),
      );

      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.success,
          assignments: [...state.assignments, assignment],
          uploadProgresses: [],
          isUploadingFiles: false,
        ),
      );
    } catch (e) {
      // Mark all files as errored
      final failed = state.uploadProgresses
          .map((p) => p.copyWith(hasError: true))
          .toList();
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readableError(e),
          uploadProgresses: failed,
          isUploadingFiles: false,
        ),
      );
    }
  }

  // ── Update ──────────────────────────────────────────────────

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
    final progresses = newFiles
        .map((f) => UploadFileProgress(fileName: f.path.split('/').last))
        .toList();

    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        uploadProgresses: progresses,
        isUploadingFiles: newFiles.isNotEmpty,
        actionError: null,
      ),
    );

    if (newFiles.isNotEmpty) {
      _startProgressAnimations(
        newFiles.map((f) => f.path.split('/').last).toList(),
      );
    }

    try {
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

      final updatedList = state.assignments
          .map((a) => a.id == assignmentId ? updated : a)
          .toList();

      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.success,
          assignments: updatedList,
          selectedAssignment: updated,
          uploadProgresses: [],
          isUploadingFiles: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readableError(e),
          uploadProgresses: state.uploadProgresses
              .map((p) => p.copyWith(hasError: true))
              .toList(),
          isUploadingFiles: false,
        ),
      );
    }
  }

  // ── Delete ──────────────────────────────────────────────────

  Future<void> deleteAssignment(int assignmentId) async {
    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        actionError: null,
      ),
    );
    try {
      await _repository.deleteAssignment(assignmentId);
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.success,
          assignments: state.assignments
              .where((a) => a.id != assignmentId)
              .toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readableError(e),
        ),
      );
    }
  }

  // ── Submit (student) ────────────────────────────────────────

  Future<void> submitAssignment({
    required int assignmentId,
    required List<File> files,
  }) async {
    final progresses = files
        .map((f) => UploadFileProgress(fileName: f.path.split('/').last))
        .toList();

    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        uploadProgresses: progresses,
        isUploadingFiles: true,
        actionError: null,
      ),
    );

    _startProgressAnimations(files.map((f) => f.path.split('/').last).toList());

    try {
      await _repository.submitAssignment(
        assignmentId: assignmentId,
        files: files,
        onFileProgress: (fileName, progress) =>
            _updateSingleFileProgress(fileName, progress),
      );

      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.success,
          uploadProgresses: [],
          isUploadingFiles: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readableError(e),
          isUploadingFiles: false,
        ),
      );
    }
  }

  // ── Grade ───────────────────────────────────────────────────

  Future<void> gradeSubmission({
    required int assignmentId,
    required int studentId,
    required int grade,
    required String feedback,
  }) async {
    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        actionError: null,
      ),
    );
    try {
      await _repository.gradeSubmission(
        assignmentId: assignmentId,
        studentId: studentId,
        grade: grade,
        feedback: feedback,
      );
      emit(state.copyWith(actionStatus: AssignmentActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readableError(e),
        ),
      );
    }
  }

  // ── Submissions ─────────────────────────────────────────────

  Future<void> loadSubmissions(int assignmentId) async {
    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        actionError: null,
      ),
    );
    try {
      final submissions = await _repository.getSubmissions(assignmentId);
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.success,
          submissions: submissions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readableError(e),
        ),
      );
    }
  }

  // ── Progress helpers ────────────────────────────────────────

  /// Called by Dio's onSendProgress (real network progress).
  void _updateSingleFileProgress(String fileName, double progress) {
    if (isClosed) return;
    final updated = state.uploadProgresses.map((p) {
      if (p.fileName == fileName) {
        return p.copyWith(progress: progress, isCompleted: progress >= 1.0);
      }
      return p;
    }).toList();
    emit(state.copyWith(uploadProgresses: updated));
  }

  /// ✅ FIX: unawaited timers — each file animates independently
  ///    without blocking the actual upload future.
  void _startProgressAnimations(List<String> fileNames) {
    for (int i = 0; i < fileNames.length; i++) {
      _animateFile(fileNames[i], delayMs: i * 120);
    }
  }

  Future<void> _animateFile(String fileName, {required int delayMs}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    // Animate from 0 → 0.85 in smooth steps
    // (the real Dio progress will push it to 1.0)
    for (int step = 1; step <= 17; step++) {
      if (isClosed) return;
      await Future.delayed(const Duration(milliseconds: 60));
      _updateSingleFileProgress(fileName, step / 20.0); // 0.05 → 0.85
    }
  }

  // ── Misc ────────────────────────────────────────────────────

  void resetActionStatus() {
    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.idle,
        actionError: null,
      ),
    );
  }

  String _readableError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Network')) {
      return 'Network error — check your connection';
    }
    if (msg.contains('401')) return 'Session expired — please log in again';
    if (msg.contains('403')) return 'You don\'t have permission to do that';
    if (msg.contains('404')) return 'Assignment not found';
    if (msg.contains('413')) return 'File too large — max upload size exceeded';
    if (msg.contains('500')) return 'Server error — please try again later';
    return msg;
  }
}
