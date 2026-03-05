import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({required this.progress});
  final double progress;

  @override
  State<ProgressCard> createState() => ProgressCardState();
}

class ProgressCardState extends State<ProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _progressAnim = Tween<double>(begin: 0, end: widget.progress / 100)
        .animate(CurvedAnimation(
        parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _progressColor {
    if (widget.progress >= 80) return const Color(0xFF059669);
    if (widget.progress >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFF0EA5E9);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAE6FD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _progressColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.trending_up,
                        color: _progressColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Your Progress',
                    style: TextStyle(
                      color: Color(0xFF0369A1),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(_progressAnim.value * 100).toInt()}%',
                    style: TextStyle(
                      color: _progressColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                minHeight: 10,
                backgroundColor: const Color(0xFFE0F2FE),
                valueColor:
                AlwaysStoppedAnimation<Color>(_progressColor),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ProgressMilestones(
              progress: widget.progress, color: _progressColor),
        ],
      ),
    );
  }
}

class ProgressMilestones extends StatelessWidget {
  const ProgressMilestones(
      {required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final milestones = [
      (25, 'Started'),
      (50, 'Halfway'),
      (75, 'Almost'),
      (100, 'Done'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: milestones.map((m) {
        final reached = progress >= m.$1;
        return Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                reached ? color : const Color(0xFFBAE6FD),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              m.$2,
              style: TextStyle(
                color: reached ? color : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

