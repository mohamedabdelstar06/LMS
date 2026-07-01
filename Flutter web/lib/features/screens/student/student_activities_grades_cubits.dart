// ============================================================
// student_activities_grades_cubits.dart
// ============================================================
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/core/helpers/cach_helper/submission_tracker.dart';

import 'student_activities_grades_models.dart';
import 'student_activities_grades_states.dart';

// ── Activities Cubit ──────────────────────────────────────────
class StudentActivitiesCubit extends Cubit<StudentActivitiesState> {

  StudentActivitiesCubit({Dio? dio})
      : _dio = dio ?? Dio(),
        super(StudentActivitiesInitial());
  final Dio _dio;

  String? _activeType;
  String? _activeStatus;
  int? _courseId;
  String? _search;
  int _currentPage = 1;
  static const int _pageSize = 20;

  Future<void> load({
    int? courseId,
    String? activityType,
    String? status,
    String? search,
    bool reset = true,
  }) async {
    if (reset) {
      _currentPage = 1;
      _activeType = activityType;
      _activeStatus = status;
      _courseId = courseId;
      _search = search;
      emit(StudentActivitiesLoading());
    } else {
      final current = state;
      if (current is StudentActivitiesLoaded) {
        emit(StudentActivitiesLoadingMore(current.data));
      }
    }

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      final resp = await _dio.get(
        '${ApiResources.apiUrl}students/me/activities',
        queryParameters: {
          'PageNumber': _currentPage,
          'PageSize': _pageSize,
          if (_activeType != null) 'ActivityType': _activeType,
          if (_activeStatus != null) 'Status': _activeStatus,
          if (_courseId != null) 'CourseId': _courseId,
          if (_search != null && _search!.isNotEmpty) 'Search': _search,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final page = StudentActivitiesPage.fromJson(resp.data);

      // Filter out submitted assignments and closed quizzes (hide them from the list)
      final submittedIds = await SubmissionTracker.getSubmittedIds();
      final filteredItems = page.items.where((item) {
        // Hide assignments that are completed (submitted)
        if (item.activityType == 'Assignment' && item.status == 'Completed') {
          return false;
        }
        // Also hide if we locally tracked it as submitted
        if (item.activityType == 'Assignment' && submittedIds.contains(item.id)) {
          return false;
        }
        // Hide closed quizzes (deadline passed and not completed)
        if (item.activityType == 'Quiz' && item.status == 'Overdue') {
          return false;
        }
        return true;
      }).toList();

      final filteredPage = StudentActivitiesPage(
        items: filteredItems,
        totalCount: page.totalCount - (page.items.length - filteredItems.length),
        page: page.page,
        pageSize: page.pageSize,
        totalPages: page.totalPages,
      );

      // Merge on load-more
      if (!reset && state is StudentActivitiesLoadingMore) {
        final prev = (state as StudentActivitiesLoadingMore).current;
        final merged = StudentActivitiesPage(
          items: [...prev.items, ...filteredItems],
          totalCount: filteredPage.totalCount,
          page: filteredPage.page,
          pageSize: filteredPage.pageSize,
          totalPages: filteredPage.totalPages,
        );
        emit(StudentActivitiesLoaded(
          data: merged,
          activeType: _activeType,
          activeStatus: _activeStatus,
        ));
      } else {
        emit(StudentActivitiesLoaded(
          data: filteredPage,
          activeType: _activeType,
          activeStatus: _activeStatus,
        ));
      }
    } on DioException catch (e) {
      emit(StudentActivitiesError(
          e.response?.data?['message'] ?? e.message ?? 'Network error'));
    } catch (e) {
      emit(StudentActivitiesError(e.toString()));
    }
  }

  void filterByType(String? type) => load(
        courseId: _courseId,
        activityType: type,
        status: _activeStatus,
        search: _search,
      );

  void filterByStatus(String? status) => load(
        courseId: _courseId,
        activityType: _activeType,
        status: status,
        search: _search,
      );

  void search(String query) => load(
        courseId: _courseId,
        activityType: _activeType,
        status: _activeStatus,
        search: query,
      );

  Future<void> loadMore() async {
    final current = state;
    if (current is! StudentActivitiesLoaded) return;
    if (current.data.page >= current.data.totalPages) return;
    _currentPage++;
    await load(reset: false);
  }
}

// ── Grades Cubit ──────────────────────────────────────────────
class CourseGradesCubit extends Cubit<CourseGradesState> {

  CourseGradesCubit({Dio? dio})
      : _dio = dio ?? Dio(),
        super(CourseGradesInitial());
  final Dio _dio;

  Future<void> loadGrades(int courseId) async {
    emit(CourseGradesLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      final resp = await _dio.get(
        '${ApiResources.apiUrl}courses/$courseId/my-grades',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final grades = CourseGrades.fromJson(resp.data);
      emit(CourseGradesLoaded(grades: grades));
    } on DioException catch (e) {
      emit(CourseGradesError(
          e.response?.data?['message'] ?? e.message ?? 'Failed to load grades'));
    } catch (e) {
      emit(CourseGradesError(e.toString()));
    }
  }

  void switchTab(int tab) {
    final current = state;
    if (current is CourseGradesLoaded) {
      emit(current.copyWith(activeTab: tab));
    }
  }
}
