import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';


part 'dashboard_state.dart';


class DashboardStatsModel {

  const DashboardStatsModel({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalInstructors,
    required this.totalAdmins,
    required this.totalCourses,
    required this.totalDepartments,
    required this.totalSquadrons,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final totalUsers = json['totalUsers'] ?? 0;
    final totalStudents = json['totalStudents'] ?? 0;
    final totalInstructors = json['totalInstructors'] ?? 0;
    final explicitAdmins = json['totalAdmins'] as int?;
    return DashboardStatsModel(
      totalUsers: totalUsers,
      totalStudents: totalStudents,
      totalInstructors: totalInstructors,
      totalAdmins: explicitAdmins ?? (totalUsers - totalStudents - totalInstructors).clamp(0, totalUsers),
      totalCourses: json['totalCourses'] ?? 0,
      totalDepartments: json['totalDepartments'] ?? 0,
      totalSquadrons: json['totalSquadrons'] ?? 0,
    );
  }
  final int totalUsers;
  final int totalStudents;
  final int totalInstructors;
  final int totalAdmins;
  final int totalCourses;
  final int totalDepartments;
  final int totalSquadrons;
}

class DepartmentOverview {

  const DepartmentOverview({
    required this.id,
    required this.name,
    required this.courseCount,
    this.imageUrl,
  });

  factory DepartmentOverview.fromJson(Map<String, dynamic> json) =>
      DepartmentOverview(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        courseCount: json['courseCount'] ?? 0,
        imageUrl: json['imageUrl'],
      );
  final int id;
  final String name;
  final int courseCount;
  final String? imageUrl;
}

class RecentCourse {

  const RecentCourse({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.departmentName,
    required this.instructorName,
    required this.enrolledStudentsCount,
    required this.creditHours,
    this.createdAt,
  });

  factory RecentCourse.fromJson(Map<String, dynamic> json) => RecentCourse(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        departmentName: json['departmentName'] ?? '',
        instructorName: json['instructorName'] ?? '',
        enrolledStudentsCount: json['enrolledStudentsCount'] ?? 0,
        creditHours: json['creditHours'] ?? 0,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      );
  final int id;
  final String title;
  final String imageUrl;
  final String departmentName;
  final String instructorName;
  final int enrolledStudentsCount;
  final int creditHours;
  final DateTime? createdAt;
}

class TopInstructor {

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
  final int instructorId;
  final String fullName;
  final String profileImageUrl;
  final int courseCount;
}

class WeeklyHour {

  const WeeklyHour({required this.day, required this.study, required this.exams});

  factory WeeklyHour.fromJson(Map<String, dynamic> json) => WeeklyHour(
        day: json['day'] ?? '',
        study: json['study'] ?? 0,
        exams: json['exams'] ?? 0,
      );
  final String day;
  final int study;
  final int exams;
}

class DashboardOverviewModel {

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
  final List<DepartmentOverview> departments;
  final List<RecentCourse> recentCourses;
  final List<TopInstructor> topInstructors;
  final int monthlyStudyCount;
  final int monthlyExamCount;
  final List<WeeklyHour> weeklyHours;
}

class AdminAnalyticsModel {
  const AdminAnalyticsModel({
    required this.platformHealth,
    required this.kpis,
    required this.departmentComparison,
    required this.squadronPerformance,
    required this.atRiskStudents,
    required this.atRiskByDepartment,
    required this.systemAlerts,
    required this.topPopularCourses,
    required this.topHardestCourses,
    required this.enrollmentTrend,
    required this.weeklyEngagement,
    required this.learningFunnel,
  });

