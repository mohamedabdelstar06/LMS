import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/features/screens/Announcement/model.dart';
import 'package:lms/features/screens/Announcement/states.dart';
import 'package:lms/features/screens/admin/courses/get_all_courses/model/model.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/all_model/model.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/model/view.dart';
import 'package:lms/features/screens/admin/year/get_year/get_All_years/all_model/model.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  AnnouncementCubit() : super(AnnouncementInitial());

  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://skylearn.runasp.net/api/'),
  );

  // ── helpers ───────────────────────────────────────────────────────────────

  Future<Options> _authOptions() async {
    final token = await TokenStorageHelper.getTokenSecure();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['title'];
      return message?.toString() ?? fallback;
    }
    if (data is String) {
      return data;
    }
    return e.message ?? fallback;
  }

  // ── Load all dropdown data at once (call on AddAnnouncementScreen init) ───

  Future<void> loadDropdownData() async {
    emit(DropdownDataLoading());
    try {
      final opts = await _authOptions();

      final results = await Future.wait([
        _dio.get('Departments', options: opts),
        _dio.get('Years', options: opts),
        _dio.get('Squadrons', options: opts),
        _dio.get(
          'Courses',
          queryParameters: {'page': 1, 'pageSize': 100},
          options: opts,
        ),
      ]);

      // Departments — array response
      final deptList = (results[0].data as List<dynamic>? ?? [])
          .map((e) => GetAllDepartmentModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Years — array response
      final yearList = (results[1].data as List<dynamic>? ?? [])
          .map((e) => GetAllYearModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Squadrons — array response
      final squadList = (results[2].data as List<dynamic>? ?? [])
          .map((e) => SquadronModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Courses — paginated response
      final courseItems = results[3].data['items'] as List<dynamic>? ?? [];
      final courseList = courseItems
          .map((e) => GetCourseModel.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(
        DropdownDataLoaded(
          departments: deptList,
          years: yearList,
          squadrons: squadList,
          courses: courseList,
        ),
      );
    } on DioException catch (e) {
      emit(
        DropdownDataError(
          _extractErrorMessage(e, 'Failed to load dropdown data'),
        ),
      );
    } catch (e) {
      emit(DropdownDataError('Unexpected error: $e'));
    }
  }

  // ── Add Announcement ──────────────────────────────────────────────────────

  Future<void> addAnnouncement({
    required String title,
    required String content,
    String? description,
    String? imageUrl,
    Uint8List? imageBytes,
    String? imageFilename,
    DateTime? startDate,
    DateTime? endDate,
    bool isPinned = false,
    required int audienceType,
    int? departmentId,
    int? yearId,
    int? squadronId,
    int? courseId,
  }) async {
    emit(AnnouncementLoading());
    try {
      final formData = FormData.fromMap({
        'Title': title,
        'Content': content,
        if (description != null && description.isNotEmpty)
          'Description': description,
        if (imageUrl != null && imageUrl.isNotEmpty) 'ImageUrl': imageUrl,
        if (imageBytes != null)
          'ImageFile': await MultipartFile.fromBytes(
            imageBytes,
            filename: imageFilename ?? 'announcement_image',
          ),
        if (startDate != null) 'StartDate': startDate.toIso8601String(),
        if (endDate != null) 'EndDate': endDate.toIso8601String(),
        'IsPinned': isPinned,
        'AudienceType': audienceType,
        if (departmentId != null) 'DepartmentId': departmentId,
        if (yearId != null) 'YearId': yearId,
        if (squadronId != null) 'SquadronId': squadronId,
        if (courseId != null) 'CourseId': courseId,
      });

      await _dio.post(
        'Announcements',
        data: formData,
        options: await _authOptions(),
      );

      emit(AnnouncementSuccess());
    } on DioException catch (e) {
      emit(
        AnnouncementError(
          _extractErrorMessage(e, 'Failed to create announcement'),
        ),
      );
    } catch (e) {
      emit(AnnouncementError('Unexpected error: $e'));
    }
  }

  // ── Get All Announcements (Admin) ─────────────────────────────────────────

  Future<void> getAllAnnouncements({int page = 1, int pageSize = 10}) async {
    emit(GetAllAnnouncementsLoading());
    try {
      final res = await _dio.get(
        'Announcements/all',
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: await _authOptions(),
      );

      final parsed = AnnouncementsResponse.fromJson(
        res.data as Map<String, dynamic>,
      );

      emit(
        GetAllAnnouncementsSuccess(
          announcements: parsed.items,
          hasNextPage: parsed.hasNextPage,
          hasPreviousPage: parsed.hasPreviousPage,
          totalCount: parsed.totalCount,
          totalPages: parsed.totalPages,
          currentPage: parsed.pageIndex,
        ),
      );
    } on DioException catch (e) {
      emit(
        GetAllAnnouncementsError(
          _extractErrorMessage(e, 'Failed to load announcements'),
        ),
      );
    } catch (e) {
      emit(GetAllAnnouncementsError('Unexpected error: $e'));
    }
  }

  // ── Delete Announcement ───────────────────────────────────────────────────

  Future<void> deleteAnnouncement(int id) async {
    emit(DeleteAnnouncementLoading());
    try {
      await _dio.delete('Announcements/$id', options: await _authOptions());
      emit(DeleteAnnouncementSuccess());
    } on DioException catch (e) {
      emit(
        DeleteAnnouncementError(
          _extractErrorMessage(e, 'Failed to delete announcement'),
        ),
      );
    } catch (e) {
      emit(DeleteAnnouncementError('Unexpected error: $e'));
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() => emit(AnnouncementInitial());
}
