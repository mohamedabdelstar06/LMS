import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lms/features/screens/admin/courses/course_details/courseDetailsState_managment/functions/stateCard.dart';

import '../../../home_courses/model/model.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.course});
  final GetCoursesModel course;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.insert_drive_file_sharp,
            value: '${course.lecturesCount}',
            label: 'Lectures',
            color: const Color(0xFF0EA5E9),
            bgColor: const Color(0xFFE0F2FE),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.quiz_outlined,
            value: '${course.quizzesCount}',
            label: 'Quizzes',
            color: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFFF3E8FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            icon: Icons.assignment_outlined,
            value: '${course.assignmentsCount}',
            label: 'Assignments',
            color: const Color(0xFF059669),
            bgColor: const Color(0xFFD1FAE5),
          ),
        ),
        // const SizedBox(width: 10),
        // Expanded(
        //   child: _StatCard(
        //     icon: Icons.people_alt,
        //     value: '${course.enrolledStudentsCount}',
        //     label: 'Students',
        //     color: Colors.redAccent,
        //     bgColor: Colors.red.withValues(alpha: 0.3),
        //   ),
        // ),
      ],
    );
  }
}
