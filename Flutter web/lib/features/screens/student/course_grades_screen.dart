// ============================================================
// course_grades_screen.dart
// ============================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'student_activities_grades_cubits.dart';
import 'student_activities_grades_models.dart';
import 'student_activities_grades_states.dart';

// ── Palette ───────────────────────────────────────────────────
const _kBg = Color(0xFFF0F6FF);
const _kCard = Colors.white;
const _kBlue = Color(0xFF2563EB);
const _kBlueLight = Color(0xFFEFF6FF);
const _kGreen = Color(0xFF10B981);
const _kOrange = Color(0xFFF59E0B);
const _kRed = Color(0xFFEF4444);
const _kPurple = Color(0xFF7C3AED);
const _kText = Color(0xFF0F172A);
const _kSub = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

// ── Entry ─────────────────────────────────────────────────────
class CourseGradesScreen extends StatelessWidget {
  final int courseId;
  final String courseName;
  const CourseGradesScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseGradesCubit()..loadGrades(courseId),
      child: _GradesBody(courseName: courseName, courseId: courseId),
    );
  }
}

class _GradesBody extends StatelessWidget {
  final String courseName;
  final int courseId;
  const _GradesBody({required this.courseName, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kText,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseName,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _kText),
            ),
            const Text(
              'My Grades',
              style: TextStyle(fontSize: 11, color: _kSub),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<CourseGradesCubit>().loadGrades(courseId),
            icon: const Icon(Icons.refresh_rounded, color: _kSub),
          ),
        ],
      ),
      body: BlocBuilder<CourseGradesCubit, CourseGradesState>(
        builder: (ctx, state) {
          if (state is CourseGradesLoading) {
            return const Center(
                child: CircularProgressIndicator(color: _kBlue));
          }
          if (state is CourseGradesError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => ctx.read<CourseGradesCubit>().loadGrades(courseId),
            );
          }
          if (state is CourseGradesLoaded) {
            return _GradesContent(state: state);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ── Main Content ──────────────────────────────────────────────
class _GradesContent extends StatelessWidget {
  final CourseGradesLoaded state;
  const _GradesContent({required this.state});

  static const _tabs = ['Overview', 'Quizzes', 'Assignments'];

  @override
  Widget build(BuildContext context) {
    final g = state.grades;
    return Column(
      children: [
        // ── Overview Hero ──────────────────────────────────────
        _GradeHero(grades: g),

        // ── Tab Bar ───────────────────────────────────────────
        Container(
          color: Colors.white,
          child: Row(
            children: _tabs.asMap().entries.map((e) {
              final selected = state.activeTab == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<CourseGradesCubit>()
                      .switchTab(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected ? _kBlue : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      e.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? _kBlue : _kSub,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1, color: _kBorder),

        // ── Tab Content ───────────────────────────────────────
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: state.activeTab == 0
                ? _OverviewTab(grades: g, key: const ValueKey('overview'))
                : state.activeTab == 1
                    ? _QuizzesTab(
                        quizzes: g.quizGrades, key: const ValueKey('quizzes'))
                    : _AssignmentsTab(
                        assignments: g.assignmentGrades,
                        key: const ValueKey('assignments')),
          ),
        ),
      ],
    );
  }
}

// ── Grade Hero ────────────────────────────────────────────────
class _GradeHero extends StatefulWidget {
  final CourseGrades grades;
  const _GradeHero({required this.grades});
  @override
  State<_GradeHero> createState() => _GradeHeroState();
}

class _GradeHeroState extends State<_GradeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _gradeColor {
    final avg = widget.grades.overallAverage;
    if (avg >= 80) return _kGreen;
    if (avg >= 60) return _kOrange;
    return _kRed;
  }

  String get _gradeLabel {
    final avg = widget.grades.overallAverage;
    if (avg >= 90) return 'Excellent';
    if (avg >= 80) return 'Very Good';
    if (avg >= 70) return 'Good';
    if (avg >= 60) return 'Pass';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.grades;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          // Donut gauge
          SizedBox(
            width: 110,
            height: 110,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                painter: _GaugeRingPainter(
                  progress: g.overallAverage / 100,
                  animValue: _anim.value,
                  color: _gradeColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(g.overallAverage * _anim.value).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _gradeColor,
                          height: 1,
                        ),
                      ),
                      Text(
                        _gradeLabel,
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _kSub),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroStatRow(
                  icon: Icons.quiz_rounded,
                  color: _kPurple,
                  label: 'Quiz Avg',
                  value: '${g.quizAverage.toStringAsFixed(1)}%',
                  sub: '${g.quizGrades.length} quizzes',
                ),
                const SizedBox(height: 10),
                _HeroStatRow(
                  icon: Icons.assignment_rounded,
                  color: _kBlue,
                  label: 'Assignment Avg',
                  value: '${g.assignmentAverage.toStringAsFixed(1)}%',
                  sub: '${g.assignmentGrades.length} assignments',
                ),
                const SizedBox(height: 10),
                // Mini comparison bar
                _ComparisonBar(
                  quizAvg: g.quizAverage,
                  assignAvg: g.assignmentAverage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String sub;
  const _HeroStatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: _kSub)),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color)),
                const SizedBox(width: 6),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 10, color: _kSub)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  final double quizAvg;
  final double assignAvg;
  const _ComparisonBar(
      {required this.quizAvg, required this.assignAvg});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quiz vs Assignment',
            style: TextStyle(fontSize: 10, color: _kSub)),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (_, c) => Stack(
            children: [
              Container(
                height: 8,
                width: c.maxWidth,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: c.maxWidth * (quizAvg / 100).clamp(0, 1),
                decoration: BoxDecoration(
                  color: _kPurple.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: c.maxWidth * (assignAvg / 100).clamp(0, 1) * 0.5,
                margin: EdgeInsets.only(
                    left: c.maxWidth *
                        (quizAvg / 100).clamp(0, 1) *
                        0.5),
                decoration: BoxDecoration(
                  color: _kBlue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _LegendDot(color: _kPurple, label: 'Quizzes'),
            const SizedBox(width: 12),
            _LegendDot(color: _kBlue, label: 'Assignments'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 9, color: _kSub)),
        ],
      );
}

// ── Gauge Ring Painter ────────────────────────────────────────
class _GaugeRingPainter extends CustomPainter {
  final double progress;
  final double animValue;
  final Color color;
  const _GaugeRingPainter({
    required this.progress,
    required this.animValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 8;
    const sw = 10.0;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = _kBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * progress * animValue,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeRingPainter old) =>
      old.animValue != animValue || old.progress != progress;
}

// ── Overview Tab ──────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final CourseGrades grades;
  const _OverviewTab({required this.grades, super.key});

  @override
  Widget build(BuildContext context) {
    final all = [
      ...grades.quizGrades
          .map((q) => _GradeEntry(
                title: q.quizTitle,
                type: 'Quiz',
                percent: q.percent,
                score: q.score,
                maxScore: q.maxScore,
                passed: q.passed,
                date: q.submittedAt,
              )),
      ...grades.assignmentGrades
          .map((a) => _GradeEntry(
                title: a.assignmentTitle,
                type: 'Assignment',
                percent: a.percent,
                score: a.score,
                maxScore: a.maxScore,
                passed: a.status == 'Graded' || a.percent >= 60,
                date: a.submittedAt,
                feedback: a.feedback,
              )),
    ];
    all.sort((a, b) => b.percent.compareTo(a.percent));

    if (all.isEmpty) {
      return const _EmptyGrades(message: 'No grades yet for this course');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GradeDistributionChart(entries: all),
        const SizedBox(height: 16),
        ...all.asMap().entries.map(
              (e) => _GradeItemCard(entry: e.value, index: e.key),
            ),
      ],
    );
  }
}

