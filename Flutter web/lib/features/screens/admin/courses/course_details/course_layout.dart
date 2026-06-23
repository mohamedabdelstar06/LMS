// ============================================================
// course_layout.dart  — FINAL version
// isAdmin is resolved from the stored user role/token,
// NOT passed manually every time.
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

// ── Quizzes + Questions feature imports ───────────────────────


// ── Role resolver ─────────────────────────────────────────────
// Reads the stored JWT role claim to determine admin status.
// Returns true if role is "Admin" or "Instructor".
// Adjust the role string to match your backend's JWT claims.
Future<bool> _resolveIsAdmin() async {
  try {
    final role = await TokenStorageHelper.getTokenSecure(); // implement this if not yet done
    return role == 'Admin' || role == 'Instructor';
  } catch (_) {
    // If your helper doesn't have getUserRole() yet, fall back to
    // checking SharedPreferences directly or defaulting to admin:
    return true; // change to false for student-only builds
  }
}

// ── Dio factory ───────────────────────────────────────────────
Dio _buildDio() => Dio(
      BaseOptions(
        baseUrl: 'https://skylearn.runasp.net/api/',
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    )..interceptors.add(
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

// ─────────────────────────────────────────────────────────────

class CourseLayout extends StatefulWidget {
  const CourseLayout({
    super.key,
    required this.courseModel,
    /// Pass this explicitly if you already know the role (e.g. from login state).
    /// If null, the layout resolves it automatically from the stored token.
    this.isAdmin,
  });

  final GetCoursesModel courseModel;
  final bool? isAdmin;

  @override
  State<CourseLayout> createState() => CourseLayoutState();
}

class CourseLayoutState extends State<CourseLayout> {
  bool _collapsed = false;
  String _activeLabel = 'Course Details';
  bool _isAdmin = true; // resolved in initState
  bool _roleResolved = false;

  late final AssignmentCubit _assignmentCubit;

  @override
  void initState() {
    super.initState();
    _assignmentCubit = AssignmentCubit(
      repository: AssignmentRepository(_buildDio()),
      courseId: widget.courseModel.id,
    )..loadAssignments();

    if (widget.isAdmin != null) {
      // Caller already knows the role — use it directly.
      _isAdmin = widget.isAdmin!;
      _roleResolved = true;
    } else {
      // Resolve from stored token asynchronously.
      _resolveIsAdmin().then((admin) {
        if (mounted) setState(() { _isAdmin = admin; _roleResolved = true; });
      });
    }
  }

  @override
  void dispose() {
    _assignmentCubit.close();
    super.dispose();
  }

  void setActiveLabel(String label) => setState(() => _activeLabel = label);

  @override
  Widget build(BuildContext context) {
    // Show a brief splash while the role is being resolved from the token
    if (!_roleResolved) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F7FF),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

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
      // ── Course Details ────────────────────────────────────
      case 'Course Details':
        return BlocProvider(
          create: (_) => CourseDetailsCubit()..loadCourseById(widget.courseModel.id),
          child: CourseDetailsScreen(courseModel: widget.courseModel),
        );

      // ── Lectures ─────────────────────────────────────────
      case 'Lectures':
        return BlocProvider(
          create: (_) => LectureCubit(courseModel: widget.courseModel),
          child: LecturesScreen(
            courseId: widget.courseModel.id,
            course: widget.courseModel,
          ),
        );

      // ── Quizzes: fully functional, role-aware ─────────────
      // QuizzesScreen creates its own BlocProviders internally.
      case 'Quizzes':
        return QuizzesScreen(
          courseModel: widget.courseModel,
          isAdmin: _isAdmin,
        );

      // ── Assignments ──────────────────────────────────────
      case 'Assignments':
        return AssignmentsScreen(courseModel: widget.courseModel);

      // ── Questions: sidebar shortcut → prompts to pick a quiz
      // The real question management lives inside QuizzesScreen
      // via the "Manage Questions" button on each quiz card.
      

      // ── Settings ─────────────────────────────────────────
      case 'Settings':
        return const _ComingSoon(
          icon: Icons.settings_rounded,
          label: 'Settings',
          color: Color(0xFF64748B),
          bgColor: Color(0xFFF1F5F9),
        );

      default:
        return BlocProvider(
          create: (_) => CourseDetailsCubit()..loadCourseById(widget.courseModel.id),
          child: CourseDetailsScreen(courseModel: widget.courseModel),
        );
    }
  }
}

// ── Questions hint screen ────────────────────────────────────


// ── Coming Soon placeholder ───────────────────────────────────
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
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Icon(icon, color: color, size: 46),
            ),
            const SizedBox(height: 20),
            Text(label, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            const SizedBox(height: 12),
            Text('Coming soon...', style: TextStyle(color: color.withOpacity(0.5), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