  factory AdminAnalyticsModel.fromJson(Map<String, dynamic> json) => AdminAnalyticsModel(
        platformHealth: PlatformHealthModel.fromJson(
            json['platformHealth'] as Map<String, dynamic>? ?? {}),
        kpis: (json['kpis'] as List<dynamic>? ?? [])
            .map((e) => KpiModel.fromJson(e))
            .toList(),
        departmentComparison: (json['departmentComparison'] as List<dynamic>? ?? [])
            .map((e) => DepartmentComparisonModel.fromJson(e))
            .toList(),
        squadronPerformance: (json['squadronPerformance'] as List<dynamic>? ?? [])
            .map((e) => SquadronPerformanceModel.fromJson(e))
            .toList(),
        atRiskStudents: (json['atRiskStudents'] as List<dynamic>? ?? [])
            .map((e) => AtRiskStudentModel.fromJson(e))
            .toList(),
        atRiskByDepartment: (json['atRiskByDepartment'] as List<dynamic>? ?? [])
            .map((e) => RiskByDepartmentModel.fromJson(e))
            .toList(),
        systemAlerts: (json['systemAlerts'] as List<dynamic>? ?? [])
            .map((e) => AlertModel.fromJson(e))
            .toList(),
        topPopularCourses: (json['topPopularCourses'] as List<dynamic>? ?? [])
            .map((e) => CourseRankingModel.fromJson(e))
            .toList(),
        topHardestCourses: (json['topHardestCourses'] as List<dynamic>? ?? [])
            .map((e) => CourseRankingModel.fromJson(e))
            .toList(),
        enrollmentTrend: (json['enrollmentTrend'] as List<dynamic>? ?? [])
            .map((e) => EnrollmentTrendModel.fromJson(e))
            .toList(),
        weeklyEngagement: (json['weeklyEngagement'] as List<dynamic>? ?? [])
            .map((e) => WeeklyEngagementModel.fromJson(e))
            .toList(),
        learningFunnel: (json['learningFunnel'] as List<dynamic>? ?? [])
            .map((e) => LearningFunnelStageModel.fromJson(e))
            .toList(),
      );

  final PlatformHealthModel platformHealth;
  final List<KpiModel> kpis;
  final List<DepartmentComparisonModel> departmentComparison;
  final List<SquadronPerformanceModel> squadronPerformance;
  final List<AtRiskStudentModel> atRiskStudents;
  final List<RiskByDepartmentModel> atRiskByDepartment;
  final List<AlertModel> systemAlerts;
  final List<CourseRankingModel> topPopularCourses;
  final List<CourseRankingModel> topHardestCourses;
  final List<EnrollmentTrendModel> enrollmentTrend;
  final List<WeeklyEngagementModel> weeklyEngagement;
  final List<LearningFunnelStageModel> learningFunnel;
}

class PlatformHealthModel {
  const PlatformHealthModel({
    required this.platformHealthScore,
    required this.enrolledStudentsPct,
    required this.activeCoursesPct,
    required this.overallCompletionRate,
    required this.overallQuizPassRate,
    required this.activeUsersPct,
  });

  factory PlatformHealthModel.fromJson(Map<String, dynamic> json) => PlatformHealthModel(
        platformHealthScore: (json['platformHealthScore'] ?? 0).toDouble(),
        enrolledStudentsPct: (json['enrolledStudentsPct'] ?? 0).toDouble(),
        activeCoursesPct: (json['activeCoursesPct'] ?? 0).toDouble(),
        overallCompletionRate: (json['overallCompletionRate'] ?? 0).toDouble(),
        overallQuizPassRate: (json['overallQuizPassRate'] ?? 0).toDouble(),
        activeUsersPct: (json['activeUsersPct'] ?? 0).toDouble(),
      );

  final double platformHealthScore;
  final double enrolledStudentsPct;
  final double activeCoursesPct;
  final double overallCompletionRate;
  final double overallQuizPassRate;
  final double activeUsersPct;
}

class KpiModel {
  const KpiModel({required this.key, required this.label, required this.value});

  factory KpiModel.fromJson(Map<String, dynamic> json) => KpiModel(
        key: json['key'] ?? '',
        label: json['label'] ?? '',
        value: (json['value'] ?? 0).toDouble(),
      );

  final String key;
  final String label;
  final double value;
}

class DepartmentComparisonModel {
  const DepartmentComparisonModel({
    required this.departmentName,
    required this.students,
    required this.avgCreditLoad,
    required this.avgQuizScore,
    required this.avgGrade,
    required this.quizPassRate,
    required this.completionRate,
  });

