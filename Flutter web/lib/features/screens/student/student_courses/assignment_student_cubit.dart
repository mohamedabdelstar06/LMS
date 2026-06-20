import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      _cachedList = list;
      emit(AssignmentListSuccess(list));
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
      emit(AssignmentDetailSuccess(assignment));
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
