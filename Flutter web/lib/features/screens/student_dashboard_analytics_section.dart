// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:lms/features/screens/student_dashboard_cubit.dart';

const _kCard = Colors.white;
const _kBlue = Color(0xFF2563EB);
const _kBlueDeep = Color(0xFF0D2772);
const _kGreen = Color(0xFF10B981);
const _kOrange = Color(0xFFF59E0B);
const _kPurple = Color(0xFF7C3AED);
const _kRed = Color(0xFFEF4444);
const _kText = Color(0xFF0F172A);
const _kSub = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

class StudentDashboardAnalyticsSection extends StatelessWidget {
  const StudentDashboardAnalyticsSection({super.key, required this.analytics});

  final StudentAnalyticsModel analytics;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w > 800;

    if (analytics.studentId == 0 && analytics.segment.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Learning Analytics',
          icon: Icons.analytics_rounded,
          color: _kPurple,
        ),
        const SizedBox(height: 16),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _RankCard(analytics: analytics)),
                  const SizedBox(width: 16),
                  Expanded(child: _RiskCard(analytics: analytics)),
                ],
              )
            : Column(
                children: [
                  _RankCard(analytics: analytics),
                  const SizedBox(height: 16),
                  _RiskCard(analytics: analytics),
                ],
              ),
        const SizedBox(height: 16),
        _ComparisonCard(analytics: analytics),
        const SizedBox(height: 16),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TrendCard(trend: analytics.improvementTrend)),
                  const SizedBox(width: 16),
                  Expanded(child: _StrengthsCard(items: analytics.strengthsWeaknesses)),
                ],
              )
            : Column(
                children: [
                  _TrendCard(trend: analytics.improvementTrend),
                  const SizedBox(height: 16),
                  _StrengthsCard(items: analytics.strengthsWeaknesses),
                ],
              ),
        const SizedBox(height: 16),
        _CourseProgressCard(courses: analytics.courseProgress),
        const SizedBox(height: 16),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _EfficiencyCard(efficiency: analytics.learningEfficiency)),
                  const SizedBox(width: 16),
                  Expanded(child: _WorkloadCard(workload: analytics.workload)),
                ],
              )
            : Column(
                children: [
                  _EfficiencyCard(efficiency: analytics.learningEfficiency),
                  const SizedBox(height: 16),
                  _WorkloadCard(workload: analytics.workload),
                ],
              ),
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

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.title, required this.icon, required this.iconColor, required this.child});
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
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

class _RankCard extends StatelessWidget {
  const _RankCard({required this.analytics});
  final StudentAnalyticsModel analytics;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Rankings',
      icon: Icons.emoji_events_rounded,
      iconColor: _kOrange,
      child: Column(
        children: [
          _RankRow(label: 'Overall', value: analytics.overallRank),
          _RankRow(label: 'Department', value: analytics.deptRank),
          _RankRow(label: 'Squadron', value: analytics.squadronRank),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: 'Composite',
                  value: '${analytics.compositeScore.toStringAsFixed(2)}',
                  color: _kBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricPill(
                  label: 'Segment',
                  value: analytics.segment.isEmpty ? '-' : analytics.segment,
                  color: _kPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _kSub)),
          const Spacer(),
          Text(
            value == 0 ? '-' : '#$value',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _kText),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.analytics});
  final StudentAnalyticsModel analytics;

  @override
  Widget build(BuildContext context) {
    final risk = analytics.riskScore.clamp(0.0, 1.0);
    final color = risk >= 0.7 ? _kRed : risk >= 0.4 ? _kOrange : _kGreen;
    return _AnalyticsCard(
      title: 'Risk Insights',
      icon: Icons.warning_amber_rounded,
      iconColor: _kRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${(risk * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
                    const Text('Risk Score', style: TextStyle(fontSize: 12, color: _kSub)),
                  ],
                ),
              ),
              if (analytics.isAnomaly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _kRed.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Anomaly', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kRed)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: risk,
              minHeight: 8,
              backgroundColor: _kBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(
                label: 'Dropout',
                value: '${(analytics.dropoutProbability * 100).toStringAsFixed(1)}%',
                color: _kOrange,
              ),
              _MetricPill(
                label: 'At-Risk',
                value: '${(analytics.atRiskProbability * 100).toStringAsFixed(1)}%',
                color: _kRed,
              ),
              if (analytics.anomalyType.isNotEmpty)
                _MetricPill(
                  label: 'Type',
                  value: analytics.anomalyType,
                  color: _kPurple,
                ),
            ],
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: _kSub)),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.analytics});
  final StudentAnalyticsModel analytics;

  double _classAvg(String metric) {
    return analytics.classAverages.firstWhere((a) => a.metric == metric, orElse: () => const ClassAverageModel(metric: '', average: 0)).average;
  }

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _ComparisonRowData('Avg Quiz', analytics.avgQuizScore, _classAvg('AvgQuizScore')),
      _ComparisonRowData('Avg Grade', analytics.avgGrade, _classAvg('AvgGrade')),
      _ComparisonRowData('Quiz Pass', analytics.quizPassRate * 100, _classAvg('QuizPassRate') * 100, isPercent: true),
      _ComparisonRowData('Completion', analytics.completionRate * 100, _classAvg('CompletionRate') * 100, isPercent: true),
    ];

    return _AnalyticsCard(
      title: 'You vs Class Average',
      icon: Icons.compare_rounded,
      iconColor: _kBlue,
      child: Column(
        children: metrics.map((m) => _ComparisonRow(data: m)).toList(),
      ),
    );
  }
}