  factory DepartmentComparisonModel.fromJson(Map<String, dynamic> json) => DepartmentComparisonModel(
        departmentName: json['departmentName'] ?? '',
        students: json['students'] ?? 0,
        avgCreditLoad: (json['avgCreditLoad'] ?? 0).toDouble(),
        avgQuizScore: (json['avgQuizScore'] ?? 0).toDouble(),
        avgGrade: (json['avgGrade'] ?? 0).toDouble(),
        quizPassRate: (json['quizPassRate'] ?? 0).toDouble(),
        completionRate: (json['completionRate'] ?? 0).toDouble(),
      );

  final String departmentName;
  final int students;
  final double avgCreditLoad;
  final double avgQuizScore;
  final double avgGrade;
  final double quizPassRate;
  final double completionRate;
}

class SquadronPerformanceModel {
  const SquadronPerformanceModel({
    required this.squadronId,
    required this.squadronName,
    required this.studentCount,
    required this.avgQuizScore,
    required this.quizPassRate,
    required this.completionRate,
    required this.overallScore,
    required this.rank,
  });

  factory SquadronPerformanceModel.fromJson(Map<String, dynamic> json) => SquadronPerformanceModel(
        squadronId: json['squadronId'] ?? 0,
        squadronName: json['squadronName'] ?? '',
        studentCount: json['studentCount'] ?? 0,
        avgQuizScore: (json['avgQuizScore'] ?? 0).toDouble(),
        quizPassRate: (json['quizPassRate'] ?? 0).toDouble(),
        completionRate: (json['completionRate'] ?? 0).toDouble(),
        overallScore: (json['overallScore'] ?? 0).toDouble(),
        rank: json['rank'] ?? 0,
      );

  final int squadronId;
  final String squadronName;
  final int studentCount;
  final double avgQuizScore;
  final double quizPassRate;
  final double completionRate;
  final double overallScore;
  final int rank;
}

class AtRiskStudentModel {
  const AtRiskStudentModel({
    required this.studentId,
    required this.departmentName,
    required this.clusterLabel,
    required this.combinedRiskScore,
    required this.dropoutProbability,
    required this.atRiskProbability,
    required this.completionRate,
    required this.avgScore,
    required this.failureRatio,
    required this.lateRate,
    required this.isAnomaly,
    required this.anomalyType,
  });

  factory AtRiskStudentModel.fromJson(Map<String, dynamic> json) => AtRiskStudentModel(
        studentId: json['studentId'] ?? 0,
        departmentName: json['departmentName'] ?? '',
        clusterLabel: json['clusterLabel'] ?? '',
        combinedRiskScore: (json['combinedRiskScore'] ?? 0).toDouble(),
        dropoutProbability: (json['dropoutProbability'] ?? 0).toDouble(),
        atRiskProbability: (json['atRiskProbability'] ?? 0).toDouble(),
        completionRate: (json['completionRate'] ?? 0).toDouble(),
        avgScore: (json['avgScore'] ?? 0).toDouble(),
        failureRatio: (json['failureRatio'] ?? 0).toDouble(),
        lateRate: (json['lateRate'] ?? 0).toDouble(),
        isAnomaly: json['isAnomaly'] == true || json['isAnomaly'] == 1,
        anomalyType: json['anomalyType'] ?? '',
      );

  final int studentId;
  final String departmentName;
  final String clusterLabel;
  final double combinedRiskScore;
  final double dropoutProbability;
  final double atRiskProbability;
  final double completionRate;
  final double avgScore;
  final double failureRatio;
  final double lateRate;
  final bool isAnomaly;
  final String anomalyType;
}

class RiskByDepartmentModel {
  const RiskByDepartmentModel({
    required this.departmentName,
    required this.atRiskCount,
    required this.total,
    required this.atRiskPct,
  });

  factory RiskByDepartmentModel.fromJson(Map<String, dynamic> json) => RiskByDepartmentModel(
        departmentName: json['departmentName'] ?? '',
        atRiskCount: json['atRiskCount'] ?? 0,
        total: json['total'] ?? 0,
        atRiskPct: (json['atRiskPct'] ?? 0).toDouble(),
      );

  final String departmentName;
  final int atRiskCount;
  final int total;
  final double atRiskPct;
}

class AlertModel {
  const AlertModel({required this.alert, required this.count, required this.severity});

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        alert: json['alert'] ?? '',
        count: json['count'] ?? 0,
        severity: json['severity'] ?? 'Medium',
      );

  final String alert;
  final int count;
  final String severity;
}

