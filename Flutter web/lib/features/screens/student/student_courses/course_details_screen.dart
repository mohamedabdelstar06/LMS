import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/state_managment/lectures_cubit.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/view/view.dart';
import 'package:lms/features/screens/student/course_grades_screen.dart';
import 'package:lms/features/screens/student/student_courses/assignments_list_screen.dart';
import 'package:lms/features/screens/student/student_courses/quizzes_list_screen.dart';


import '../../../../core/cons/Colors/app_colors.dart';
import '../student_courses/model/view.dart';
import '../student_courses/view.dart';
import 'course_detail_model.dart';
import 'course_detail_cubit.dart';
import 'course_detail_states.dart';

String buildImageUrl(String? image) {
  if (image == null || image.isEmpty) return '';
  if (image.startsWith('http')) return image;
  return 'https://skylearn.runasp.net$image';
}

class CourseDetailsScreen extends StatelessWidget {
  final int courseId;
  final CourseEnrollmentModel? preview;

  const CourseDetailsScreen({super.key, required this.courseId, this.preview});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseDetailCubit()..getCourseDetail(courseId),
      child: _CourseDetailsView(preview: preview),
    );
  }
}

class _CourseDetailsView extends StatelessWidget {
  final CourseEnrollmentModel? preview;
  const _CourseDetailsView({this.preview});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;
    final maxWidth = isLargeScreen
        ? 1100.0
        : (isMediumScreen ? 800.0 : double.infinity);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MYColors.gradientColor_3,
            MYColors.gradientColor_2.withValues(alpha: 0.25),
            MYColors.gradientColor_3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<CourseDetailCubit, CourseDetailState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BackRow(title: preview?.courseTitle),
                        const SizedBox(height: 16),
                        _buildBody(context, state, isLargeScreen),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CourseDetailState state,
    bool isLargeScreen,
  ) {
    if (state is CourseDetailLoading && preview == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is CourseDetailError && preview == null) {
      return _ErrorState(message: state.message, onRetry: () {});
    }

    CourseDetailModel? course = state is CourseDetailSuccess
        ? state.course
        : null;

    final title = course?.title ?? preview?.courseTitle ?? '';
    final description = course?.description ?? preview?.courseDescription ?? '';
    final image = course?.imageUrl ?? preview?.imageUrl ?? '';
    final creditHours = course?.creditHours ?? preview?.creditHours ?? 0;
    final instructorName =
        course?.instructorName ?? preview?.instructorName ?? '';
    final enrolledCount =
        course?.enrolledStudentsCount ?? preview?.enrolledStudentsCount ?? 0;

    final isStillLoadingFullDetail =
        state is CourseDetailLoading && preview != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CourseHeaderCard(
          title: title,
          description: description,
          imageUrl: image,
          creditHours: creditHours,
          instructorName: instructorName,
          enrolledCount: enrolledCount,
          profileImageUrl: course?.instructor?.profileImageUrl,
          progressPercentage: course?.progressPercentage,
          isLargeScreen: isLargeScreen,
        ),
        const SizedBox(height: 28),
        Text(
          'Explore Course',
          style: TextStyle(
            fontSize: isLargeScreen ? 22 : 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'inter',
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isStillLoadingFullDetail
              ? 'Loading the latest course content...'
              : 'Jump into assignments, quizzes, lectures and grades for this course.',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: 'inter',
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 18),
        _ExploreGrid(
          courseId: course?.id ?? preview?.courseId ?? 0,
          courseTitle: title,
          course: course,
          assignmentsCount: course?.assignmentsCount,
          quizzesCount: course?.quizzesCount,
          lecturesCount: course?.lecturesCount,
          isLargeScreen: isLargeScreen,
          isLoadingCounts: isStillLoadingFullDetail,
        ),
      ],
    );
  }
}

