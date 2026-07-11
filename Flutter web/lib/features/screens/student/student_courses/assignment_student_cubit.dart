import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/helpers/cach_helper/submission_tracker.dart';
import 'package:lms/features/screens/student/student_courses/student_assignment_model.dart';
import 'package:lms/features/screens/student/student_courses/student_assignment_repository.dart';

import 'assignment_student_states.dart';

class AssignmentStudentCubit extends Cubit<AssignmentStudentState> {
  AssignmentStudentCubit({StudentAssignmentRepository? repository})
      : _repository = repository ?? StudentAssignmentRepository(),
        super(AssignmentStudentInitial());

  final StudentAssignmentRepository _repository;

  List<StudentAssignmentModel> _cachedList = [];
  List<StudentAssignmentModel> get cachedList => _cachedList;

  Future<void> loadAssignments(int courseId) async {
    emit(AssignmentListLoading());
    try {
      final list = await _repository.getCourseAssignments(courseId);
      // Check local tracker for any assignments that were submitted
      // but backend hasn't caught up yet
      final submittedIds = await SubmissionTracker.getSubmittedIds();
      _cachedList = list.map((a) {
        if (submittedIds.contains(a.id) && !a.isSubmitted) {
          return StudentAssignmentModel(
            id: a.id,
            courseId: a.courseId,
            title: a.title,
            description: a.description,
            instructions: a.instructions,
            maxGrade: a.maxGrade,
            allowLateSubmission: a.allowLateSubmission,
            startDate: a.startDate,
            deadlineDate: a.deadlineDate,
            targetSquadronId: a.targetSquadronId,
            targetSquadronName: a.targetSquadronName,
            submissionCount: 1,
            isVisible: a.isVisible,
            createdById: a.createdById,
            createdByName: a.createdByName,
            createdAt: a.createdAt,
            fileUrls: a.fileUrls,
          );
        }
        return a;
      }).toList();
      emit(AssignmentListSuccess(_cachedList));
    } on DioException catch (e) {
      emit(AssignmentListError(_readable(e)));
    } catch (e) {
      emit(AssignmentListError(e.toString()));
    }
  }

  Future<void> loadAssignmentDetail(int assignmentId) async {
    emit(AssignmentDetailLoading());
    try {
      final assignment = await _repository.getAssignmentById(assignmentId);
      // Check local tracker: if we know it was submitted but the backend
      // hasn't caught up yet, override the submission count
      final locallySubmitted = await SubmissionTracker.isSubmitted(assignmentId);
      final effectiveAssignment = (locallySubmitted && !assignment.isSubmitted)
          ? StudentAssignmentModel(
              id: assignment.id,
              courseId: assignment.courseId,
              title: assignment.title,
              description: assignment.description,
              instructions: assignment.instructions,
              maxGrade: assignment.maxGrade,
              allowLateSubmission: assignment.allowLateSubmission,
              startDate: assignment.startDate,
              deadlineDate: assignment.deadlineDate,
              targetSquadronId: assignment.targetSquadronId,
              targetSquadronName: assignment.targetSquadronName,
              submissionCount: 1, // override to show as submitted
              isVisible: assignment.isVisible,
              createdById: assignment.createdById,
              createdByName: assignment.createdByName,
              createdAt: assignment.createdAt,
              fileUrls: assignment.fileUrls,
            )
          : assignment;
      emit(AssignmentDetailSuccess(effectiveAssignment));
    } on DioException catch (e) {
      emit(AssignmentDetailError(_readable(e)));
    } catch (e) {
      emit(AssignmentDetailError(e.toString()));
    }
  }

  Future<bool> submitAssignment({
    required int assignmentId,
    required List<PickedSubmissionFile> files,
  }) async {
    emit(AssignmentSubmitting(0));
    try {
      await _repository.submitAssignment(
        assignmentId: assignmentId,
        files: files,
        onSendProgress: (sent, total) {
          if (total > 0) {
            emit(AssignmentSubmitting(sent / total));
          }
        },
      );
      // Mark as submitted locally so status updates immediately
      await SubmissionTracker.markSubmitted(assignmentId);
      emit(AssignmentSubmitSuccess());
      await loadAssignmentDetail(assignmentId);
      return true;
    } on DioException catch (e) {
      emit(AssignmentSubmitError(_readable(e)));
      return false;
    } catch (e) {
      emit(AssignmentSubmitError(e.toString()));
      return false;
    }
  }

  String _readable(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    if (status == 401) return 'Session expired — please log in again';
    if (status == 403) return "You don't have permission for this";
    if (status == 404) return 'Assignment not found';
    if (status == 413) return 'File too large';
    if (status == 500) return 'Server error — try again later';
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Network error — check your connection';
    }
    return e.message ?? 'Something went wrong';
  }
}
