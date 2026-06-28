// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:lms/features/screens/admin/dashboard_cubit.dart';

const _kBg = Color(0xFFF0F4FF);
const _kCard = Colors.white;
const _kBlue = Color(0xFF2563EB);
const _kGreen = Color(0xFF12B76A);
const _kOrange = Color(0xFFF79009);
const _kRed = Color(0xFFF04438);
const _kPurple = Color(0xFF7C3AED);
const _kText = Color(0xFF101828);
const _kSub = Color(0xFF667085);

class DashboardAnalyticsSection extends StatelessWidget {
  const DashboardAnalyticsSection({super.key, required this.analytics});

  final AdminAnalyticsModel analytics;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w > 900;

    if (analytics.kpis.isEmpty && analytics.platformHealth.platformHealthScore == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Data Science Analytics', icon: Icons.analytics_rounded, color: _kPurple),
        const SizedBox(height: 16),
        _PlatformHealthCard(health: analytics.platformHealth),
        const SizedBox(height: 16),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _AtRiskCard(students: analytics.atRiskStudents)),
                  const SizedBox(width: 16),
                  Expanded(child: _AlertsCard(alerts: analytics.systemAlerts)),
                ],
              )
            : Column(
                children: [
                  _AtRiskCard(students: analytics.atRiskStudents),
                  const SizedBox(height: 16),
                  _AlertsCard(alerts: analytics.systemAlerts),
                ],
              ),
        const SizedBox(height: 16),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _CourseRankingCard(title: 'Top Popular Courses', courses: analytics.topPopularCourses, color: _kBlue)),
                  const SizedBox(width: 16),
                  Expanded(child: _CourseRankingCard(title: 'Top Hardest Courses', courses: analytics.topHardestCourses, color: _kRed)),
                ],
              )
            : Column(
                children: [
                  _CourseRankingCard(title: 'Top Popular Courses', courses: analytics.topPopularCourses, color: _kBlue),
                  const SizedBox(height: 16),
                  _CourseRankingCard(title: 'Top Hardest Courses', courses: analytics.topHardestCourses, color: _kRed),
                ],
              ),
        const SizedBox(height: 16),
        _DepartmentComparisonCard(departments: analytics.departmentComparison),
        const SizedBox(height: 16),
        _LearningFunnelCard(funnel: analytics.learningFunnel),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon, required this.color});
  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _kText),
        ),
      ],
    );
  }
}

class _PlatformHealthCard extends StatelessWidget {
  const _PlatformHealthCard({required this.health});
  final PlatformHealthModel health;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HealthRing(score: health.platformHealthScore),
              const SizedBox(width: 20),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricPill(label: 'Enrolled', value: '${health.enrolledStudentsPct.toStringAsFixed(1)}%', color: _kBlue),
                    _MetricPill(label: 'Active Courses', value: '${health.activeCoursesPct.toStringAsFixed(1)}%', color: _kGreen),
                    _MetricPill(label: 'Completion', value: '${health.overallCompletionRate.toStringAsFixed(1)}%', color: _kOrange),
                    _MetricPill(label: 'Quiz Pass', value: '${health.overallQuizPassRate.toStringAsFixed(1)}%', color: _kPurple),
                    _MetricPill(label: 'Active Users', value: '${health.activeUsersPct.toStringAsFixed(1)}%', color: _kRed),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthRing extends StatelessWidget {
  const _HealthRing({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 80 ? _kGreen : score >= 60 ? _kOrange : _kRed;
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 10,
            backgroundColor: _kBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(score.toStringAsFixed(1), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
                const Text('Health', style: TextStyle(fontSize: 10, color: _kSub)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: _kSub)),
        ],
      ),
    );
  }
}

