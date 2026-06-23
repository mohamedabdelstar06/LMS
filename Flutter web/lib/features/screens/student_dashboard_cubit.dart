import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';

import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';

import 'package:lms/features/screens/student_dashboard_states.dart';



// ── Models ────────────────────────────────────────────────────────────────────

class CompletionStatus {
  const CompletionStatus({
    required this.completed,
    required this.inProgress,
    required this.notStarted,
  });
  factory CompletionStatus.fromJson(Map<String, dynamic> j) => CompletionStatus(
    completed: j['completed'] ?? 0,
    inProgress: j['inProgress'] ?? 0,
    notStarted: j['notStarted'] ?? 0,
  );
  final int completed;
  final int inProgress;
  final int notStarted;
}

class ProgressPoint {
  const ProgressPoint({
    required this.week,
    required this.yourProgress,
    required this.classAverage,
  });
  factory ProgressPoint.fromJson(Map<String, dynamic> j) => ProgressPoint(
    week: j['week'] ?? '',
    yourProgress: (j['yourProgress'] ?? 0).toDouble(),
    classAverage: (j['classAverage'] ?? 0).toDouble(),
  );
  final String week;
  final double yourProgress;
  final double classAverage;
}

class GradePerCourse {
  const GradePerCourse({required this.courseName, required this.grade});
  factory GradePerCourse.fromJson(Map<String, dynamic> j) => GradePerCourse(
    courseName: j['courseName'] ?? '',
    grade: (j['grade'] ?? 0).toDouble(),
  );
  final String courseName;
  final double grade;
}

class UpcomingDeadline {
  const UpcomingDeadline({
    required this.title,
    required this.dueDate,
    required this.courseTitle,
  });
  factory UpcomingDeadline.fromJson(Map<String, dynamic> j) => UpcomingDeadline(
    title: j['title'] ?? '',
    dueDate: j['dueDate'] ?? '',
    courseTitle: j['courseTitle'] ?? '',
  );
  final String title;
  final String dueDate;
  final String courseTitle;
}

class Achievement {
  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
  });
  factory Achievement.fromJson(Map<String, dynamic> j) => Achievement(
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    icon: j['icon'] ?? '',
  );
  final String title;
  final String description;
  final String icon;
}

class EnrolledCourse {
  const EnrolledCourse({
    required this.id,
    required this.title,
    required this.progressPercent,
    required this.imageUrl,
  });
  factory EnrolledCourse.fromJson(Map<String, dynamic> j) => EnrolledCourse(
    id: j['id'] ?? 0,
    title: j['title'] ?? '',
    progressPercent: (j['progressPercent'] ?? 0).toDouble(),
    imageUrl: j['imageUrl'] ?? '',
  );
  final int id;
  final String title;
  final double progressPercent;
  final String imageUrl;
}

class StudentDashboardModel {

  const StudentDashboardModel({
    required this.overallGpa,
    required this.coursesCompleted,
    required this.creditHours,
    required this.courseProgressPercent,
    required this.assignmentsCompleted,
    required this.assignmentsTotal,
    required this.averageGrade,
    required this.attendanceRate,
    required this.completionStatus,
    required this.progressOverTime,
    required this.gradesPerCourse,
    required this.upcomingDeadlines,
    required this.achievements,
    required this.enrolledCourses,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> j) =>
      StudentDashboardModel(
        overallGpa: (j['overallGpa'] ?? 0).toDouble(),
        coursesCompleted: j['coursesCompleted'] ?? 0,
        creditHours: j['creditHours'] ?? 0,
        courseProgressPercent: (j['courseProgressPercent'] ?? 0).toDouble(),
        assignmentsCompleted: j['assignmentsCompleted'] ?? 0,
        assignmentsTotal: j['assignmentsTotal'] ?? 0,
        averageGrade: (j['averageGrade'] ?? 0).toDouble(),
        attendanceRate: (j['attendanceRate'] ?? 0).toDouble(),
        completionStatus: CompletionStatus.fromJson(
          j['completionStatus'] ?? {},
        ),
        progressOverTime: (j['progressOverTime'] as List? ?? [])
            .map((e) => ProgressPoint.fromJson(e))
            .toList(),
        gradesPerCourse: (j['gradesPerCourse'] as List? ?? [])
            .map((e) => GradePerCourse.fromJson(e))
            .toList(),
        upcomingDeadlines: (j['upcomingDeadlines'] as List? ?? [])
            .map((e) => UpcomingDeadline.fromJson(e))
            .toList(),
        achievements: (j['achievements'] as List? ?? [])
            .map((e) => Achievement.fromJson(e))
            .toList(),
        enrolledCourses: (j['enrolledCourses'] as List? ?? [])
            .map((e) => EnrolledCourse.fromJson(e))
            .toList(),
      );
  final double overallGpa;
  final int coursesCompleted;
  final int creditHours;
  final double courseProgressPercent;
  final int assignmentsCompleted;
  final int assignmentsTotal;
  final double averageGrade;
  final double attendanceRate;
  final CompletionStatus completionStatus;
  final List<ProgressPoint> progressOverTime;
  final List<GradePerCourse> gradesPerCourse;
  final List<UpcomingDeadline> upcomingDeadlines;
  final List<Achievement> achievements;
  final List<EnrolledCourse> enrolledCourses;
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class StudentDashboardCubit extends Cubit<StudentDashboardState> {

  StudentDashboardCubit({Dio? dio})
    : dio = dio ?? Dio(),
      super(StudentDashboardInitial());
  final Dio dio;

  Future<void> loadDashboard() async {
    emit(StudentDashboardLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const StudentDashboardError('غير مصرح. Token مفقود.'));
        return;
      }
      final response = await dio.get(
        '${ApiResources.apiUrl}Dashboard/student',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      emit(
        StudentDashboardLoaded(
          model: StudentDashboardModel.fromJson(response.data),
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(
          const StudentDashboardError('غير مصرح. يرجى تسجيل الدخول مجدداً.'),
        );
      } else {
        emit(StudentDashboardError(e.message ?? 'حدث خطأ في الاتصال'));
      }
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }
}