class _ComparisonRowData {
  const _ComparisonRowData(this.label, this.yours, this.classAvg, {this.isPercent = false});
  final String label;
  final double yours;
  final double classAvg;
  final bool isPercent;
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.data});
  final _ComparisonRowData data;

  @override
  Widget build(BuildContext context) {
    final suffix = data.isPercent ? '%' : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(data.label, style: const TextStyle(fontSize: 12, color: _kSub))),
          Expanded(
            flex: 2,
            child: _MiniBar(label: 'You', value: data.yours, max: 100, color: _kBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _MiniBar(label: 'Class', value: data.classAvg, max: 100, color: _kGreen),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${data.yours.toStringAsFixed(1)}$suffix',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kText),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.label, required this.value, required this.max, required this.color});
  final String label;
  final double value;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _kSub)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: _kBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend});
  final List<ImprovementTrendModel> trend;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Improvement Trend',
      icon: Icons.trending_up_rounded,
      iconColor: _kGreen,
      child: trend.isEmpty
          ? const _EmptyAnalytics(message: 'No trend data yet')
          : Column(
              children: trend.take(6).map((t) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _kBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(t.month, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kBlue)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${t.attempts} attempts', style: const TextStyle(fontSize: 12, color: _kSub))),
                      Text('${t.avgScore.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kText)),
                      const SizedBox(width: 8),
                      Text('${(t.passRate * 100).toStringAsFixed(0)}% pass', style: const TextStyle(fontSize: 11, color: _kSub)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _StrengthsCard extends StatelessWidget {
  const _StrengthsCard({required this.items});
  final List<StrengthWeaknessModel> items;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Strengths & Weaknesses',
      icon: Icons.psychology_rounded,
      iconColor: _kPurple,
      child: items.isEmpty
          ? const _EmptyAnalytics(message: 'No question data yet')
          : Column(
              children: items.map((i) {
                final rate = i.correctRate.clamp(0.0, 1.0);
                final color = rate >= 0.7 ? _kGreen : rate >= 0.4 ? _kOrange : _kRed;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(i.questionType, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kText)),
                          Text('${i.correctCount}/${i.answered}', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 6,
                          backgroundColor: _kBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard({required this.courses});
  final List<StudentCourseProgressModel> courses;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Course Progress Detail',
      icon: Icons.menu_book_rounded,
      iconColor: _kBlueDeep,
      child: courses.isEmpty
          ? const _EmptyAnalytics(message: 'No course progress data')
          : Column(
              children: courses.take(6).map((c) {
                final pct = (c.completionRate * 100).clamp(0.0, 100.0);
                final color = pct >= 80 ? _kGreen : pct >= 50 ? _kOrange : _kRed;
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
                              c.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${c.activitiesDone}/${c.activitiesTotal} activities',
                            style: const TextStyle(fontSize: 11, color: _kSub),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 7,
                                backgroundColor: _kBorder,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _EfficiencyCard extends StatelessWidget {
  const _EfficiencyCard({required this.efficiency});
  final List<LearningEfficiencyModel> efficiency;

  @override
  Widget build(BuildContext context) {
    final e = efficiency.isNotEmpty ? efficiency.first : null;
    return _AnalyticsCard(
      title: 'Learning Efficiency',
      icon: Icons.bolt_rounded,
      iconColor: _kOrange,
      child: e == null
          ? const _EmptyAnalytics(message: 'No efficiency data')
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricPill(label: 'Efficiency', value: e.avgEfficiency.toStringAsFixed(2), color: _kOrange),
                _MetricPill(label: 'Avg Score', value: e.avgScore.toStringAsFixed(1), color: _kBlue),
                _MetricPill(label: 'Avg Time', value: '${e.avgTimeMinutes.toStringAsFixed(1)}m', color: _kPurple),
                _MetricPill(label: 'Attempts', value: '${e.totalAttempts}', color: _kGreen),
                _MetricPill(label: 'Tier', value: e.efficiencyTier.isEmpty ? '-' : e.efficiencyTier, color: _kRed),
              ],
            ),
    );
  }
}

class _WorkloadCard extends StatelessWidget {
  const _WorkloadCard({required this.workload});
  final List<StudentWorkloadModel> workload;

  @override
  Widget build(BuildContext context) {
    final w = workload.isNotEmpty ? workload.first : null;
    return _AnalyticsCard(
      title: 'Workload',
      icon: Icons.work_outline_rounded,
      iconColor: _kGreen,
      child: w == null
          ? const _EmptyAnalytics(message: 'No workload data')
          : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricPill(label: 'Submissions/Week', value: w.avgSubmissionsPerWeek.toStringAsFixed(1), color: _kBlue),
                _MetricPill(label: 'Max in Week', value: '${w.maxSubmissionsInWeek}', color: _kOrange),
                _MetricPill(label: 'Active Weeks', value: '${w.activeWeeks}', color: _kGreen),
                _MetricPill(label: 'Tier', value: w.workloadTier.isEmpty ? '-' : w.workloadTier, color: _kPurple),
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
