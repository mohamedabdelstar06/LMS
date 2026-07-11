// ignore_for_file: deprecated_member_use
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/helpers/api_url_helper.dart';
import 'package:lms/features/screens/Announcement/dashboard_announcment_card.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/features/screens/admin/Noti_button.dart';
import 'package:lms/features/screens/instructor/home_courses/view.dart';
import 'package:lms/generated/assets.dart';

import 'instructor_dashboard_cubit.dart';
import 'instructor_dashboard_model.dart';
import 'instructor_dashboard_states.dart';

// ── Palette (mirrors admin dashboard) ────────────────────────
const _kBg = Color(0xFFF0F4FF);
const _kCard = Colors.white;
const _kBlue = Color(0xFF175CD3);
const _kIndigo = Color(0xFF4F46E5);
const _kGreen = Color(0xFF12B76A);
const _kOrange = Color(0xFFF79009);
const _kRed = Color(0xFFF04438);
const _kPurple = Color(0xFF7C3AED);
const _kCyan = Color(0xFF0EA5E9);
const _kText = Color(0xFF101828);
const _kSub = Color(0xFF667085);

// ── Infer activity type from title ──────────────────────────
String _inferActivityType(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('quiz')) return 'Quiz';
  if (lower.contains('assignment')) return 'Assignment';
  if (lower.contains('lecture')) return 'Lecture';
  if (lower.contains('exam')) return 'Exam';
  return 'Activity';
}

// ── Entry ─────────────────────────────────────────────────────
class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstructorDashboardCubit()..loadDashboard(),
      child: const _InstructorDashboardView(),
    );
  }
}

class _InstructorDashboardView extends StatefulWidget {
  const _InstructorDashboardView();

  @override
  State<_InstructorDashboardView> createState() =>
      _InstructorDashboardViewState();
}

class _InstructorDashboardViewState extends State<_InstructorDashboardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: const _InstructorDashboardAppBar(),
      body: BlocConsumer<InstructorDashboardCubit, InstructorDashboardState>(
        listener: (_, state) {
          if (state is InstructorDashboardLoaded) _fadeCtrl.forward(from: 0);
        },
        builder: (context, state) {
          if (state is InstructorDashboardLoading ||
              state is InstructorDashboardInitial) {
            return const _LoadingView();
          }
          if (state is InstructorDashboardError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<InstructorDashboardCubit>().loadDashboard(),
            );
          }
          if (state is InstructorDashboardLoaded) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: _DashboardBody(model: state.model),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────
class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.model});
  final InstructorDashboardModel model;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w > 900;
    final p = isWide ? 24.0 : 16.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats row ──────────────────────────────────────
          _StatsRow(model: model, isWide: isWide),
          const SizedBox(height: 24),

          // ── Weekly engagement chart ─────────────────────────
          _WeeklyChart(engagement: model.weeklyEngagement),
          const SizedBox(height: 24),

          // ── Courses + Activities ────────────────────────────
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _RecentCoursesCard(courses: model.recentCourses),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _RecentActivitiesCard(
                        activities: model.recentActivities,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _RecentCoursesCard(courses: model.recentCourses),
                    const SizedBox(height: 16),
                    _RecentActivitiesCard(activities: model.recentActivities),
                  ],
                ),
          const SizedBox(height: 24),

          // ── Course Progress Overview ──────────────────────
          _InstructorCourseProgressCard(courses: model.recentCourses),
          const SizedBox(height: 24),

          // ── Submissions ─────────────────────────────────────
          _RecentSubmissionsCard(submissions: model.recentSubmissions),
          const SizedBox(height: 24),

          // ── Recent Announcements ───────────────────────────
          const DashboardAnnouncementCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Stats ─────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.model, required this.isWide});
  final InstructorDashboardModel model;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatData(
        label: 'My Courses',
        value: model.totalCourses,
        icon: Icons.menu_book_rounded,
        color: _kBlue,
        subtitle: 'Published courses',
        page: const TeacherCourseScreen(),
      ),
      _StatData(
        label: 'Total Students',
        value: model.totalStudents,
        icon: Icons.school_rounded,
        color: _kGreen,
        subtitle: 'Enrolled learners',
        page: const TeacherCourseScreen(),
      ),
      _StatData(
        label: 'Activities',
        value: model.totalActivities,
        icon: Icons.task_alt_rounded,
        color: _kPurple,
        subtitle: 'Quizzes & assignments',
        page: const TeacherCourseScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : (items.length > 2 ? 2 : 1),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 3.1 : 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _AnimatedStatCard(data: items[i], delay: i * 80),
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.page,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final Widget page;
}

