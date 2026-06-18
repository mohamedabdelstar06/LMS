import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/core/widgets/app_bar.dart';
import 'package:lms/features/screens/admin/Noti_button.dart';
import 'package:lms/features/screens/admin/admin_profile/view.dart';
import 'package:lms/features/screens/admin/courses/home_courses/view.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/view.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/get_all%20squadrons/view.dart';
import 'package:lms/features/screens/admin/users/get_users/view.dart';
import 'package:lms/features/screens/logs/state_mangement/logs_cubit.dart';
import 'package:lms/features/screens/logs/state_mangement/repositery_fetch.dart';
import 'package:lms/features/screens/logs/view/view.dart';
import 'package:lms/generated/assets.dart';

import 'dashboard_cubit.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBg        = Color(0xFFF0F4FF);
const _kCard      = Colors.white;
const _kBlue      = Color(0xFF175CD3);
const _kBlueLight = Color(0xFF53B1FD);
const _kIndigo    = Color(0xFF4F46E5);
const _kGreen     = Color(0xFF12B76A);
const _kOrange    = Color(0xFFF79009);
const _kRed       = Color(0xFFF04438);
const _kPurple    = Color(0xFF7C3AED);
const _kText      = Color(0xFF101828);
const _kSub       = Color(0xFF667085);

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit()..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();
  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with TickerProviderStateMixin {
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
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded) _fadeCtrl.forward(from: 0);
        },
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const _LoadingView();
          }
          if (state is DashboardError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<DashboardCubit>().loadDashboard(),
            );
          }
          if (state is DashboardLoaded) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: _DashboardBody(
                stats: state.stats,
                overview: state.overview,
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  final DashboardStatsModel stats;
  final DashboardOverviewModel overview;

  const _DashboardBody({required this.stats, required this.overview});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w > 900;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: const CustomAppBar_1(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          children: [
            _StatsGrid(stats: stats, isWide: isWide),
            const SizedBox(height: 24),
            _WeeklyChart(weeklyHours: overview.weeklyHours),
            const SizedBox(height: 24),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _DepartmentsCard(
                          departments: overview.departments,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _TopInstructorsCard(
                          instructors: overview.topInstructors,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _DepartmentsCard(departments: overview.departments),
                      const SizedBox(height: 16),
                      _TopInstructorsCard(instructors: overview.topInstructors),
                    ],
                  ),
            const SizedBox(height: 24),
            _RecentCoursesCard(courses: overview.recentCourses),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
// ── Quick Nav ─────────────────────────────────────────────────────────────────

class _QuickNavRow extends StatelessWidget {
  final _items = const [
    _NavItem(label: 'Users',       icon: Icons.people_alt_rounded,   color: _kBlue,   page: GetUsersPage()),
    _NavItem(label: 'Courses',     icon: Icons.menu_book_rounded,    color: _kGreen,  page: AdminCourseScreen()),
    _NavItem(label: 'Departments', icon: Icons.domain_rounded,       color: _kOrange, page: DepartmentsScreen()),
    _NavItem(label: 'Squadrons',   icon: Icons.flight_rounded,       color: _kPurple, page: GetSquadronPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _items
          .map((item) => Expanded(child: _NavCard(item: item)))
          .toList(),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final Color color;
  final Widget page;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.page,
  });
}

class _NavCard extends StatefulWidget {
  final _NavItem item;
  const _NavCard({required this.item});
  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => widget.item.page),
        );
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 120,
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.item.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.item.color.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingIcon(icon: widget.item.icon, color: widget.item.color),
              const SizedBox(height: 6),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.item.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pulsing Animated Icon ─────────────────────────────────────────────────────

class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _PulsingIcon({required this.icon, required this.color});
  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(widget.icon, color: widget.color, size: 20),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardStatsModel stats;
  final bool isWide;

  const _StatsGrid({required this.stats, required this.isWide});

  @override
  Widget build(BuildContext context) {
   final items = [
      _StatData(
        'Total Users',
        stats.totalUsers,
        Icons.people_rounded,
        _kBlue,
        GetUsersPage(),
        'All registered accounts',
      ),
      _StatData(
        'Students',
        stats.totalStudents,
        Icons.school_rounded,
        _kGreen,
        GetUsersPage(),
        'Active learners enrolled',
      ),
      _StatData(
        'Instructors',
        stats.totalInstructors,
        Icons.person_pin_rounded,
        _kOrange,
        GetUsersPage(),
        'Teaching staff members',
      ),
      _StatData(
        'Courses',
        stats.totalCourses,
        Icons.menu_book_rounded,
        _kIndigo,
        AdminCourseScreen(),
        'Published course catalog',
      ),
      _StatData(
        'Departments',
        stats.totalDepartments,
        Icons.domain_rounded,
        _kPurple,
        DepartmentsScreen(),
        'Academic divisions',
      ),
      _StatData(
        'Squadrons',
        stats.totalSquadrons,
        Icons.flight_takeoff_rounded,
        _kRed,
        GetSquadronPage(),
        'Active flight squadrons',
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 3.1: 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _AnimatedStatCard(data: items[i], delay: i * 80),
    );
  }
}

class _StatData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Widget page;
   final String subtitle; 
  const _StatData(this.label, this.value, this.icon, this.color, this.page, this.subtitle);
}

class _AnimatedStatCard extends StatefulWidget {
  final _StatData data;
  final int delay;
  const _AnimatedStatCard({required this.data, required this.delay});
  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _opacity;
  late final Animation<int> _count;
  late final Animation<double> _iconScale;

 @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // رقم بيعد من 0
    _count = IntTween(
      begin: 0,
      end: widget.data.value,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // أيقونة pulse مستمر
    _iconScale = Tween<double>(
      begin: 0.88,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // شيل slide و opacity (الكارت ثابت)
    _slide = Tween<double>(begin: 0, end: 0).animate(_ctrl);
    _opacity = Tween<double>(begin: 1, end: 1).animate(_ctrl);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        // عد الرقم مرة واحدة
        _ctrl.forward().then((_) {
          if (mounted) {
            // بعدين pulse الأيقونة بس
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
            // ── Icon animated (pulse فقط) ──
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

            // ── Count animated ──
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

            // ── Label ──
            Text(
              widget.data.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kText,
              ),
            ),

            const SizedBox(height: 3),

            // ── Subtitle ──
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


class _WeeklyChart extends StatefulWidget {
  final List<WeeklyHour> weeklyHours;
  const _WeeklyChart({required this.weeklyHours});
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
    final maxVal = widget.weeklyHours.fold<int>(
      1,
      (prev, e) => math.max(prev, math.max(e.study, e.exams)),
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
              const Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              const Spacer(),
              _Legend(color: _kBlue, label: 'Study'),
              const SizedBox(width: 12),
              _Legend(color: _kOrange, label: 'Exams'),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: widget.weeklyHours.map((h) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _Bar(
                                value: h.study,
                                max: maxVal,
                                color: _kBlue,
                                progress: _anim.value,
                              ),
                              const SizedBox(width: 2),
                              _Bar(
                                value: h.exams,
                                max: maxVal,
                                color: _kOrange,
                                progress: _anim.value,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            h.day,
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

class _Bar extends StatelessWidget {
  final int value;
  final int max;
  final Color color;
  final double progress;

  const _Bar({
    required this.value,
    required this.max,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final heightFraction = max == 0 ? 0.05 : (value / max).clamp(0.05, 1.0);
    return Container(
      width: 10,
      height: 90 * heightFraction * progress,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: _kSub)),
      ],
    );
  }
}

// ── Departments Card ──────────────────────────────────────────────────────────

class _DepartmentsCard extends StatelessWidget {
  final List<DepartmentOverview> departments;
  const _DepartmentsCard({required this.departments});

  @override
  Widget build(BuildContext context) {
    final maxCourses = departments.fold<int>(
      1,
      (prev, e) => math.max(prev, e.courseCount),
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
                  color: _kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.domain_rounded,
                    color: _kOrange, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Departments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...departments.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DepartmentRow(dept: d, maxCourses: maxCourses),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentRow extends StatefulWidget {
  final DepartmentOverview dept;
  final int maxCourses;
  const _DepartmentRow({required this.dept, required this.maxCourses});
  @override
  State<_DepartmentRow> createState() => _DepartmentRowState();
}

class _DepartmentRowState extends State<_DepartmentRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    final fraction = widget.maxCourses == 0
        ? 0.0
        : widget.dept.courseCount / widget.maxCourses;
    _width = Tween<double>(begin: 0, end: fraction.clamp(0.05, 1.0)).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.dept.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kText,
              ),
            ),
            Text(
              '${widget.dept.courseCount} courses',
              style: const TextStyle(fontSize: 11, color: _kSub),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (_, constraints) => Stack(
            children: [
              Container(
                height: 6,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedBuilder(
                animation: _width,
                builder: (_, __) => Container(
                  height: 6,
                  width: constraints.maxWidth * _width.value,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kOrange, Color(0xFFFFD166)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Top Instructors ───────────────────────────────────────────────────────────

class _TopInstructorsCard extends StatelessWidget {
  final List<TopInstructor> instructors;
  const _TopInstructorsCard({required this.instructors});

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
                child: const Icon(Icons.workspace_premium_rounded,
                    color: _kPurple, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Top Instructors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...instructors.asMap().entries.map(
                (e) => _InstructorTile(
                  instructor: e.value,
                  rank: e.key + 1,
                ),
              ),
        ],
      ),
    );
  }
}

class _InstructorTile extends StatelessWidget {
  final TopInstructor instructor;
  final int rank;
  const _InstructorTile({required this.instructor, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: rank == 1 ? const Color(0xFFFFD700) : _kSub.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: rank == 1 ? Colors.white : _kSub,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: _kPurple.withOpacity(0.1),
            backgroundImage: instructor.profileImageUrl.isNotEmpty
                ? NetworkImage(
                    '${ApiResources.apiUrl}${instructor.profileImageUrl}')
                : null,
            child: instructor.profileImageUrl.isEmpty
                ? Text(
                    instructor.fullName.isNotEmpty
                        ? instructor.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: _kPurple, fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructor.fullName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${instructor.courseCount} courses',
                  style: const TextStyle(fontSize: 11, color: _kSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Courses ────────────────────────────────────────────────────────────

class _RecentCoursesCard extends StatelessWidget {
  final List<RecentCourse> courses;
  const _RecentCoursesCard({required this.courses});

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
                  color: _kIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: _kIndigo, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Recent Courses',
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
                  MaterialPageRoute(builder: (_) => const AdminCourseScreen()),
                ),
                child: const Text('See all',
                    style: TextStyle(color: _kBlue, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _CourseTile(
              course: courses[i],
              delay: i * 60,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatefulWidget {
  final RecentCourse course;
  final int delay;
  const _CourseTile({required this.course, required this.delay});
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
    _slide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
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
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.course.imageUrl.isNotEmpty
                      ? Image.network(
                          '${ApiResources.apiUrl}${widget.course.imageUrl}',
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
                      Row(
                        children: [
                          _Chip(
                            label: '${widget.course.creditHours} cr',
                            color: _kBlue,
                          ),
                          const SizedBox(width: 6),
                          _Chip(
                            label:
                                '${widget.course.enrolledStudentsCount} enrolled',
                            color: _kGreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: _kSub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoursePlaceholder extends StatelessWidget {
  final String title;
  const _CoursePlaceholder({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      color: _kIndigo.withOpacity(0.1),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : 'C',
          style: const TextStyle(
            color: _kIndigo,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── AppBar Pattern ────────────────────────────────────────────────────────────

class _AppBarPattern extends StatelessWidget {
  const _AppBarPattern();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PatternPainter());
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.5),
        40.0 + i * 25,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Loading / Error ───────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _kBlue),
          SizedBox(height: 16),
          Text('Loading Dashboard…',
              style: TextStyle(color: _kSub, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: _kRed),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kText, fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CustomAppBar_1 extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar_1({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
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
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LogoBrand(),

                const Spacer(),

                _NavLink(
                  label: 'System Logs',
                  icon: Icons.receipt_long_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) =>
                              ActivityLogsCubit(ActivityLogsRepository()),
                          child: const ActivityLogsScreen(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 4),

                _NavLink(
                  label: 'Management',
                  icon: Icons.manage_accounts_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminProfileScreen()),
                    );
                  },
                ),

                const Spacer(),

                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),

                const SizedBox(width: 20),

                FutureBuilder<String?>(
                  future: TokenStorageHelper.getTokenSecure(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    return NotificationBellButton(
                      token: snapshot.data!,
                      role: 'admin',
                    );
                  },
                ),

                const SizedBox(width: 4),

                _AdminAvatar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ── Logo + Brand ─────────────────────────────────────────────

class _LogoBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulsingLogo(),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SkyLearn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D2772),
                letterSpacing: -0.3,
                fontFamily: 'inter',
              ),
            ),
            Text(
              'Admin Portal',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PulsingLogo extends StatefulWidget {
  @override
  State<_PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<_PulsingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: Container(
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
    );
  }
}

// ── Nav link button ──────────────────────────────────────────

class _NavLink extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
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

// ── Icon button with optional badge ─────────────────────────


// ── Admin avatar with dropdown ───────────────────────────────

class _AdminAvatar extends StatefulWidget {
  @override
  State<_AdminAvatar> createState() => _AdminAvatarState();
}

class _AdminAvatarState extends State<_AdminAvatar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminProfileScreen()),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0D2772)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'inter',
                    ),
                  ),
                  Text(
                    'System Administrator',
                    style: TextStyle(
                      fontSize: 9,
                      color: const Color(0xFF94A3B8),
                      fontFamily: 'inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: _hovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