// ── Back Row ──────────────────────────────────────────────────
class _BackRow extends StatelessWidget {
  final String? title;
  const _BackRow({this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Color(0xFF175CD3),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title ?? 'Course',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'inter',
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Course Header Card ────────────────────────────────────────
class _CourseHeaderCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final int creditHours;
  final String instructorName;
  final int enrolledCount;
  final String? profileImageUrl;
  final double? progressPercentage;
  final bool isLargeScreen;

  const _CourseHeaderCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.creditHours,
    required this.instructorName,
    required this.enrolledCount,
    this.profileImageUrl,
    this.progressPercentage,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: isLargeScreen ? 220 : 160,
            child: imageUrl.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      IgnorePointer(
                        child: WebImage(
                          url: buildImageUrl(imageUrl),
                          width: double.infinity,
                          height: isLargeScreen ? 220 : 160,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 16,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 26 : 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'inter',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    color: const Color(0xffE3F6FF),
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 26 : 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'inter',
                        color: const Color(0xff175CD3),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty)
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'inter',
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.school_rounded,
                      label: '$creditHours Credit Hours',
                    ),
                    _InfoChip(
                      icon: Icons.groups_rounded,
                      label: '$enrolledCount Students',
                    ),
                    if (instructorName.isNotEmpty)
                      _InfoChip(
                        icon: Icons.person_rounded,
                        label: instructorName,
                      ),
                  ],
                ),
                if (progressPercentage != null) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Your Progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'inter',
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${progressPercentage!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'inter',
                          color: Color(0xFF175CD3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (progressPercentage! / 100).clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: const Color(0xffE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF175CD3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF175CD3)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'inter',
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Explore Grid ──────────────────────────────────────────────
class _ExploreGrid extends StatelessWidget {
  final int courseId;
  final String courseTitle;
  final CourseDetailModel? course;
  final int? assignmentsCount;
  final int? quizzesCount;
  final int? lecturesCount;
  final bool isLargeScreen;
  final bool isLoadingCounts;

  const _ExploreGrid({
    required this.courseId,
    required this.courseTitle,
    required this.course,
    this.assignmentsCount,
    this.quizzesCount,
    this.lecturesCount,
    required this.isLargeScreen,
    required this.isLoadingCounts,
  });

  @override
  Widget build(BuildContext context) {
    // 4 cards: 2×2 on medium, 4 in a row on large, 1 col on mobile
    final crossAxisCount = isLargeScreen
        ? 4
        : (MediaQuery.of(context).size.width > 600 ? 2 : 1);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: isLargeScreen ? 1.3 : 1.7,
      children: [
        // ── Assignments ──────────────────────────────────────
        _ExploreCard(
          title: 'Assignments',
          subtitle: 'View and submit your work',
          icon: Icons.assignment_rounded,
          gradientColors: const [Color(0xFF175CD3), Color(0xFF4F8DFD)],
          count: assignmentsCount,
          isLoadingCount: isLoadingCounts,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssignmentsListScreen(
                courseId: courseId,
                courseTitle: courseTitle,
              ),
            ),
          ),
        ),

        // ── Quizzes ──────────────────────────────────────────
        _ExploreCard(
          title: 'Quizzes',
          subtitle: 'Test your knowledge',
          icon: Icons.quiz_rounded,
          gradientColors: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
          count: quizzesCount,
          isLoadingCount: isLoadingCounts,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizzesListScreen(
                courseId: courseId,
                courseTitle: courseTitle,
              ),
            ),
          ),
        ),

        // ── Lectures ─────────────────────────────────────────
        _ExploreCard(
          title: 'Lectures',
          subtitle: 'Course materials & videos',
          icon: Icons.menu_book_rounded,
          gradientColors: const [Color(0xFF059669), Color(0xFF34D399)],
          count: lecturesCount,
          isLoadingCount: isLoadingCounts,
          onTap: () {
            final loadedCourse = course;
            if (loadedCourse == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Still loading course details — try again in a second.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            final adminCourseModel = loadedCourse.toGetCoursesModel();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => LectureCubit(courseModel: adminCourseModel),
                  child: LecturesScreen(
                    courseId: adminCourseModel.id,
                    course: adminCourseModel,
                  ),
                ),
              ),
            );
          },
        ),

        // ── Grades ───────────────────────────────────────────
        _ExploreCard(
          title: 'Grades',
          subtitle: 'Your quiz & assignment scores',
          icon: Icons.grade_rounded,
          gradientColors: const [Color(0xFFD97706), Color(0xFFFBBF24)],
          count: null, // no count badge needed for grades
          isLoadingCount: false,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseGradesScreen(
                courseId: courseId,
                courseName: courseTitle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Explore Card ──────────────────────────────────────────────
class _ExploreCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final int? count;
  final bool isLoadingCount;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.count,
    required this.isLoadingCount,
    required this.onTap,
  });

  @override
  State<_ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<_ExploreCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: hovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withValues(
                    alpha: hovered ? 0.35 : 0.2,
                  ),
                  blurRadius: hovered ? 24 : 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 22),
                    ),
                    const Spacer(),
                    if (widget.isLoadingCount)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white70,
                          ),
                        ),
                      )
                    else if (widget.count != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.count}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'inter',
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'inter',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Explore',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedSlide(
                      offset: hovered ? const Offset(0.3, 0) : Offset.zero,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'inter',
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