class _AnimatedStatCard extends StatefulWidget {
  const _AnimatedStatCard({required this.data, required this.delay});
  final _StatData data;
  final int delay;

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _iconScale = Tween<double>(
      begin: 0.88,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _ctrl.forward().then((_) {
          if (mounted) {
            _ctrl.repeat(
              reverse: true,
              period: const Duration(milliseconds: 1600),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => widget.data.page),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.data.color.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedBuilder(
                  animation: _iconScale,
                  builder: (_, __) => Transform.scale(
                    scale: _iconScale.value,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.data.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.data.icon,
                        color: widget.data.color,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: widget.data.color.withOpacity(0.4),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${widget.data.value}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: widget.data.color,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.data.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kText,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.data.subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: _kSub,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly Engagement Chart ────────────────────────────────────
class _WeeklyChart extends StatefulWidget {
  const _WeeklyChart({required this.engagement});
  final List<InstructorWeeklyEngagement> engagement;

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxVal = widget.engagement.fold<int>(
      1,
      (p, e) => math.max(p, e.submissions),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: _kCyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Engagement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                      ),
                    ),
                    Text(
                      'Student submissions per day',
                      style: TextStyle(fontSize: 11, color: _kSub),
                    ),
                  ],
                ),
              ),
              _Legend(color: _kCyan, label: 'Submissions'),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.engagement.map((e) {
                  final fraction = maxVal == 0
                      ? 0.05
                      : (e.submissions / maxVal).clamp(0.05, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (e.submissions > 0)
                            Text(
                              '${e.submissions}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: _kCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Container(
                            width: double.infinity,
                            height: 90 * fraction * _anim.value,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [_kCyan, _kCyan.withOpacity(0.5)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: e.submissions > 0
                                  ? [
                                      BoxShadow(
                                        color: _kCyan.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.day,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kSub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Courses ─────────────────────────────────────────────
class _RecentCoursesCard extends StatelessWidget {
  const _RecentCoursesCard({required this.courses});
  final List<InstructorRecentCourse> courses;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: _kBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'My Courses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherCourseScreen(),
                  ),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(color: _kBlue, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (courses.isEmpty)
            _EmptyState(
              icon: Icons.menu_book_outlined,
              message: 'No courses published yet',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (_, i) =>
                  _CourseTile(course: courses[i], delay: i * 60),
            ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatefulWidget {
  const _CourseTile({required this.course, required this.delay});
  final InstructorRecentCourse course;
  final int delay;

  @override
  State<_CourseTile> createState() => _CourseTileState();
}

class _CourseTileState extends State<_CourseTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _slide = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _imageUrl {
    return ApiUrlHelper.resolveMediaUrl(widget.course.imageUrl) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(_slide.value, 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _imageUrl.isNotEmpty
                      ? Image.network(
                          _imageUrl,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _CoursePlaceholder(title: widget.course.title),
                        )
                      : _CoursePlaceholder(title: widget.course.title),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.course.departmentName,
                        style: const TextStyle(fontSize: 11, color: _kSub),
                      ),
                      const SizedBox(height: 4),
                      _Chip(
                        label:
                            '${widget.course.enrolledStudentsCount} enrolled',
                        color: _kGreen,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _kSub,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoursePlaceholder extends StatelessWidget {
  const _CoursePlaceholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      color: _kIndigo.withOpacity(0.1),
      alignment: Alignment.center,
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : 'C',
        style: const TextStyle(
          color: _kIndigo,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}

// ── Recent Activities ──────────────────────────────────────────
class _RecentActivitiesCard extends StatelessWidget {
  const _RecentActivitiesCard({required this.activities});
  final List<InstructorRecentActivity> activities;

  static const _typeColors = {
    'Quiz': _kPurple,
    'Assignment': _kBlue,
    'Lecture': _kCyan,
    'Exam': _kRed,
    'Activity': _kOrange,
  };

  static const _typeIcons = {
    'Quiz': Icons.quiz_rounded,
    'Assignment': Icons.assignment_rounded,
    'Lecture': Icons.play_circle_rounded,
    'Exam': Icons.school_rounded,
    'Activity': Icons.task_alt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: _kPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            _EmptyState(
              icon: Icons.timeline_outlined,
              message: 'No activities yet',
            )
          else
            ...activities.take(5).toList().asMap().entries.map((entry) {
              final a = entry.value;
              final typeKey = _inferActivityType(a.title);
              final color = _typeColors[typeKey] ?? _kOrange;
              final icon = _typeIcons[typeKey] ?? Icons.task_alt_rounded;
              return _ActivityTile(
                activity: a,
                color: color,
                icon: icon,
                delay: entry.key * 60,
              );
            }),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatefulWidget {
  const _ActivityTile({
    required this.activity,
    required this.color,
    required this.icon,
    required this.delay,
  });
  final InstructorRecentActivity activity;
  final Color color;
  final IconData icon;
  final int delay;

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _opacity = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.color.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: a.isVisible
                                  ? _kGreen.withOpacity(0.1)
                                  : _kOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              a.isVisible ? 'Visible' : 'Hidden',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: a.isVisible ? _kGreen : _kOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.courseTitle,
                        style: const TextStyle(fontSize: 11, color: _kSub),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, y · h:mm a').format(a.createdAt),
                        style: const TextStyle(fontSize: 10, color: _kSub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Recent Submissions ─────────────────────────────────────────
class _RecentSubmissionsCard extends StatelessWidget {
  const _RecentSubmissionsCard({required this.submissions});
  final List<InstructorRecentSubmission> submissions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: _kGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Recent Submissions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (submissions.isEmpty)
            _EmptyState(
              icon: Icons.inbox_outlined,
              message: 'No submissions yet',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: submissions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (_, i) =>
                  _SubmissionTile(sub: submissions[i], delay: i * 60),
            ),
        ],
      ),
    );
  }
}

class _SubmissionTile extends StatefulWidget {
  const _SubmissionTile({required this.sub, required this.delay});
  final InstructorRecentSubmission sub;
  final int delay;

  @override
  State<_SubmissionTile> createState() => _SubmissionTileState();
}

class _SubmissionTileState extends State<_SubmissionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sub;
    return FadeTransition(
      opacity: _opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                s.studentName.isNotEmpty ? s.studentName[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: _kGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.studentName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${s.activityTitle} · ${s.courseTitle}',
                    style: const TextStyle(fontSize: 11, color: _kSub),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('MMM d').format(s.submittedAt),
              style: const TextStyle(fontSize: 11, color: _kSub),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────
class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: _kSub)),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    ),
  );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: _kBlue),
        SizedBox(height: 16),
        Text(
          'Loading Dashboard…',
          style: TextStyle(color: _kSub, fontSize: 14),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 64, color: _kRed),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _kText, fontSize: 15),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

// ── Instructor Dashboard App Bar ─────────────────────────────
class _InstructorDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _InstructorDashboardAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // ── Logo + Brand ──────────────────────────────
              _InstructorLogoBrand(),

              const Spacer(),

              // ── Management Nav Link ───────────────────────
              _InstructorNavLink(
                label: 'Management',
                icon: Icons.manage_accounts_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TeacherCourseScreen()),
                  );
                },
              ),

              const Spacer(),

              // ── Divider ───────────────────────────────────
              Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 20),

              // ── Notifications ─────────────────────────────
              FutureBuilder<String?>(
                future: TokenStorageHelper.getTokenSecure(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  return NotificationBellButton(
                    token: snapshot.data!,
                    role: 'instructor',
                  );
                },
              ),
              const SizedBox(width: 12),

              // ── Instructor Avatar ─────────────────────────
              _InstructorAvatar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructorLogoBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D2772).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(Assets.logo),
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اّفـــــاق',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D2772),
                letterSpacing: -0.3,
                fontFamily: 'inter',
              ),
            ),
            Text(
              'Instructor Portal',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InstructorNavLink extends StatefulWidget {
  const _InstructorNavLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_InstructorNavLink> createState() => _InstructorNavLinkState();
}

class _InstructorNavLinkState extends State<_InstructorNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _hovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'inter',
                  color: _hovered
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructorAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: PrefHelper.getFulName(),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Instructor';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: const Color(0xFF0D2772),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'I',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Instructor',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF94A3B8),
                      fontFamily: 'inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Instructor Course Progress Card ─────────────────────────
class _InstructorCourseProgressCard extends StatelessWidget {
  const _InstructorCourseProgressCard({required this.courses});
  final List<InstructorRecentCourse> courses;

  static int _simulatedProgress(int courseId) {
    final seed = (courseId * 31 + 17) % 100;
    return seed < 10 ? 10 + seed : seed;
  }

  static const _colors = [
    _kBlue,
    _kGreen,
    _kOrange,
    _kPurple,
    _kRed,
    _kIndigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: _kGreen, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Course Progress Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _kBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Estimated',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _kBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (courses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No courses available',
                  style: TextStyle(color: _kSub, fontSize: 13),
                ),
              ),
            )
          else
            ...courses.asMap().entries.map((entry) {
              final i = entry.key;
              final course = entry.value;
              final progress = _simulatedProgress(course.id);
              final color = _colors[i % _colors.length];
              return _InstructorCourseProgressTile(
                title: course.title,
                progress: progress,
                color: color,
                delay: i * 80,
              );
            }),
        ],
      ),
    );
  }
}

class _InstructorCourseProgressTile extends StatefulWidget {
  const _InstructorCourseProgressTile({
    required this.title,
    required this.progress,
    required this.color,
    required this.delay,
  });
  final String title;
  final int progress;
  final Color color;
  final int delay;

  @override
  State<_InstructorCourseProgressTile> createState() =>
      _InstructorCourseProgressTileState();
}

class _InstructorCourseProgressTileState
    extends State<_InstructorCourseProgressTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _width = Tween<double>(
      begin: 0,
      end: widget.progress / 100,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${widget.progress}%',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (_, c) => AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Stack(
                children: [
                  Container(
                    height: 8,
                    width: c.maxWidth,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 8,
                    width: c.maxWidth * _width.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color,
                          widget.color.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
