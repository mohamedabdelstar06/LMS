import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';

import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';

import 'package:lms/features/screens/student_dashboard_states.dart';





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
    this.assignmentsSubmitted = 0,
    this.assignmentsPending = 0,
    this.quizzesTaken = 0,
    this.quizzesNotTaken = 0,
  });
  factory EnrolledCourse.fromJson(Map<String, dynamic> j) => EnrolledCourse(
    id: j['id'] ?? 0,
    title: j['title'] ?? '',
    progressPercent: (j['progressPercent'] ?? 0).toDouble(),
    imageUrl: j['imageUrl'] ?? '',
    assignmentsSubmitted: j['assignmentsSubmitted'] ?? 0,
    assignmentsPending: j['assignmentsPending'] ?? 0,
    quizzesTaken: j['quizzesTaken'] ?? 0,
    quizzesNotTaken: j['quizzesNotTaken'] ?? 0,
  );
  final int id;
  final String title;
  final double progressPercent;
  final String imageUrl;
  final int assignmentsSubmitted;
  final int assignmentsPending;
  final int quizzesTaken;
  final int quizzesNotTaken;
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



class StudentAnalyticsModel {
  const StudentAnalyticsModel({
    required this.studentId,
    required this.departmentName,
    required this.squadronName,
    required this.segment,
    required this.overallRank,
    required this.deptRank,
    required this.squadronRank,
    required this.compositeScore,
    required this.avgQuizScore,
    required this.avgGrade,
    required this.quizPassRate,
    required this.completionRate,
    required this.riskScore,
    required this.dropoutProbability,
    required this.atRiskProbability,
    required this.isAnomaly,
    required this.anomalyType,
    required this.classAverages,
    required this.departmentAverages,
    required this.improvementTrend,
    required this.strengthsWeaknesses,
    required this.courseProgress,
    required this.learningEfficiency,
    required this.workload,
  });

  const StudentAnalyticsModel.empty()
      : studentId = 0,
        departmentName = '',
        squadronName = '',
        segment = '',
        overallRank = 0,
        deptRank = 0,
        squadronRank = 0,
        compositeScore = 0,
        avgQuizScore = 0,
        avgGrade = 0,
        quizPassRate = 0,
        completionRate = 0,
        riskScore = 0,
        dropoutProbability = 0,
        atRiskProbability = 0,
        isAnomaly = false,
        anomalyType = '',
        classAverages = const [],
        departmentAverages = const [],
        improvementTrend = const [],
        strengthsWeaknesses = const [],
        courseProgress = const [],
        learningEfficiency = const [],
        workload = const [];

  factory StudentAnalyticsModel.fromJson(Map<String, dynamic> j) =>
      StudentAnalyticsModel(
        studentId: j['studentId'] ?? 0,
        departmentName: j['departmentName'] ?? '',
        squadronName: j['squadronName'] ?? '',
        segment: j['segment'] ?? '',
        overallRank: j['overallRank'] ?? 0,
        deptRank: j['deptRank'] ?? 0,
        squadronRank: j['squadronRank'] ?? 0,
        compositeScore: (j['compositeScore'] ?? 0).toDouble(),
        avgQuizScore: (j['avgQuizScore'] ?? 0).toDouble(),
        avgGrade: (j['avgGrade'] ?? 0).toDouble(),
        quizPassRate: (j['quizPassRate'] ?? 0).toDouble(),
        completionRate: (j['completionRate'] ?? 0).toDouble(),
        riskScore: (j['riskScore'] ?? 0).toDouble(),
        dropoutProbability: (j['dropoutProbability'] ?? 0).toDouble(),
        atRiskProbability: (j['atRiskProbability'] ?? 0).toDouble(),
        isAnomaly: j['isAnomaly'] == true || j['isAnomaly'] == 1,
        anomalyType: j['anomalyType'] ?? '',
        classAverages: (j['classAverages'] as List? ?? [])
            .map((e) => ClassAverageModel.fromJson(e))
            .toList(),
        departmentAverages: (j['departmentAverages'] as List? ?? [])
            .map((e) => ClassAverageModel.fromJson(e))
            .toList(),
        improvementTrend: (j['improvementTrend'] as List? ?? [])
            .map((e) => ImprovementTrendModel.fromJson(e))
            .toList(),
        strengthsWeaknesses: (j['strengthsWeaknesses'] as List? ?? [])
            .map((e) => StrengthWeaknessModel.fromJson(e))
            .toList(),
        courseProgress: (j['courseProgress'] as List? ?? [])
            .map((e) => StudentCourseProgressModel.fromJson(e))
            .toList(),
        learningEfficiency: (j['learningEfficiency'] as List? ?? [])
            .map((e) => LearningEfficiencyModel.fromJson(e))
            .toList(),
        workload: (j['workload'] as List? ?? [])
            .map((e) => StudentWorkloadModel.fromJson(e))
            .toList(),
      );

  final int studentId;
  final String departmentName;
  final String squadronName;
  final String segment;
  final int overallRank;
  final int deptRank;
  final int squadronRank;
  final double compositeScore;
  final double avgQuizScore;
  final double avgGrade;
  final double quizPassRate;
  final double completionRate;
  final double riskScore;
  final double dropoutProbability;
  final double atRiskProbability;
  final bool isAnomaly;
  final String anomalyType;
  final List<ClassAverageModel> classAverages;
  final List<ClassAverageModel> departmentAverages;
  final List<ImprovementTrendModel> improvementTrend;
  final List<StrengthWeaknessModel> strengthsWeaknesses;
  final List<StudentCourseProgressModel> courseProgress;
  final List<LearningEfficiencyModel> learningEfficiency;
  final List<StudentWorkloadModel> workload;
}

