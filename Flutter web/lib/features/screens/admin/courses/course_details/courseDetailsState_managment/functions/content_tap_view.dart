import 'package:flutter/material.dart';

import '../../../home_courses/model/model.dart';
import '../../layout.dart';
import 'countSummaryCard.dart';

class ContentTabView extends StatelessWidget {
  const ContentTabView(
      {required this.course, required this.activeIndex});
  final GetCoursesModel course;
  final int activeIndex;

  void _goToSidebarItem(BuildContext context, String label) {
    final layoutState =
    context.findAncestorStateOfType<CourseLayoutState>();
    layoutState?.setActiveLabel(label);
  }

  @override
  Widget build(BuildContext context) {
    switch (activeIndex) {
      case 0:
        return CountSummaryCard(
          count: course.lecturesCount,
          icon: Icons.play_circle_filled,
          color: const Color(0xFF0EA5E9),
          bgColor: const Color(0xFFE0F2FE),
          label: 'Lecture',
          onViewAll: () => _goToSidebarItem(context, 'Lectures'),
        );
      case 1:
        return CountSummaryCard(
          count: course.quizzesCount,
          icon: Icons.quiz,
          color: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFF3E8FF),
          label: 'Quiz',
          onViewAll: () => _goToSidebarItem(context, 'Quizzes'),
        );
      case 2:
        return CountSummaryCard(
          count: course.assignmentsCount,
          icon: Icons.assignment,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFD1FAE5),
          label: 'Assignment',
          onViewAll: () => _goToSidebarItem(context, 'Assignments'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