class CourseRankingModel {
  const CourseRankingModel({
    required this.courseId,
    required this.title,
    required this.departmentName,
    required this.enrolledStudentsCount,
    required this.completionRate,
    required this.avgQuizScore,
    required this.quizPassRate,
    required this.totalAttempts,
  });

  factory CourseRankingModel.fromJson(Map<String, dynamic> json) => CourseRankingModel(
        courseId: json['courseId'] ?? 0,
        title: json['title'] ?? '',
        departmentName: json['departmentName'] ?? '',
        enrolledStudentsCount: json['enrolledStudentsCount'] ?? 0,
        completionRate: (json['completionRate'] ?? 0).toDouble(),
        avgQuizScore: (json['avgQuizScore'] ?? 0).toDouble(),
        quizPassRate: (json['quizPassRate'] ?? 0).toDouble(),
        totalAttempts: json['totalAttempts'] ?? 0,
      );

  final int courseId;
  final String title;
  final String departmentName;
  final int enrolledStudentsCount;
  final double completionRate;
  final double avgQuizScore;
  final double quizPassRate;
  final int totalAttempts;
}

class EnrollmentTrendModel {
  const EnrollmentTrendModel({
    required this.year,
    required this.month,
    required this.enrollments,
  });

  factory EnrollmentTrendModel.fromJson(Map<String, dynamic> json) => EnrollmentTrendModel(
        year: json['year'] ?? 0,
        month: json['month'] ?? 0,
        enrollments: json['enrollments'] ?? 0,
      );

  final int year;
  final int month;
  final int enrollments;
}

class WeeklyEngagementModel {
  const WeeklyEngagementModel({
    required this.week,
    required this.totalActions,
    required this.uniqueUsers,
  });

  factory WeeklyEngagementModel.fromJson(Map<String, dynamic> json) => WeeklyEngagementModel(
        week: json['week'] ?? '',
        totalActions: json['totalActions'] ?? 0,
        uniqueUsers: json['uniqueUsers'] ?? 0,
      );

  final String week;
  final int totalActions;
  final int uniqueUsers;
}

class LearningFunnelStageModel {
  const LearningFunnelStageModel({
    required this.stage,
    required this.count,
    required this.dropFromPrev,
    required this.retentionPct,
  });

  factory LearningFunnelStageModel.fromJson(Map<String, dynamic> json) => LearningFunnelStageModel(
        stage: json['stage'] ?? '',
        count: json['count'] ?? 0,
        dropFromPrev: json['dropFromPrev'] ?? 0,
        retentionPct: (json['retentionPct'] ?? 0).toDouble(),
      );

  final String stage;
  final int count;
  final int dropFromPrev;
  final double retentionPct;
}



class DashboardCubit extends Cubit<DashboardState> {

  DashboardCubit({Dio? dio})
      : dio = dio ?? Dio(),
        super(DashboardInitial());
  final Dio dio;

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

      final coreResponses = await Future.wait([
        dio.get(
          '${ApiResources.apiUrl}${ApiResources.adminDashboardEndPoint}',
          options: Options(headers: headers),
        ),
        dio.get(
          '${ApiResources.apiUrl}${ApiResources.adminDashboardOverviewEndPoint}',
          options: Options(headers: headers),
        ),
      ]);

      Response? analyticsResponse;
      try {
        analyticsResponse = await dio.get(
          '${ApiResources.apiUrl}${ApiResources.adminDashboardAnalyticsEndPoint}',
          options: Options(headers: headers),
        );
      } catch (_) {
        analyticsResponse = null;
      }

      final stats = DashboardStatsModel.fromJson(coreResponses[0].data);
      final overview = DashboardOverviewModel.fromJson(coreResponses[1].data);
      final analytics = AdminAnalyticsModel.fromJson(
        analyticsResponse?.data is Map<String, dynamic>
            ? analyticsResponse!.data as Map<String, dynamic>
            : {},
      );

      emit(DashboardLoaded(stats: stats, overview: overview, analytics: analytics));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(const DashboardError('غير مصرح. يرجى تسجيل الدخول مجدداً.'));
      } else {
        emit(DashboardError(e.response?.data['message'] ?? e.message ?? 'حدث خطأ في الاتصال'));
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
