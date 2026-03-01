import 'package:flutter/material.dart';

class LogHelpers {
  static Color componentColor(String component) {
    switch (component.toLowerCase()) {
      case 'auth':
        return const Color(0xFF3B82F6);
      case 'lectures':
      case 'lecture':
        return const Color(0xFF10B981);
      case 'courses':
      case 'course':
        return const Color(0xFF8B5CF6);
      case 'users':
      case 'user':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  static IconData originIcon(String origin) {
    switch (origin.toLowerCase()) {
      case 'web':
        return Icons.language;
      case 'cli':
        return Icons.terminal;
      default:
        return Icons.device_unknown;
    }
  }

  static String formatTime(DateTime time) {
    final local = time.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String formatDate(DateTime time) {
    final local = time.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  static String formatRelative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static List<String> get components => ['Auth', 'Lectures', 'Lecture', 'Courses', 'Users'];

  static List<String> get origins => ['web', 'cli'];
}