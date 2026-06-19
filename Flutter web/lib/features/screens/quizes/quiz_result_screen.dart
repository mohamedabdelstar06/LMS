// ============================================================
// quiz_result_screen.dart
// ============================================================
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key, required this.result});
  final QuizResult result;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scoreAnim = Tween<double>(begin: 0, end: widget.result.score / 100).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final passed = result.passed;
    final primaryColor = passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final bgColor = passed ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2);
    final seconds = result.timeTakenSeconds ?? 0;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(result.quizTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
              const SizedBox(height: 20),

              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(width: 180, height: 180, child: CustomPaint(painter: _ScoreRingPainter(progress: _scoreAnim.value, color: primaryColor))),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${result.score.toStringAsFixed(0)}%', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: primaryColor)),
                        Text(passed ? '🎉 Passed!' : '😔 Try Again', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),

              if (!result.isFullyGraded)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFCD34D))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xFFD97706)),
                      SizedBox(width: 6),
                      Text('Pending manual grading', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706))),
                    ]),
                  ),
                ),

              const SizedBox(height: 24),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  _StatCard(icon: Icons.check_circle_outline_rounded, label: 'Correct', value: '${result.correctAnswers}/${result.totalQuestions}', color: const Color(0xFF10B981)),
                  _StatCard(icon: Icons.military_tech_outlined, label: 'Marks', value: '${result.earnedMarks}/${result.totalMarks}', color: const Color(0xFF6366F1)),
                  _StatCard(icon: Icons.timer_outlined, label: 'Time Taken', value: '${minutes}m ${secs.toString().padLeft(2, '0')}s', color: const Color(0xFF0EA5E9)),
                  _StatCard(icon: Icons.verified_outlined, label: 'Pass Mark', value: '${result.passingScore.toInt()}%', color: primaryColor),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withOpacity(0.2))),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), shape: BoxShape.circle),
                      child: Icon(passed ? Icons.emoji_events_rounded : Icons.refresh_rounded, color: primaryColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(passed ? 'Excellent work!' : 'Keep practicing!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: primaryColor)),
                          const SizedBox(height: 2),
                          Text(
                            passed
                                ? 'You passed with ${result.score.toStringAsFixed(0)}%. Great job!'
                                : 'You need ${result.passingScore.toInt()}% to pass. You scored ${result.score.toStringAsFixed(0)}%.',
                            style: TextStyle(fontSize: 12, color: primaryColor.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  child: const Text('Back to Quizzes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: color.withOpacity(0.06), blurRadius: 12)]),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ScoreRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    final bgPaint = Paint()..color = color.withOpacity(0.1)..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress || old.color != color;
}
