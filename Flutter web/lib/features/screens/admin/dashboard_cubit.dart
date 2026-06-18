import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';


part 'dashboard_state.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class DashboardStatsModel {
  final int totalUsers;
  final int totalStudents;
  final int totalInstructors;
  final int totalCourses;
  final int totalDepartments;
  final int totalSquadrons;

  const DashboardStatsModel({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalInstructors,
    required this.totalCourses,
    required this.totalDepartments,
    required this.totalSquadrons,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      DashboardStatsModel(
        totalUsers: json['totalUsers'] ?? 0,
        totalStudents: json['totalStudents'] ?? 0,
        totalInstructors: json['totalInstructors'] ?? 0,
        totalCourses: json['totalCourses'] ?? 0,
        totalDepartments: json['totalDepartments'] ?? 0,
        totalSquadrons: json['totalSquadrons'] ?? 0,
      );
}

class DepartmentOverview {
  final int id;
  final String name;
  final int courseCount;

  const DepartmentOverview({
    required this.id,
    required this.name,
    required this.courseCount,
  });

  factory DepartmentOverview.fromJson(Map<String, dynamic> json) =>
      DepartmentOverview(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        courseCount: json['courseCount'] ?? 0,
      );
}

class RecentCourse {
  final int id;
  final String title;
  final String imageUrl;
  final String departmentName;
  final String instructorName;
  final int enrolledStudentsCount;
  final int creditHours;

  const RecentCourse({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.departmentName,
    required this.instructorName,
    required this.enrolledStudentsCount,
    required this.creditHours,
  });

  factory RecentCourse.fromJson(Map<String, dynamic> json) => RecentCourse(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        departmentName: json['departmentName'] ?? '',
        instructorName: json['instructorName'] ?? '',
        enrolledStudentsCount: json['enrolledStudentsCount'] ?? 0,
        creditHours: json['creditHours'] ?? 0,
      );
}

class TopInstructor {
  final int instructorId;
  final String fullName;
  final String profileImageUrl;
  final int courseCount;

  const TopInstructor({
    required this.instructorId,
    required this.fullName,
    required this.profileImageUrl,
    required this.courseCount,
  });

  factory TopInstructor.fromJson(Map<String, dynamic> json) => TopInstructor(
        instructorId: json['instructorId'] ?? 0,
        fullName: json['fullName'] ?? '',
        profileImageUrl: json['profileImageUrl'] ?? '',
        courseCount: json['courseCount'] ?? 0,
      );
}

class WeeklyHour {
  final String day;
  final int study;
  final int exams;

  const WeeklyHour({required this.day, required this.study, required this.exams});

  factory WeeklyHour.fromJson(Map<String, dynamic> json) => WeeklyHour(
        day: json['day'] ?? '',
        study: json['study'] ?? 0,
        exams: json['exams'] ?? 0,
      );
}

class DashboardOverviewModel {
  final List<DepartmentOverview> departments;
  final List<RecentCourse> recentCourses;
  final List<TopInstructor> topInstructors;
  final int monthlyStudyCount;
  final int monthlyExamCount;
  final List<WeeklyHour> weeklyHours;

  const DashboardOverviewModel({
    required this.departments,
    required this.recentCourses,
    required this.topInstructors,
    required this.monthlyStudyCount,
    required this.monthlyExamCount,
    required this.weeklyHours,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) =>
      DashboardOverviewModel(
        departments: (json['departments'] as List<dynamic>? ?? [])
            .map((e) => DepartmentOverview.fromJson(e))
            .toList(),
        recentCourses: (json['recentCourses'] as List<dynamic>? ?? [])
            .map((e) => RecentCourse.fromJson(e))
            .toList(),
        topInstructors: (json['topInstructors'] as List<dynamic>? ?? [])
            .map((e) => TopInstructor.fromJson(e))
            .toList(),
        monthlyStudyCount: json['monthlyStudyCount'] ?? 0,
        monthlyExamCount: json['monthlyExamCount'] ?? 0,
        weeklyHours: (json['weeklyHours'] as List<dynamic>? ?? [])
            .map((e) => WeeklyHour.fromJson(e))
            .toList(),
      );
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class DashboardCubit extends Cubit<DashboardState> {
  final Dio dio;

  DashboardCubit({Dio? dio})
      : dio = dio ?? Dio(),
        super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const DashboardError('غير مصرح. Token مفقود.'));
        return;
      }
      

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final responses = await Future.wait([
        dio.get(
          '${ApiResources.apiUrl}Dashboard/admin',
          options: Options(headers: headers),
        ),
        dio.get(
          '${ApiResources.apiUrl}Dashboard/admin/overview',
          options: Options(headers: headers),
        ),
      ]);

      final stats = DashboardStatsModel.fromJson(responses[0].data);
      final overview = DashboardOverviewModel.fromJson(responses[1].data);

      emit(DashboardLoaded(stats: stats, overview: overview));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(const DashboardError('غير مصرح. يرجى تسجيل الدخول مجدداً.'));
      } else {
        emit(DashboardError(e.message ?? 'حدث خطأ في الاتصال'));
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
