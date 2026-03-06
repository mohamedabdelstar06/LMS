

import 'package:flutter/material.dart';

class LiquidPill extends StatefulWidget {
  const LiquidPill({super.key, required this.position});
  final double position;

  @override
  State<LiquidPill> createState() => LiquidPillState();
}

class LiquidPillState extends State<LiquidPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        final shimmerX = -1.5 + _shimmer.value * 3.0;
        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(shimmerX - 0.3, -1),
              end: Alignment(shimmerX + 0.6, 1),
              colors: [
                Colors.white.withValues(alpha: .92),
                Colors.white.withValues(alpha: .96),
                Colors.lightBlueAccent.withValues(alpha: .22),
                Colors.white.withValues(alpha: .94),
              ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: .9),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withValues(alpha: .5),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: .8),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 1.78,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: .9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}