class _AtRiskCard extends StatelessWidget {
  const _AtRiskCard({required this.students});
  final List<AtRiskStudentModel> students;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'At-Risk Students',
      icon: Icons.warning_amber_rounded,
      iconColor: _kRed,
      child: students.isEmpty
          ? const _EmptyAnalytics(message: 'No at-risk data available')
          : Column(
              children: students.take(5).map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _kRed.withOpacity(0.1),
                        child: Text('#${s.studentId}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _kRed)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.departmentName.isNotEmpty ? s.departmentName : 'Student #${s.studentId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kText)),
                            Text('Risk ${(s.combinedRiskScore * 100).toStringAsFixed(1)}% • Completion ${(s.completionRate * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, color: _kSub)),
                          ],
                        ),
                      ),
                      _SeverityBadge(score: s.combinedRiskScore),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final label = score >= 0.7 ? 'High' : score >= 0.4 ? 'Medium' : 'Low';
    final color = score >= 0.7 ? _kRed : score >= 0.4 ? _kOrange : _kGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.alerts});
  final List<AlertModel> alerts;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'System Alerts',
      icon: Icons.notifications_active_rounded,
      iconColor: _kOrange,
      child: alerts.isEmpty
          ? const _EmptyAnalytics(message: 'No active alerts')
          : Column(
              children: alerts.map((a) {
                final color = a.severity == 'High' ? _kRed : a.severity == 'Medium' ? _kOrange : _kBlue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(a.alert, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kText))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('${a.count}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _CourseRankingCard extends StatelessWidget {
  const _CourseRankingCard({required this.title, required this.courses, required this.color});
  final String title;
  final List<CourseRankingModel> courses;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: title,
      icon: Icons.school_rounded,
      iconColor: color,
      child: courses.isEmpty
          ? _EmptyAnalytics(message: 'No $title data')
          : Column(
              children: courses.take(5).map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kText), overflow: TextOverflow.ellipsis),
                            Text(c.departmentName, style: const TextStyle(fontSize: 10, color: _kSub)),
                          ],
                        ),
                      ),
                      Text(
                        c.enrolledStudentsCount > 0 ? '${c.enrolledStudentsCount} enrolled' : '${(c.quizPassRate * 100).toStringAsFixed(1)}% pass',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _DepartmentComparisonCard extends StatelessWidget {
  const _DepartmentComparisonCard({required this.departments});
  final List<DepartmentComparisonModel> departments;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Department Comparison',
      icon: Icons.domain_rounded,
      iconColor: _kBlue,
      child: departments.isEmpty
          ? const _EmptyAnalytics(message: 'No department data')
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kText),
                dataTextStyle: const TextStyle(fontSize: 12, color: _kSub),
                columns: const [
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Students')),
                  DataColumn(label: Text('Avg Quiz')),
                  DataColumn(label: Text('Completion')),
                ],
                rows: departments.map((d) {
                  return DataRow(cells: [
                    DataCell(Text(d.departmentName)),
                    DataCell(Text('${d.students}')),
                    DataCell(Text(d.avgQuizScore.toStringAsFixed(1))),
                    DataCell(Text('${(d.completionRate * 100).toStringAsFixed(1)}%')),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}

class _LearningFunnelCard extends StatelessWidget {
  const _LearningFunnelCard({required this.funnel});
  final List<LearningFunnelStageModel> funnel;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Learning Funnel',
      icon: Icons.filter_alt_rounded,
      iconColor: _kPurple,
      child: funnel.isEmpty
          ? const _EmptyAnalytics(message: 'No funnel data')
          : Column(
              children: funnel.asMap().entries.map((e) {
                final stage = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _kSub))),
                      Expanded(child: Text(stage.stage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kText))),
                      Text('${stage.count}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kText)),
                      const SizedBox(width: 8),
                      Text('${stage.retentionPct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: _kSub)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.title, required this.icon, required this.iconColor, required this.child});
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
  const _EmptyAnalytics({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(child: Text(message, style: const TextStyle(color: _kSub, fontSize: 13), textAlign: TextAlign.center)),
    );
  }
}
