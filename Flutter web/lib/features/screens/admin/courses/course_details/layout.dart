import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home_courses/model/model.dart';
import '../course_details/courseDetailsState_managment/course_details_cubit.dart';
import '../course_details/view.dart';
import '../course_details/lectures/state_managment/lectures_cubit.dart';
import '../course_details/lectures/view/view.dart';
import 'lectures/functions/sideBar.dart';

class CourseLayout extends StatefulWidget {
  const CourseLayout({super.key, required this.courseModel});
  final GetCoursesModel courseModel;

  @override
  State<CourseLayout> createState() => CourseLayoutState();
}

class CourseLayoutState extends State<CourseLayout> {
  bool _collapsed = false;
  String _activeLabel = 'Course Details';

  void setActiveLabel(String label) {
    setState(() => _activeLabel = label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _buildContent() {
    switch (_activeLabel) {
      case 'Course Details':
        return BlocProvider(
          create: (_) =>
          CourseDetailsCubit()..loadCourse(widget.courseModel,
              widget.courseModel.id
          ),
          child: CourseDetailsScreen(courseModel: widget.courseModel),
        );

      case 'Lectures':
        return BlocProvider(
          create: (_) => LectureCubit(courseModel: widget.courseModel),
          child: LecturesScreen(courseId: widget.courseModel.id, course: widget.courseModel,),
        );

      case 'Quizzes':
        return _ComingSoon(
          icon: Icons.quiz_rounded,
          label: 'Quizzes',
          count: widget.courseModel.quizzesCount,
          color: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFF3E8FF),
        );

      case 'Assignments':
        return _ComingSoon(
          icon: Icons.assignment_rounded,
          label: 'Assignments',
          count: widget.courseModel.assignmentsCount,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFD1FAE5),
        );

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
          CourseDetailsCubit()..loadCourse(widget.courseModel,widget.courseModel.id),
          child: CourseDetailsScreen(courseModel: widget.courseModel),
        );
    }
  }
}

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
                    horizontal: 14, vertical: 6),
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
              style: TextStyle(
                color: color.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}