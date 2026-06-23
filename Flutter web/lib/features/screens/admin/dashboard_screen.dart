// ignore_for_file: avoid_redundant_argument_values, use_key_in_widget_constructors, prefer_const_constructors, unused_element, directives_ordering, unused_field, deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/core/widgets/app_network_image.dart';
import 'package:lms/features/screens/admin/Noti_button.dart';
import 'package:lms/features/screens/admin/admin_profile/state_management/cubit_d_profile.dart';
import 'package:lms/features/screens/admin/admin_profile/state_management/state_d_profile.dart';
import 'package:lms/features/screens/admin/admin_profile/view.dart';
import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart';
import 'package:lms/features/screens/admin/courses/home_courses/view.dart';
import 'package:lms/features/screens/admin/courses/course_details/layout.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/view.dart';
import 'package:lms/features/screens/admin/squadron/create_squadron/view.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/get_all%20squadrons/view.dart';
import 'package:lms/features/screens/admin/users/get_users/view.dart';
import 'package:lms/features/screens/logs/state_mangement/logs_cubit.dart';
import 'package:lms/features/screens/logs/state_mangement/repositery_fetch.dart';
import 'package:lms/features/screens/logs/view/view.dart';
import 'package:lms/generated/assets.dart';

import 'dashboard_cubit.dart';

const _kBg = Color(0xFFF0F4FF);
const _kCard = Colors.white;
const _kBlue = Color(0xFF2563EB);
const _kBlueLight = Color(0xFF53B1FD);
const _kIndigo = Color(0xFF4F46E5);
const _kGreen = Color(0xFF12B76A);
const _kOrange = Color(0xFFF79009);
const _kRed = Color(0xFFF04438);
const _kPurple = Color(0xFF7C3AED);
const _kText = Color(0xFF101828);
const _kSub = Color(0xFF667085);


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



class _DashboardBody extends StatelessWidget {