// ── Quizzes Tab ───────────────────────────────────────────────
class _QuizzesTab extends StatelessWidget {
  final List<QuizGradeItem> quizzes;
  const _QuizzesTab({required this.quizzes, super.key});

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return const _EmptyGrades(message: 'No quiz grades yet');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _QuizBarChart(quizzes: quizzes),
        const SizedBox(height: 16),
        ...quizzes.asMap().entries.map(
              (e) => _GradeItemCard(
                entry: _GradeEntry(
                  title: e.value.quizTitle,
                  type: 'Quiz',
                  percent: e.value.percent,
                  score: e.value.score,
                  maxScore: e.value.maxScore,
                  passed: e.value.passed,
                  date: e.value.submittedAt,
                ),
                index: e.key,
              ),
            ),
      ],
    );
  }
}

// ── Assignments Tab ───────────────────────────────────────────
class _AssignmentsTab extends StatelessWidget {
  final List<AssignmentGradeItem> assignments;
  const _AssignmentsTab({required this.assignments, super.key});

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const _EmptyGrades(message: 'No assignment grades yet');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...assignments.asMap().entries.map(
              (e) => _GradeItemCard(
                entry: _GradeEntry(
                  title: e.value.assignmentTitle,
                  type: 'Assignment',
                  percent: e.value.percent,
                  score: e.value.score,
                  maxScore: e.value.maxScore,
                  passed: e.value.percent >= 60,
                  date: e.value.submittedAt,
                  feedback: e.value.feedback,
                ),
                index: e.key,
              ),
            ),
      ],
    );
  }
}

