import 'package:flutter/material.dart';

import '../../../home_courses/model/model.dart';
import 'meta_tag.dart';

class CourseMetaRow extends StatelessWidget {
  const CourseMetaRow({required this.course});
  final GetCoursesModel course;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        MetaTag(
            icon: Icons.calendar_today_outlined, label: course.yearName),
        MetaTag(
          icon: Icons.timer_outlined,
          label: '${course.creditHours} Credit Hrs',
        ),
        MetaTag(
          icon: Icons.people_outline,
          label: '${course.enrolledStudentsCount} Students',
        ),
        // _MetaTag(
        //   icon: Icons.people_outline,
        //   label: '${course.lecturesCount} Lectures',
        // ),
      ],
    );
  }
}