class ClassAverageModel {
  const ClassAverageModel({
    required this.metric,
    this.departmentName,
    required this.average,
  });
  factory ClassAverageModel.fromJson(Map<String, dynamic> j) => ClassAverageModel(
        metric: j['metric'] ?? '',
        departmentName: j['departmentName'],
        average: (j['average'] ?? 0).toDouble(),
      );
  final String metric;
  final String? departmentName;
  final double average;
}

class ImprovementTrendModel {
  const ImprovementTrendModel({
    required this.month,
    required this.avgScore,
    required this.attempts,
    required this.passRate,
  });
  factory ImprovementTrendModel.fromJson(Map<String, dynamic> j) =>
      ImprovementTrendModel(
        month: j['month'] ?? '',
        avgScore: (j['avgScore'] ?? 0).toDouble(),
        attempts: j['attempts'] ?? 0,
        passRate: (j['passRate'] ?? 0).toDouble(),
      );
  final String month;
  final double avgScore;
  final int attempts;
  final double passRate;
}

class StrengthWeaknessModel {
  const StrengthWeaknessModel({
    required this.questionType,
    required this.answered,
    required this.correctCount,
    required this.correctRate,
  });
  factory StrengthWeaknessModel.fromJson(Map<String, dynamic> j) =>
      StrengthWeaknessModel(
        questionType: j['questionType'] ?? '',
        answered: j['answered'] ?? 0,
        correctCount: j['correctCount'] ?? 0,
        correctRate: (j['correctRate'] ?? 0).toDouble(),
      );
  final String questionType;
  final int answered;
  final int correctCount;
  final double correctRate;
}

class StudentCourseProgressModel {
  const StudentCourseProgressModel({
    required this.courseId,
    required this.title,
    required this.activitiesTotal,
    required this.activitiesDone,
    required this.avgProgress,
    required this.avgTimeMinutes,
    required this.completionRate,
  });
  factory StudentCourseProgressModel.fromJson(Map<String, dynamic> j) =>
      StudentCourseProgressModel(
        courseId: j['courseId'] ?? 0,
        title: j['title'] ?? '',
        activitiesTotal: j['activitiesTotal'] ?? 0,
        activitiesDone: j['activitiesDone'] ?? 0,
        avgProgress: (j['avgProgress'] ?? 0).toDouble(),
        avgTimeMinutes: (j['avgTimeMinutes'] ?? 0).toDouble(),
        completionRate: (j['completionRate'] ?? 0).toDouble(),
      );
  final int courseId;
  final String title;
  final int activitiesTotal;
  final int activitiesDone;
  final double avgProgress;
  final double avgTimeMinutes;
  final double completionRate;
}

class LearningEfficiencyModel {
  const LearningEfficiencyModel({
    required this.avgEfficiency,
    required this.avgScore,
    required this.avgTimeMinutes,
    required this.totalAttempts,
    required this.efficiencyTier,
  });
  factory LearningEfficiencyModel.fromJson(Map<String, dynamic> j) =>
      LearningEfficiencyModel(
        avgEfficiency: (j['avgEfficiency'] ?? 0).toDouble(),
        avgScore: (j['avgScore'] ?? 0).toDouble(),
        avgTimeMinutes: (j['avgTimeMinutes'] ?? 0).toDouble(),
        totalAttempts: j['totalAttempts'] ?? 0,
        efficiencyTier: j['efficiencyTier'] ?? '',
      );
  final double avgEfficiency;
  final double avgScore;
  final double avgTimeMinutes;
  final int totalAttempts;
  final String efficiencyTier;
}

class StudentWorkloadModel {
  const StudentWorkloadModel({
    required this.avgSubmissionsPerWeek,
    required this.maxSubmissionsInWeek,
    required this.activeWeeks,
    required this.workloadTier,
  });
  factory StudentWorkloadModel.fromJson(Map<String, dynamic> j) =>
      StudentWorkloadModel(
        avgSubmissionsPerWeek: (j['avgSubmissionsPerWeek'] ?? 0).toDouble(),
        maxSubmissionsInWeek: j['maxSubmissionsInWeek'] ?? 0,
        activeWeeks: j['activeWeeks'] ?? 0,
        workloadTier: j['workloadTier'] ?? '',
      );
  final double avgSubmissionsPerWeek;
  final int maxSubmissionsInWeek;
  final int activeWeeks;
  final String workloadTier;
}



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

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final dashboardResponse = await dio.get(
        '${ApiResources.apiUrl}${ApiResources.studentDashboardEndPoint}',
        options: Options(headers: headers),
      );

      Response? analyticsResponse;
      try {
        analyticsResponse = await dio.get(
          '${ApiResources.apiUrl}${ApiResources.studentDashboardAnalyticsEndPoint}',
          options: Options(headers: headers),
        );
      } catch (_) {
        analyticsResponse = null;
      }

      final model = StudentDashboardModel.fromJson(dashboardResponse.data);
      final analytics = analyticsResponse?.data is Map<String, dynamic>
          ? StudentAnalyticsModel.fromJson(
              analyticsResponse!.data as Map<String, dynamic>)
          : const StudentAnalyticsModel.empty();

      emit(
        StudentDashboardLoaded(
          model: model,
          analytics: analytics,
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
