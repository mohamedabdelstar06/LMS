// ============================================================
// course_layout.dart  — drop-in replacement for your existing file
// ============================================================
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignmnet_repo.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/state_mangmnet/assignments_cubit.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/view/view.dart';

import '../home_courses/model/model.dart';
import '../course_details/courseDetailsState_managment/course_details_cubit.dart';
import '../course_details/view.dart';
import '../course_details/lectures/state_managment/lectures_cubit.dart';
import '../course_details/lectures/view/view.dart';
import 'lectures/functions/sideBar.dart';



// ── Shared Dio instance (reuse your app singleton instead) ───
Dio _buildDio() =>
    Dio(
        BaseOptions(
          baseUrl: 'https://skylearn.runasp.net/api/',
          receiveDataWhenStatusError: true,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Replace TokenStorageHelper with your actual helper
            final token = await TokenStorageHelper.getTokenSecure();
             if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );

// ────────────────────────────────────────────────────────────

class CourseLayout extends StatefulWidget {
  const CourseLayout({super.key, required this.courseModel});
  final GetCoursesModel courseModel;

  @override
  State<CourseLayout> createState() => CourseLayoutState();
}

class CourseLayoutState extends State<CourseLayout> {
  bool _collapsed = false;
  String _activeLabel = 'Course Details';

  // Cubit kept alive so badge count persists across tab switches
  late final AssignmentCubit _assignmentCubit;

  @override
  void initState() {
    super.initState();
    _assignmentCubit = AssignmentCubit(
      repository: AssignmentRepository(_buildDio()),
      courseId: widget.courseModel.id,
    )..loadAssignments();
  }

  @override
  void dispose() {
    _assignmentCubit.close();
    super.dispose();
  }

  void setActiveLabel(String label) {
    setState(() => _activeLabel = label);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _assignmentCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F7FF),
        body: Row(
          children: [
            // Pass the live badge count to the sidebar
            BlocBuilder<AssignmentCubit, dynamic>(
              builder: (context, assignmentState) => Sidebar(
                collapsed: _collapsed,
                onToggle: () => setState(() => _collapsed = !_collapsed),
                activeLabel: _activeLabel,
                courseModel: widget.courseModel,
                onIteSelected: setActiveLabel,
                // 👇 If your Sidebar accepts a badgeCounts map, pass it here.
                // badgeCounts: {
                //   'Assignments': assignmentState.assignments.length,
                // },
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_activeLabel) {
      case 'Course Details':
        return BlocProvider(
          create: (_) =>
              CourseDetailsCubit()..loadCourseById(widget.courseModel.id),
          child: CourseDetailsScreen(courseModel: widget.courseModel),
        );

      case 'Lectures':
        return BlocProvider(
          create: (_) => LectureCubit(courseModel: widget.courseModel),
          child: LecturesScreen(
            courseId: widget.courseModel.id,
            course: widget.courseModel,
          ),
        );

      case 'Quizzes':
        return _ComingSoon(
          icon: Icons.quiz_rounded,
          label: 'Quizzes',
          count: widget.courseModel.quizzesCount,
          color: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFF3E8FF),
        );

      // ── Assignments: now fully functional ─────────────────
      case 'Assignments':
        return AssignmentsScreen(courseModel: widget.courseModel);

      case 'Questions':
        return const _ComingSoon(
          icon: Icons.help_outline_rounded,
          label: 'Questions',
          count: null,
          color: Color(0xFFF59E0B),
          bgColor: Color(0xFFFEF3C7),
        );

      case 'Settings':
        return const _ComingSoon(
          icon: Icons.settings_rounded,
          label: 'Settings',
          count: null,
          color: Color(0xFF64748B),
          bgColor: Color(0xFFF1F5F9),
        );

      default:
        return BlocProvider(
          create: (_) =>
              CourseDetailsCubit()..loadCourseById(widget.courseModel.id),
          child: CourseDetailsScreen(courseModel: widget.courseModel),
        );
    }
  }
}

// ─── Coming Soon placeholder (unchanged) ────────────────────
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final int? count;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F7FF),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 46),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            if (count != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '$count available',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Coming soon...',
              style: TextStyle(color: color.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