// ── Grade Entry ───────────────────────────────────────────────
class _GradeEntry {
  final String title;
  final String type;
  final double percent;
  final double score;
  final double maxScore;
  final bool passed;
  final String? date;
  final String? feedback;

  const _GradeEntry({
    required this.title,
    required this.type,
    required this.percent,
    required this.score,
    required this.maxScore,
    required this.passed,
    this.date,
    this.feedback,
  });
}

// ── Grade Distribution Chart ──────────────────────────────────
class _GradeDistributionChart extends StatefulWidget {
  final List<_GradeEntry> entries;
  const _GradeDistributionChart({required this.entries});
  @override
  State<_GradeDistributionChart> createState() =>
      _GradeDistributionChartState();
}

class _GradeDistributionChartState extends State<_GradeDistributionChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
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
    final excellent =
        widget.entries.where((e) => e.percent >= 90).length;
    final good = widget.entries
        .where((e) => e.percent >= 70 && e.percent < 90)
        .length;
    final pass = widget.entries
        .where((e) => e.percent >= 60 && e.percent < 70)
        .length;
    final fail = widget.entries.where((e) => e.percent < 60).length;
    final total = widget.entries.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: _kBlue, size: 16),
              SizedBox(width: 8),
              Text('Grade Distribution',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kText)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _DistBar(
                  label: 'Excellent',
                  count: excellent,
                  total: total,
                  color: _kGreen,
                  anim: _anim),
              const SizedBox(width: 8),
              _DistBar(
                  label: 'Good',
                  count: good,
                  total: total,
                  color: _kBlue,
                  anim: _anim),
              const SizedBox(width: 8),
              _DistBar(
                  label: 'Pass',
                  count: pass,
                  total: total,
                  color: _kOrange,
                  anim: _anim),
              const SizedBox(width: 8),
              _DistBar(
                  label: 'Fail',
                  count: fail,
                  total: total,
                  color: _kRed,
                  anim: _anim),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final Animation<double> anim;
  const _DistBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    final frac = total > 0 ? count / total : 0.0;
    return Expanded(
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: anim,
            builder: (_, __) => Container(
              height: 60,
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: (frac * anim.value).clamp(0.05, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.3), blurRadius: 6)
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 9, color: _kSub),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Quiz Bar Chart ────────────────────────────────────────────
class _QuizBarChart extends StatefulWidget {
  final List<QuizGradeItem> quizzes;
  const _QuizBarChart({required this.quizzes});
  @override
  State<_QuizBarChart> createState() => _QuizBarChartState();
}

