import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/cons/Colors/app_colors.dart';
import 'student_quiz_model.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.result});
  final StudentQuizResult result;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;
    final maxWidth = isLargeScreen
        ? 700.0
        : (isMediumScreen ? 600.0 : double.infinity);

    final hasScore = result.score != null && result.scorePercent != null;
    final passed = hasScore && result.scorePercent! >= 50;
    final percent = hasScore ? result.scorePercent!.clamp(0, 100) : 0.0;

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context),
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
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Quiz Result',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'inter',
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _ResultHeroCard(
                      result: result,
                      hasScore: hasScore,
                      percent: percent.toDouble(),
                      passed: passed,
                    ),
                    const SizedBox(height: 20),
                    _ResultDetailsCard(result: result),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultHeroCard extends StatelessWidget {

  const _ResultHeroCard({
    required this.result,
    required this.hasScore,
    required this.percent,
    required this.passed,
  });
  final StudentQuizResult result;
  final bool hasScore;
  final double percent;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final isPendingGrading = result.status == 'Submitted' && !hasScore;

    final gradientColors = !hasScore
        ? const [Color(0xFF64748B), Color(0xFF94A3B8)]
        : passed
        ? const [Color(0xFF059669), Color(0xFF34D399)]
        : const [Color(0xFFDC2626), Color(0xFFF87171)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            !hasScore
                ? Icons.hourglass_top_rounded
                : passed
                ? Icons.emoji_events_rounded
                : Icons.replay_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 14),
          Text(
            result.quizTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'inter',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (hasScore) ...[
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                fontFamily: 'inter',
                color: Colors.white,
              ),
            ),
            Text(
              '${result.score!.toStringAsFixed(0)} / ${result.maxScore} points',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                fontFamily: 'inter',
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                passed ? 'Passed' : 'Not Passed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'inter',
                  color: passed
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
              ),
            ),
          ] else ...[
            Text(
              isPendingGrading ? 'Submitted — awaiting grading' : result.status,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                fontFamily: 'inter',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This quiz includes questions that need manual review.\nYour score will appear here once grading is complete.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
                fontFamily: 'inter',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultDetailsCard extends StatelessWidget {
  const _ResultDetailsCard({required this.result});
  final StudentQuizResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attempt Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'inter',
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            label: 'Attempt Number',
            value: '#${result.attemptNumber}',
          ),
          _DetailRow(label: 'Status', value: result.status),
          if (result.startedAt != null)
            _DetailRow(
              label: 'Started At',
              value: DateFormat('MMM d, y · h:mm a').format(result.startedAt!),
            ),
          if (result.submittedAt != null)
            _DetailRow(
              label: 'Submitted At',
              value: DateFormat(
                'MMM d, y · h:mm a',
              ).format(result.submittedAt!),
            ),
          if (result.timeSpentSeconds != null)
            _DetailRow(
              label: 'Time Spent',
              value: _formatSeconds(result.timeSpentSeconds!),
            ),
        ],
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'inter',
              color: Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'inter',
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
