import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/course_details/courseDetailsState_managment/functions/progress.dart';
import 'package:lms/features/screens/admin/courses/course_details/courseDetailsState_managment/functions/section_label.dart';
import 'package:lms/features/screens/admin/courses/course_details/courseDetailsState_managment/functions/state_row.dart';
import '../course_details_cubit.dart';
import '../course_details_state.dart';
import 'content_tap_bar.dart';
import 'content_tap_view.dart';
import 'course_appbar.dart';
import 'course_meta_row.dart';
import 'expandable_discription.dart';
import 'instructor_card.dart';

class LoadedScreen extends StatelessWidget {
  const LoadedScreen({required this.state});
  final CourseDetailsLoaded state;

  @override
  Widget build(BuildContext context) {
    final course = state.course;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CourseHeroAppBar(course: course),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  CourseMetaRow(course: course),
                  const SizedBox(height: 24),
                  if (course.progressPercentage != null) ...[
                    ProgressCard(progress: course.progressPercentage!),
                    const SizedBox(height: 24),
                  ],
                  StatsRow(course: course),
                  const SizedBox(height: 28),
                  const SectionLabel(label: 'About this course'),
                  const SizedBox(height: 12),
                  ExpandableDescription(text: course.description),
                  const SizedBox(height: 28),
                  const SectionLabel(label: 'Course Content'),
                  const SizedBox(height: 16),
                  ContentTabBar(
                    activeIndex: state.activeTab,
                    onTap: (i) =>
                        context.read<CourseDetailsCubit>().setTab(i),
                  ),
                  const SizedBox(height: 16),
                  ContentTabView(
                    course: course,
                    activeIndex: state.activeTab,
                  ),
                  const SizedBox(height: 28),
                  InstructorCard(course: course),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