class _QuizBarChartState extends State<_QuizBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, color: _kPurple, size: 16),
              SizedBox(width: 8),
              Text('Quiz Performance',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kText)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: _QuizBarPainter(
                    quizzes: widget.quizzes, progress: _anim.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizBarPainter extends CustomPainter {
  final List<QuizGradeItem> quizzes;
  final double progress;
  const _QuizBarPainter({required this.quizzes, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (quizzes.isEmpty) return;
    final barW = (size.width / quizzes.length) * 0.55;
    final gap = (size.width / quizzes.length) * 0.45;
    final h = size.height - 16;

    for (int i = 0; i < quizzes.length; i++) {
      final x = i * (barW + gap) + gap / 2;
      final pct = quizzes[i].percent / 100;
      final barH = pct * h * progress;
      final color = pct >= 0.8
          ? _kGreen
          : pct >= 0.6
              ? _kOrange
              : _kRed;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h - barH, barW, barH),
          const Radius.circular(4),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withOpacity(0.6)],
          ).createShader(Rect.fromLTWH(x, h - barH, barW, barH)),
      );

      // Passing line at 60%
      final passY = h - (0.6 * h);
      canvas.drawLine(
        Offset(0, passY),
        Offset(size.width, passY),
        Paint()
          ..color = _kRed.withOpacity(0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );

      final label = quizzes[i].quizTitle.length > 5
          ? quizzes[i].quizTitle.substring(0, 5)
          : quizzes[i].quizTitle;
      final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 8, color: _kSub)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, h + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _QuizBarPainter old) =>
      old.progress != progress;
}

// ── Grade Item Card ───────────────────────────────────────────
class _GradeItemCard extends StatefulWidget {
  final _GradeEntry entry;
  final int index;
  const _GradeItemCard({required this.entry, required this.index});
  @override
  State<_GradeItemCard> createState() => _GradeItemCardState();
}

class _GradeItemCardState extends State<_GradeItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide, _opacity;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<double>(begin: 20, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _opacity = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    Future.delayed(
        Duration(milliseconds: (widget.index * 60).clamp(0, 300)), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _typeColor =>
      widget.entry.type == 'Quiz' ? _kPurple : _kBlue;
  IconData get _typeIcon => widget.entry.type == 'Quiz'
      ? Icons.quiz_rounded
      : Icons.assignment_rounded;

  Color get _gradeColor {
    if (widget.entry.percent >= 80) return _kGreen;
    if (widget.entry.percent >= 60) return _kOrange;
    return _kRed;
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
                boxShadow: [
                  BoxShadow(
                    color: _typeColor.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Type icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_typeIcon,
                              color: _typeColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _kText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _typeColor.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      e.type,
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: _typeColor),
                                    ),
                                  ),
                                  if (e.date != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(e.date!),
                                      style: const TextStyle(
                                          fontSize: 10, color: _kSub),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Score circle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _gradeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${e.percent.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: _gradeColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (e.passed ? _kGreen : _kRed)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                e.passed ? '✓ Pass' : '✗ Fail',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: e.passed ? _kGreen : _kRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Score bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    child: _ScoreProgressBar(
                        percent: e.percent / 100, color: _gradeColor),
                  ),
                  // Expanded feedback
                  if (_expanded && e.feedback != null && e.feedback!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.feedback_rounded,
                              size: 14, color: _kSub),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.feedback!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: _kSub,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (e.feedback != null && e.feedback!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: _kSub,
                          ),
                          Text(
                            _expanded ? 'Hide feedback' : 'View feedback',
                            style: const TextStyle(
                                fontSize: 10, color: _kSub),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Animated Score Bar ────────────────────────────────────────
class _ScoreProgressBar extends StatefulWidget {
  final double percent;
  final Color color;
  const _ScoreProgressBar({required this.percent, required this.color});
  @override
  State<_ScoreProgressBar> createState() => _ScoreProgressBarState();
}

class _ScoreProgressBarState extends State<_ScoreProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.percent.clamp(0, 1))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => Stack(
        children: [
          Container(
            height: 5,
            width: c.maxWidth,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Passing threshold marker
          Positioned(
            left: c.maxWidth * 0.6 - 1,
            child: Container(width: 2, height: 5, color: _kRed.withOpacity(0.4)),
          ),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              height: 5,
              width: c.maxWidth * _anim.value,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.color, widget.color.withOpacity(0.6)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty & Error ─────────────────────────────────────────────
class _EmptyGrades extends StatelessWidget {
  final String message;
  const _EmptyGrades({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.grade_rounded,
                size: 36, color: _kBlue),
          ),
          const SizedBox(height: 14),
          Text(message,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kSub),
              textAlign: TextAlign.center),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: _kRed),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: _kSub),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