  const _DashboardBody({required this.stats, required this.overview});
  final DashboardStatsModel stats;
  final DashboardOverviewModel overview;

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
                        child: Column(
                          children: [
                            _TopInstructorsCard(
                              instructors: overview.topInstructors,
                            ),
                            const SizedBox(height: 16),
                            _TopDepartmentsCard(
                              departments: overview.departments,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _DepartmentsCard(departments: overview.departments),
                      const SizedBox(height: 16),
                      _TopInstructorsCard(instructors: overview.topInstructors),
                      const SizedBox(height: 16),
                      _TopDepartmentsCard(departments: overview.departments),
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


// ignore: unused_element
class _QuickNavRow extends StatelessWidget {
  final _items = const [
    _NavItem(label: 'Users', icon: Icons.people_alt_rounded, color: _kBlue, page: GetUsersPage()),
    _NavItem(label: 'Courses', icon: Icons.menu_book_rounded, color: _kGreen, page: AdminCourseScreen()),
    _NavItem(label: 'Departments', icon: Icons.domain_rounded, color: _kOrange, page: DepartmentsScreen()),
    _NavItem(label: 'Squadrons', icon: Icons.flight_rounded, color: _kPurple, page: GetSquadronPage()),
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
  const _NavItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.page,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _NavCard extends StatefulWidget {
  const _NavCard({required this.item});
  final _NavItem item;
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
      lowerBound: 0.92,
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



class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;
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



class _StatsGrid extends StatelessWidget {

  const _StatsGrid({required this.stats, required this.isWide});
  final DashboardStatsModel stats;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
   final items = [
      _StatData(
        'Total Users',
        stats.totalUsers,
        Icons.people_rounded,
        _kBlue,
        const GetUsersPage(),
        'All registered accounts',
      ),
      _StatData(
        'Students',
        stats.totalStudents,
        Icons.school_rounded,
        _kGreen,
        const GetUsersPage(),
        'Active learners enrolled',
      ),
      _StatData(
        'Instructors',
        stats.totalInstructors,
        Icons.person_pin_rounded,
        _kOrange,
        const GetUsersPage(),
        'Teaching staff members',
      ),
      _StatData(
        'Courses',
        stats.totalCourses,
        Icons.menu_book_rounded,
        _kIndigo,
        const AdminCourseScreen(),
        'Published course catalog',
      ),
      _StatData(
        'Departments',
        stats.totalDepartments,
        Icons.domain_rounded,
        _kPurple,
        const DepartmentsScreen(),
        'Academic divisions',
      ),
      _StatData(
        'Squadrons',
        stats.totalSquadrons,
        Icons.flight_takeoff_rounded,
        _kRed,
        const GetSquadronPage(),
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
        childAspectRatio: isWide ? 3.1 : 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _AnimatedStatCard(data: items[i], delay: i * 80),
    );
  }
}

class _StatData { 
  const _StatData(this.label, this.value, this.icon, this.color, this.page, this.subtitle);
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Widget page;
   final String subtitle;
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

    _count = IntTween(
      begin: 0,
      end: widget.data.value,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _iconScale = Tween<double>(
      begin: 0.88,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _slide = Tween<double>(begin: 0, end: 0).animate(_ctrl);
    _opacity = Tween<double>(begin: 1, end: 1).animate(_ctrl);

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

            const SizedBox(height: 3),

            
            Text(
              widget.data.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kText,
              ),
            ),

            const SizedBox(height: 4),

            
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
  const _WeeklyChart({required this.weeklyHours});
  final List<WeeklyHour> weeklyHours;
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
          const Row(
            children: [
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              Spacer(),
              _Legend(color: _kBlue, label: 'Study'),
              SizedBox(width: 12),
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

  const _Bar({
    required this.value,
    required this.max,
    required this.color,
    required this.progress,
  });
  final int value;
  final int max;
  final Color color;
  final double progress;

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
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: _kSub)),
      ],
    );
  }
}

// Departments Card
class _DepartmentsCard extends StatelessWidget {
  const _DepartmentsCard({required this.departments});
  final List<DepartmentOverview> departments;

  @override
  Widget build(BuildContext context) {
    final totalCourses = departments.fold<int>(0, (prev, e) => prev + e.courseCount);

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
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DepartmentsScreen()),
                ),
                child: const Text('See all',
                    style: TextStyle(color: _kBlue, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            // ignore: avoid_redundant_argument_values
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular chart
              SizedBox(
                width: 150,
                height: 150,
                child: _DoughnutChart(
                  departments: departments,
                  totalCourses: totalCourses,
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: departments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dept = entry.value;
                    return LegendItem(
                      color: _getDepartmentColor(index),
                      label: dept.name,
                      value: dept.courseCount,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...departments.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DepartmentRow(dept: d, totalCourses: totalCourses),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDepartmentColor(int index) {
    final colors = [
      _kOrange,
      _kBlue,
      _kGreen,
      _kPurple,
      _kRed,
      _kIndigo,
    ];
    return colors[index % colors.length];
  }
}

class _DoughnutChart extends StatefulWidget {
  const _DoughnutChart({
    required this.departments,
    required this.totalCourses,
  });
  final List<DepartmentOverview> departments;
  final int totalCourses;

  @override
  State<_DoughnutChart> createState() => _DoughnutChartState();
}

class _DoughnutChartState extends State<_DoughnutChart> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _getDepartmentColor(int index) {
    final colors = [
      _kOrange,
      _kBlue,
      _kGreen,
      _kPurple,
      _kRed,
      _kIndigo,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _DoughnutPainter(
          departments: widget.departments,
          totalCourses: widget.totalCourses,
          progress: _anim.value,
          getColor: _getDepartmentColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.totalCourses}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              const Text(
                'Courses',
                style: TextStyle(
                  fontSize: 11,
                  color: _kSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoughnutPainter extends CustomPainter {
  const _DoughnutPainter({
    required this.departments,
    required this.totalCourses,
    required this.progress,
    required this.getColor,
  });
  final List<DepartmentOverview> departments;
  final int totalCourses;
  final double progress;
  final Color Function(int) getColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    double startAngle = -math.pi / 2;

    for (int i = 0; i < departments.length; i++) {
      final dept = departments[i];
      final sweepAngle = (dept.courseCount / (totalCourses == 0 ? 1 : totalCourses)) * 2 * math.pi * progress;
      
      final paint = Paint()
        ..color = getColor(i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      
      startAngle += sweepAngle / progress;
    }
  }

  @override
  bool shouldRepaint(_DoughnutPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.departments != departments;
}

class LegendItem extends StatelessWidget {
  const LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _kText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($value)',
          style: const TextStyle(
            fontSize: 10,
            color: _kSub,
          ),
        ),
      ],
    );
  }
}

class _DepartmentRow extends StatelessWidget {
  const _DepartmentRow({required this.dept, required this.totalCourses});
  final DepartmentOverview dept;
  final int totalCourses;

  @override
  Widget build(BuildContext context) {
    final percentage = totalCourses == 0 ? 0 : ((dept.courseCount / totalCourses) * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Department image/avatar
          AppNetworkImage(
            imageUrl: dept.imageUrl,
            width: 44,
            height: 44,
            fallbackText: dept.name,
            shape: BoxShape.circle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage% of total courses',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kSub,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _kOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${dept.courseCount} courses',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Top Instructors Card
class _TopInstructorsCard extends StatelessWidget {
  const _TopInstructorsCard({required this.instructors});
  final List<TopInstructor> instructors;

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
  const _InstructorTile({required this.instructor, required this.rank});
  final TopInstructor instructor;
  final int rank;

  Color get _medalColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade300;
    }
  }

  IconData get _medalIcon {
    if (rank <= 3) {
      return Icons.emoji_events;
    }
    return Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kBg.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _medalColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Medal
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _medalColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _medalIcon,
                  color: _medalColor,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            AppNetworkImage(
              imageUrl: instructor.profileImageUrl,
              width: 48,
              height: 48,
              fallbackText: instructor.fullName,
              shape: BoxShape.circle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instructor.fullName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#$rank • ${instructor.courseCount} courses',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Top Departments Card
class _TopDepartmentsCard extends StatelessWidget {
  const _TopDepartmentsCard({required this.departments});
  final List<DepartmentOverview> departments;

  @override
  Widget build(BuildContext context) {
    // Sort departments by course count descending
    final sorted = [...departments]..sort((a, b) => b.courseCount.compareTo(a.courseCount));
    final top3 = sorted.take(3).toList();

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
                child: const Icon(Icons.domain_add_outlined,
                    color: _kGreen, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Top Departments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...top3.asMap().entries.map(
                (e) => _TopDepartmentTile(
                  dept: e.value,
                  rank: e.key + 1,
                ),
              ),
        ],
      ),
    );
  }
}

class _TopDepartmentTile extends StatelessWidget {
  const _TopDepartmentTile({required this.dept, required this.rank});
  final DepartmentOverview dept;
  final int rank;

  Color get _medalColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade300;
    }
  }

  IconData get _medalIcon {
    if (rank <= 3) {
      return Icons.emoji_events;
    }
    return Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kBg.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _medalColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Medal
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _medalColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _medalIcon,
                  color: _medalColor,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            AppNetworkImage(
              imageUrl: dept.imageUrl,
              width: 48,
              height: 48,
              fallbackText: dept.name,
              shape: BoxShape.circle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dept.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#$rank • ${dept.courseCount} courses',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _RecentCoursesCard extends StatelessWidget {
  const _RecentCoursesCard({required this.courses});
  final List<RecentCourse> courses;

  @override
  Widget build(BuildContext context) {
    final displayedCourses = courses.take(4).toList();

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
            itemCount: displayedCourses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _CourseTile(
              course: displayedCourses[i],
              delay: i * 60,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatefulWidget {
  const _CourseTile({required this.course, required this.delay});
  final RecentCourse course;
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

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final courseDate = widget.course.createdAt ?? DateTime.now().subtract(Duration(days: (widget.course.id * 7) % 30 + 1));

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(_slide.value, 0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseLayout(
                    courseModel: GetCoursesModel(
                      id: widget.course.id,
                      title: widget.course.title,
                      description: '',
                      departmentId: 0,
                      departmentName: widget.course.departmentName,
                      yearId: 0,
                      yearName: '',
                      creditHours: widget.course.creditHours,
                      enrolledStudentsCount: widget.course.enrolledStudentsCount,
                      imageUrl: widget.course.imageUrl,
                      instructorId: 0,
                      instructorName: widget.course.instructorName,
                      createdAt: courseDate,
                      lecturesCount: 0,
                      quizzesCount: 0,
                      assignmentsCount: 0,
                    ),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  // Thumbnail using AppNetworkImage
                  AppNetworkImage(
                    imageUrl: widget.course.imageUrl,
                    width: 54,
                    height: 54,
                    borderRadius: BorderRadius.circular(10),
                    fallbackText: widget.course.title,
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
                              label: '${widget.course.enrolledStudentsCount} enrolled',
                              color: _kGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(courseDate),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: _kSub),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;
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
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
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
    return BlocProvider(
      create: (_) => AdminProfileCubit()..getProfile(),
      child: Container(
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
                        MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
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
      ),
    );
  }
}


class _LogoBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulsingLogo(),
        const SizedBox(width: 10),
        const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SkyLearn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D2772),
                letterSpacing: -0.3,
                fontFamily: 'inter',
              ),
            ),
            Text(
              'Admin Portal',
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



class _NavLink extends StatefulWidget {

  const _NavLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

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


class _AdminAvatar extends StatelessWidget {
  const _AdminAvatar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminProfileCubit, AdminProfileState>(
      builder: (context, state) {
        String? profileImageUrl;
        String? fullName;

        if (state is AdminProfileLoaded) {
          profileImageUrl = state.profile.user.profileImageUrl;
          fullName = state.profile.user.fullName;
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppNetworkImage(
                    imageUrl: profileImageUrl,
                    width: 26,
                    height: 26,
                    fallbackText: fullName ?? 'Admin',
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName ?? 'Admin',
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
                        'System Administrator',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF94A3B8),
                          fontFamily: 'inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
