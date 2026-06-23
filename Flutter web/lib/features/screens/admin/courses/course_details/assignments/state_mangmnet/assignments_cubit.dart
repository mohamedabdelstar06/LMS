import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignmnet_repo.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/state_mangmnet/assignments_state.dart';



class AssignmentCubit extends Cubit<AssignmentState> {

  AssignmentCubit({
    required AssignmentRepository repository,
    required this.courseId,
  }) : _repository = repository,
       super(const AssignmentState());
  final AssignmentRepository _repository;
  final int courseId;

  // ── Load ────────────────────────────────────────────────────

  Future<void> loadAssignments() async {
    emit(state.copyWith(status: AssignmentStatus.loading));
    try {
      final list = await _repository.getCourseAssignments(courseId);
      emit(state.copyWith(status: AssignmentStatus.success, assignments: list));
    } catch (e) {
      emit(
        state.copyWith(
          status: AssignmentStatus.failure,
          errorMessage: _readable(e),
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
    DateTime? startDate,
    DateTime? deadlineDate,
    required List<PickedFileData> files,
  }) async {
    final progresses = files
        .map((f) => UploadFileProgress(fileName: f.name))
        .toList();

    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        uploadProgresses: progresses,
        isUploadingFiles: files.isNotEmpty,
      ),
    );

    // Animate progress bars concurrently with the real upload
    if (files.isNotEmpty) {
      _startAnimations(files.map((f) => f.name).toList());
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
        startDate: startDate,
        deadlineDate: deadlineDate,
        files: files,
        onFileProgress: _updateProgress,
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
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readable(e),
          uploadProgresses: state.uploadProgresses
              .map((p) => p.copyWith(hasError: true))
              .toList(),
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
    DateTime? startDate,
    DateTime? deadlineDate,
    List<PickedFileData> newFiles = const [],
  }) async {
    final progresses = newFiles
        .map((f) => UploadFileProgress(fileName: f.name))
        .toList();

    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        uploadProgresses: progresses,
        isUploadingFiles: newFiles.isNotEmpty,
      ),
    );

    if (newFiles.isNotEmpty) {
      _startAnimations(newFiles.map((f) => f.name).toList());
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
        startDate: startDate,
        deadlineDate: deadlineDate,
        newFiles: newFiles,
      );

      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.success,
          assignments: state.assignments
              .map((a) => a.id == assignmentId ? updated : a)
              .toList(),
          selectedAssignment: updated,
          uploadProgresses: [],
          isUploadingFiles: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readable(e),
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
          actionError: _readable(e),
        ),
      );
    }
  }

  // ── Submit (student) ────────────────────────────────────────

  Future<void> submitAssignment({
    required int assignmentId,
    required List<PickedFileData> files,
  }) async {
    final progresses = files
        .map((f) => UploadFileProgress(fileName: f.name))
        .toList();

    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
        uploadProgresses: progresses,
        isUploadingFiles: true,
      ),
    );

    _startAnimations(files.map((f) => f.name).toList());

    try {
      await _repository.submitAssignment(
        assignmentId: assignmentId,
        files: files,
        onFileProgress: _updateProgress,
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
          actionError: _readable(e),
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
          actionError: _readable(e),
        ),
      );
    }
  }

  // ── Submissions ─────────────────────────────────────────────

  Future<void> loadSubmissions(int assignmentId) async {
    emit(
      state.copyWith(
        actionStatus: AssignmentActionStatus.loading,
      ),
    );
    try {
      final subs = await _repository.getSubmissions(assignmentId);
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.success,
          submissions: subs,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: AssignmentActionStatus.failure,
          actionError: _readable(e),
        ),
      );
    }
  }

  // ── Progress helpers ────────────────────────────────────────

  void _updateProgress(String fileName, double progress) {
    if (isClosed) return;
    final updated = state.uploadProgresses.map((p) {
      if (p.fileName == fileName) {
        return p.copyWith(progress: progress, isCompleted: progress >= 1.0);
      }
      return p;
    }).toList();
    emit(state.copyWith(uploadProgresses: updated));
  }

  /// Fire-and-forget staggered animation: 0 → 0.85
  /// Real Dio onSendProgress will push each file to 1.0
  void _startAnimations(List<String> names) {
    for (int i = 0; i < names.length; i++) {
      _animateOne(names[i], delayMs: i * 100);
    }
  }

  Future<void> _animateOne(String name, {required int delayMs}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    for (int step = 1; step <= 17; step++) {
      if (isClosed) return;
      await Future.delayed(const Duration(milliseconds: 55));
      _updateProgress(name, step / 20.0); // 0.05 → 0.85
    }
  }

  // ── Misc ────────────────────────────────────────────────────

  void resetActionStatus() => emit(
    state.copyWith(
      actionStatus: AssignmentActionStatus.idle,
    ),
  );

  String _readable(Object e) {
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('Network')) {
      return 'Network error — check your connection';
    }
    if (s.contains('401')) return 'Session expired — please log in again';
    if (s.contains('403')) return 'You don\'t have permission for this';
    if (s.contains('404')) return 'Assignment not found';
    if (s.contains('413')) return 'File too large';
    if (s.contains('500')) return 'Server error — try again later';
    return s;
  }
}
