import 'package:flutter/material.dart';

/// Header for admin list screens (Users, Squadrons, Departments, etc.).
/// Matches the Squadrons screen styling.
class AdminTableHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<AdminStatBadge> stats;

  const AdminTableHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: stats
                .map(
                  (s) => _CompactStatBadge(
                    title: s.title,
                    count: s.count,
                    icon: s.icon,
                    color: s.color,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class AdminStatBadge {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const AdminStatBadge({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });
}

class _CompactStatBadge extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _CompactStatBadge({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:  TextStyle(
                  fontSize: 10,
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                count.toString(),
                style:  TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
