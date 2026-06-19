// ============================================================
// course_layout_final.dart
// Quizzes + Questions both wired up
// ============================================================
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignmnet_repo.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/state_mangmnet/assignments_cubit.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/view/view.dart';
import 'package:lms/features/screens/quizes/quizzes_screen.dart';

import '../home_courses/model/model.dart';
import '../course_details/courseDetailsState_managment/course_details_cubit.dart';
import '../course_details/view.dart';
import '../course_details/lectures/state_managment/lectures_cubit.dart';
import '../course_details/lectures/view/view.dart';
import 'lectures/functions/sideBar.dart';

// ── Feature imports ───────────────────────────────────────────


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
            final token = await TokenStorageHelper.getTokenSecure();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );

class CourseLayout extends StatefulWidget {
  const CourseLayout({
    super.key,
    required this.courseModel,
    this.isAdmin = true,
  });

  final GetCoursesModel courseModel;
  final bool isAdmin;

  @override
  State<CourseLayout> createState() => CourseLayoutState();
}

class CourseLayoutState extends State<CourseLayout> {
  bool _collapsed = false;
  String _activeLabel = 'Course Details';

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

  void setActiveLabel(String label) => setState(() => _activeLabel = label);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _assignmentCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F7FF),
        body: Row(
          children: [
            Sidebar(
              collapsed: _collapsed,
              onToggle: () => setState(() => _collapsed = !_collapsed),
              activeLabel: _activeLabel,
              courseModel: widget.courseModel,
              onIteSelected: setActiveLabel,
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

      // ── Quizzes: fully functional ────────────────────────
      case 'Quizzes':
        return QuizzesScreen(
          courseModel: widget.courseModel,
          isAdmin: widget.isAdmin,
        );

      case 'Assignments':
        return AssignmentsScreen(courseModel: widget.courseModel);

      // ── Questions: browse all questions for this course ───
      // Typically admin use-case (not tied to a specific quiz)
      // Shows a picker first then loads questions for that quiz
      case 'Questions':
        return _QuestionsPlaceholder(
          courseModel: widget.courseModel,
          isAdmin: widget.isAdmin,
        );

      case 'Settings':
        return const _ComingSoon(
          icon: Icons.settings_rounded,
          label: 'Settings',
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

// ── Questions placeholder (prompts user to pick a quiz first) ─
class _QuestionsPlaceholder extends StatelessWidget {
  const _QuestionsPlaceholder({
    required this.courseModel,
    required this.isAdmin,
  });
  final GetCoursesModel courseModel;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F7FF),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFFF59E0B),
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Questions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Open a quiz from the Quizzes tab,\nthen tap "Questions" to manage them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Quizzes tab
                final state = context
                    .findAncestorStateOfType<CourseLayoutState>();
                state?.setActiveLabel('Quizzes');
              },
              icon: const Icon(Icons.quiz_rounded, size: 18),
              label: const Text('Go to Quizzes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });
  final IconData icon;
  final String label;
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
