import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/student/dashboard_Appbar.dart';
import 'package:lms/features/screens/student_dashboard_states.dart';
import 'package:lms/features/screens/student/student_courses/view.dart';
import 'student_dashboard_cubit.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBg = Color(0xFFF0F6FF);
const _kCard = Colors.white;
const _kBlue = Color(0xFF2563EB);
const _kBlueDeep = Color(0xFF0D2772);
const _kBlueSoft = Color(0xFFEFF6FF);
const _kGreen = Color(0xFF10B981);
const _kOrange = Color(0xFFF59E0B);
const _kPurple = Color(0xFF7C3AED);
const _kRed = Color(0xFFEF4444);
const _kText = Color(0xFF0F172A);
const _kSub = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

// ── Entry ─────────────────────────────────────────────────────────────────────

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentDashboardCubit()..loadDashboard(),
      child: const _StudentDashboardView(),
    );
  }
}

class _StudentDashboardView extends StatefulWidget {
  const _StudentDashboardView();
  @override
  State<_StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends State<_StudentDashboardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
      appBar: StudentDashboardAppBar(
        onNavigateToGrades: () {
          // Grades are scoped per-course, so send the student to pick a
          // course first; that screen is responsible for opening
          // CourseGradesScreen(courseId, courseName) once one is selected.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentCourseScreen()),
          );
        },
      ),
      body: BlocConsumer<StudentDashboardCubit, StudentDashboardState>(
        listener: (_, state) {
          if (state is StudentDashboardLoaded) _fadeCtrl.forward(from: 0);
        },
        builder: (context, state) {
          if (state is StudentDashboardLoading ||
              state is StudentDashboardInitial) {
            return const _LoadingView();
          }
          if (state is StudentDashboardError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<StudentDashboardCubit>().loadDashboard(),
            );
          }
          if (state is StudentDashboardLoaded) {
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

// ── Body ──────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  final StudentDashboardModel model;
  const _DashboardBody({required this.model});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w > 800;
    final p = isWide ? 24.0 : 16.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero row: GPA card + Ongoing Courses ──
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 220, child: _GpaHeroCard(model: model)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _OngoingCoursesCard(
                        courses: model.enrolledCourses,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _GpaHeroCard(model: model),
                    const SizedBox(height: 16),
                    _OngoingCoursesCard(courses: model.enrolledCourses),
                  ],
                ),

          const SizedBox(height: 20),

          // ── Stats row ──
          _StatsRow(model: model, isWide: isWide),

          const SizedBox(height: 20),

          // ── Charts row ──
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _LineChartCard(points: model.progressOverTime),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _BarChartCard(grades: model.gradesPerCourse),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _LineChartCard(points: model.progressOverTime),
                    const SizedBox(height: 16),
                    _BarChartCard(grades: model.gradesPerCourse),
                  ],
                ),

          const SizedBox(height: 20),

          // ── Bottom row ──
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _CompletionDonutCard(
                        status: model.completionStatus,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _DeadlinesCard(deadlines: model.upcomingDeadlines),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _CompletionDonutCard(status: model.completionStatus),
                    const SizedBox(height: 16),
                    _DeadlinesCard(deadlines: model.upcomingDeadlines),
                  ],
                ),

          if (model.achievements.isNotEmpty) ...[
            const SizedBox(height: 20),
            _AchievementsCard(achievements: model.achievements),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── GPA Hero Card ─────────────────────────────────────────────────────────────

class _GpaHeroCard extends StatefulWidget {
  final StudentDashboardModel model;
  const _GpaHeroCard({required this.model});
  @override
  State<_GpaHeroCard> createState() => _GpaHeroCardState();
}

class _GpaHeroCardState extends State<_GpaHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _gpa;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _gpa = Tween<double>(
      begin: 0,
      end: widget.model.overallGpa,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF0D2772)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kBlue.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Overall GPA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _gpa,
            builder: (_, __) => Text(
              _gpa.value.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MiniStat(
            label: 'Credits',
            value: '${widget.model.creditHours}h',
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          _MiniStat(
            label: 'Completed',
            value: '${widget.model.coursesCompleted}',
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          _MiniStat(
            label: 'Attendance',
            value: '${widget.model.attendanceRate.toStringAsFixed(0)}%',
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Ongoing Courses ───────────────────────────────────────────────────────────

class _OngoingCoursesCard extends StatelessWidget {
  final List<EnrolledCourse> courses;
  const _OngoingCoursesCard({required this.courses});

  static const _colors = [
    _kBlue,
    Color(0xFFEC4899),
    _kGreen,
    _kOrange,
    _kPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Ongoing Courses',
      icon: Icons.play_circle_outline_rounded,
      iconColor: _kBlue,
      child: courses.isEmpty
          ? const _EmptyState(message: 'No courses enrolled yet')
          : Column(
              children: courses.asMap().entries.map((e) {
                final color = _colors[e.key % _colors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CourseProgressRow(
                    course: e.value,
                    color: color,
                    delay: e.key * 100,
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _CourseProgressRow extends StatefulWidget {
  final EnrolledCourse course;
  final Color color;
  final int delay;
  const _CourseProgressRow({
    required this.course,
    required this.color,
    required this.delay,
  });
  @override
  State<_CourseProgressRow> createState() => _CourseProgressRowState();
}

class _CourseProgressRowState extends State<_CourseProgressRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _width = Tween<double>(
      begin: 0,
      end: (widget.course.progressPercent / 100).clamp(0.0, 1.0),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.course.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${widget.course.progressPercent.toStringAsFixed(0)}/100',
              style: const TextStyle(
                fontSize: 12,
                color: _kSub,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (_, c) => Stack(
            children: [
              Container(
                height: 7,
                width: c.maxWidth,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedBuilder(
                animation: _width,
                builder: (_, __) => Container(
                  height: 7,
                  width: c.maxWidth * _width.value,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
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

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final StudentDashboardModel model;
  final bool isWide;
  const _StatsRow({required this.model, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        'Avg Grade',
        '${model.averageGrade.toStringAsFixed(0)}%',
        Icons.grade_rounded,
        _kBlue,
      ),
      _StatItem(
        'Assignments',
        '${model.assignmentsCompleted}/${model.assignmentsTotal}',
        Icons.assignment_turned_in_rounded,
        _kGreen,
      ),
      _StatItem(
        'Progress',
        '${model.courseProgressPercent.toStringAsFixed(0)}%',
        Icons.trending_up_rounded,
        _kOrange,
      ),
      _StatItem(
        'Attendance',
        '${model.attendanceRate.toStringAsFixed(0)}%',
        Icons.event_available_rounded,
        _kPurple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 2.0 : 1.9,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _AnimatedStatCard(item: items[i], delay: i * 80),
    );
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _AnimatedStatCard extends StatefulWidget {
  final _StatItem item;
  final int delay;
  const _AnimatedStatCard({required this.item, required this.delay});
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
      duration: const Duration(milliseconds: 1400),
    );
    _iconScale = Tween<double>(
      begin: 0.88,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: widget.item.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: widget.item.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.item.icon,
                      color: widget.item.color,
                      size: 17,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                size: 16,
                color: _kSub.withOpacity(0.4),
              ),
            ],
          ),
          const Spacer(),
          Text(
            widget.item.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: widget.item.color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.item.label,
            style: const TextStyle(
              fontSize: 11,
              color: _kSub,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Line Chart ────────────────────────────────────────────────────────────────

class _LineChartCard extends StatefulWidget {
  final List<ProgressPoint> points;
  const _LineChartCard({required this.points});
  @override
  State<_LineChartCard> createState() => _LineChartCardState();
}

class _LineChartCardState extends State<_LineChartCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  int _selected = 2; // Last Month default

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Progress Over Time',
      icon: Icons.show_chart_rounded,
      iconColor: _kBlue,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterChip(
            label: 'Last 24h',
            selected: _selected == 0,
            onTap: () => setState(() {
              _selected = 0;
              _ctrl.forward(from: 0);
            }),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Last Week',
            selected: _selected == 1,
            onTap: () => setState(() {
              _selected = 1;
              _ctrl.forward(from: 0);
            }),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Last Month',
            selected: _selected == 2,
            onTap: () => setState(() {
              _selected = 2;
              _ctrl.forward(from: 0);
            }),
          ),
        ],
      ),
      child: SizedBox(
        height: 180,
        child: widget.points.isEmpty
            ? const _EmptyState(message: 'No progress data yet')
            : AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => CustomPaint(
                  size: Size.infinite,
                  painter: _LineChartPainter(
                    points: widget.points,
                    progress: _anim.value,
                  ),
                ),
              ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ProgressPoint> points;
  final double progress;
  const _LineChartPainter({required this.points, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxY = points.fold<double>(
      1,
      (p, e) => math.max(p, math.max(e.yourProgress, e.classAverage)),
    );
    final w = size.width;
    final h = size.height - 24;
    final step = w / (points.length - 1).clamp(1, 100);

    Offset p(int i, double v) =>
        Offset(i * step, h - (v / maxY) * h * progress);

    void drawLine(
      List<ProgressPoint> pts,
      Color color,
      double Function(ProgressPoint) val,
    ) {
      final path = Path();
      final fill = Path();
      for (int i = 0; i < pts.length; i++) {
        final o = p(i, val(pts[i]));
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
          fill.moveTo(o.dx, h);
          fill.lineTo(o.dx, o.dy);
        } else {
          final prev = p(i - 1, val(pts[i - 1]));
          final cp1 = Offset((prev.dx + o.dx) / 2, prev.dy);
          final cp2 = Offset((prev.dx + o.dx) / 2, o.dy);
          path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, o.dx, o.dy);
          fill.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, o.dx, o.dy);
        }
      }
      fill.lineTo((pts.length - 1) * step, h);
      fill.close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      for (int i = 0; i < pts.length; i++) {
        final o = p(i, val(pts[i]));
        canvas.drawCircle(o, 4, Paint()..color = color);
        canvas.drawCircle(
          o,
          4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = h * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(w, y),
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..strokeWidth = 1,
      );
      final label = ((1 - i / 4) * maxY).toStringAsFixed(0);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 9, color: _kSub),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 10));
    }

    drawLine(points, _kBlue, (p) => p.yourProgress);
    drawLine(points, const Color(0xFFEC4899), (p) => p.classAverage);

    // X labels
    for (int i = 0; i < points.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: points[i].week,
          style: const TextStyle(fontSize: 9, color: _kSub),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(i * step - tp.width / 2, h + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.progress != progress;
}

// ── Bar Chart (Grades) ────────────────────────────────────────────────────────

class _BarChartCard extends StatefulWidget {
  final List<GradePerCourse> grades;
  const _BarChartCard({required this.grades});
  @override
  State<_BarChartCard> createState() => _BarChartCardState();
}

class _BarChartCardState extends State<_BarChartCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avg = widget.grades.isEmpty
        ? 0.0
        : widget.grades.fold(0.0, (s, e) => s + e.grade) / widget.grades.length;

    return _Card(
      title: 'Student Performance',
      icon: Icons.bar_chart_rounded,
      iconColor: _kPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Average Grades',
            style: TextStyle(fontSize: 12, color: _kSub),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${avg.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '+3.2% Vs Last Year',
                  style: TextStyle(
                    fontSize: 10,
                    color: _kGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: widget.grades.isEmpty
                ? const _EmptyState(message: 'No grade data yet')
                : AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => CustomPaint(
                      size: Size.infinite,
                      painter: _BarChartPainter(
                        grades: widget.grades,
                        progress: _anim.value,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<GradePerCourse> grades;
  final double progress;
  const _BarChartPainter({required this.grades, required this.progress});

  static const _colors = [
    _kBlue,
    Color(0xFF60A5FA),
    Color(0xFF93C5FD),
    Color(0xFFBFDBFE),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (grades.isEmpty) return;
    final maxVal = grades.fold<double>(1, (p, e) => math.max(p, e.grade));
    final barW = (size.width / grades.length) * 0.5;
    final gap = (size.width / grades.length) * 0.5;
    final h = size.height - 20;

    for (int i = 0; i < grades.length; i++) {
      final x = i * (barW + gap) + gap / 2;
      final barH = (grades[i].grade / maxVal) * h * progress;
      final color = _colors[i % _colors.length];

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, h - barH, barW, barH),
        const Radius.circular(6),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withOpacity(0.6)],
          ).createShader(Rect.fromLTWH(x, h - barH, barW, barH)),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: grades[i].courseName.length > 6
              ? grades[i].courseName.substring(0, 6)
              : grades[i].courseName,
          style: const TextStyle(fontSize: 9, color: _kSub),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, h + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.progress != progress;
}

// ── Completion Donut ──────────────────────────────────────────────────────────

class _CompletionDonutCard extends StatefulWidget {
  final CompletionStatus status;
  const _CompletionDonutCard({required this.status});
  @override
  State<_CompletionDonutCard> createState() => _CompletionDonutCardState();
}

class _CompletionDonutCardState extends State<_CompletionDonutCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total =
        (widget.status.completed +
                widget.status.inProgress +
                widget.status.notStarted)
            .clamp(1, 9999);

    return _Card(
      title: 'Course Completion',
      icon: Icons.donut_large_rounded,
      iconColor: _kGreen,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: _DonutPainter(
                  completed: widget.status.completed / total,
                  inProgress: widget.status.inProgress / total,
                  notStarted: widget.status.notStarted / total,
                  progress: _anim.value,
                  total: total,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DonutLegend(
                color: _kGreen,
                label: 'Completed',
                value: widget.status.completed,
              ),
              _DonutLegend(
                color: _kOrange,
                label: 'In Progress',
                value: widget.status.inProgress,
              ),
              _DonutLegend(
                color: _kBorder,
                label: 'Not Started',
                value: widget.status.notStarted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double completed, inProgress, notStarted, progress;
  final int total;
  const _DonutPainter({
    required this.completed,
    required this.inProgress,
    required this.notStarted,
    required this.progress,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 10;
    const sw = 22.0;
    const start = -math.pi / 2;

    void arc(double sweep, Color color) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start + (2 * math.pi * (1 - sweep) * progress), // offset for animation
        sweep * 2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFFF1F5F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    double offset = 0;
    void arcOffset(double frac, Color color) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start + offset * 2 * math.pi,
        frac * 2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
      offset += frac;
    }

    arcOffset(completed, _kGreen);
    arcOffset(inProgress, _kOrange);
    arcOffset(notStarted, _kBorder);

    // Center text
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$total\n',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kText,
              height: 1.1,
            ),
          ),
          const TextSpan(
            text: 'Courses',
            style: TextStyle(fontSize: 11, color: _kSub),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: r * 1.2);
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}

class _DonutLegend extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _DonutLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _kText,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: _kSub)),
      ],
    );
  }
}

// ── Deadlines ─────────────────────────────────────────────────────────────────

class _DeadlinesCard extends StatelessWidget {
  final List<UpcomingDeadline> deadlines;
  const _DeadlinesCard({required this.deadlines});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Upcoming Deadlines',
      icon: Icons.schedule_rounded,
      iconColor: _kRed,
      child: deadlines.isEmpty
          ? const _EmptyState(message: 'No upcoming deadlines 🎉')
          : Column(
              children: deadlines
                  .asMap()
                  .entries
                  .map(
                    (e) => _DeadlineTile(deadline: e.value, delay: e.key * 80),
                  )
                  .toList(),
            ),
    );
  }
}

class _DeadlineTile extends StatefulWidget {
  final UpcomingDeadline deadline;
  final int delay;
  const _DeadlineTile({required this.deadline, required this.delay});
  @override
  State<_DeadlineTile> createState() => _DeadlineTileState();
}

class _DeadlineTileState extends State<_DeadlineTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide, _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<double>(
      begin: 20,
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(_slide.value, 0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kRed.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kRed.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_rounded,
                    color: _kRed,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.deadline.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.deadline.courseTitle,
                        style: const TextStyle(fontSize: 11, color: _kSub),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.deadline.dueDate,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _kRed,
                      fontWeight: FontWeight.w600,
                    ),
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

// ── Achievements ──────────────────────────────────────────────────────────────

class _AchievementsCard extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementsCard({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Achievements',
      icon: Icons.emoji_events_rounded,
      iconColor: _kOrange,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: achievements
            .map((a) => _AchievementChip(achievement: a))
            .toList(),
      ),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  final Achievement achievement;
  const _AchievementChip({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: achievement.description,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _kOrange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kOrange.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.icon.isEmpty ? '🏆' : achievement.icon,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Card ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? trailing;

  const _Card({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? _kBlue : _kBlueSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _kSub,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: _kSub, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Loading / Error ───────────────────────────────────────────────────────────

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
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
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
