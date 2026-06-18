import 'package:flutter/material.dart';

/// Maps notification `type` string → visual config.
/// Extend this as new types are added in the backend.
class NotificationTypeConfig {
  final Color unreadBackground;
  final Color readBackground;
  final Color unreadBorder;
  final Color readBorder;
  final Color iconBackground;
  final Color iconColor;
  final IconData icon;
  final String label;

  const NotificationTypeConfig({
    required this.unreadBackground,
    required this.readBackground,
    required this.unreadBorder,
    required this.readBorder,
    required this.iconBackground,
    required this.iconColor,
    required this.icon,
    required this.label,
  });
}

class NotificationStyles {
  NotificationStyles._();

  // ── Type → Config mapping ──────────────────────────────────────────────────
  static NotificationTypeConfig forType(String type) {
    switch (type.toLowerCase()) {
      case 'enrollment':
        return const NotificationTypeConfig(
          unreadBackground: Color(0xFFEFF6FF),
          readBackground: Color(0xFFF8FAFC),
          unreadBorder: Color(0xFFBFDBFE),
          readBorder: Color(0xFFE2E8F0),
          iconBackground: Color(0xFFDBEAFE),
          iconColor: Color(0xFF1D4ED8),
          icon: Icons.school_rounded,
          label: 'Enrollment',
        );
      case 'assignment':
        return const NotificationTypeConfig(
          unreadBackground: Color(0xFFFFFBEB),
          readBackground: Color(0xFFF8FAFC),
          unreadBorder: Color(0xFFFDE68A),
          readBorder: Color(0xFFE2E8F0),
          iconBackground: Color(0xFFFEF3C7),
          iconColor: Color(0xFFD97706),
          icon: Icons.assignment_rounded,
          label: 'Assignment',
        );
      case 'grade':
        return const NotificationTypeConfig(
          unreadBackground: Color(0xFFF0FDF4),
          readBackground: Color(0xFFF8FAFC),
          unreadBorder: Color(0xFFBBF7D0),
          readBorder: Color(0xFFE2E8F0),
          iconBackground: Color(0xFFDCFCE7),
          iconColor: Color(0xFF16A34A),
          icon: Icons.grade_rounded,
          label: 'Grade',
        );
      case 'announcement':
        return const NotificationTypeConfig(
          unreadBackground: Color(0xFFFDF4FF),
          readBackground: Color(0xFFF8FAFC),
          unreadBorder: Color(0xFFE9D5FF),
          readBorder: Color(0xFFE2E8F0),
          iconBackground: Color(0xFFF3E8FF),
          iconColor: Color(0xFF7C3AED),
          icon: Icons.campaign_rounded,
          label: 'Announcement',
        );
      case 'message':
        return const NotificationTypeConfig(
          unreadBackground: Color(0xFFF0F9FF),
          readBackground: Color(0xFFF8FAFC),
          unreadBorder: Color(0xFFBAE6FD),
          readBorder: Color(0xFFE2E8F0),
          iconBackground: Color(0xFFE0F2FE),
          iconColor: Color(0xFF0284C7),
          icon: Icons.chat_bubble_rounded,
          label: 'Message',
        );
      case 'reminder':
        return const NotificationTypeConfig(
          unreadBackground: Color(0xFFFFF7ED),
          readBackground: Color(0xFFF8FAFC),
          unreadBorder: Color(0xFFFED7AA),
          readBorder: Color(0xFFE2E8F0),
          iconBackground: Color(0xFFFFEDD5),
          iconColor: Color(0xFFEA580C),
          icon: Icons.alarm_rounded,
          label: 'Reminder',
        );
      default:
        return const NotificationTypeConfig(
          unreadBackground: Color(0xFFEFF6FF),
          readBackground: Color(0xFFF8FAFC),
          unreadBorder: Color(0xFFBFDBFE),
          readBorder: Color(0xFFE2E8F0),
          iconBackground: Color(0xFFDBEAFE),
          iconColor: Color(0xFF1D4ED8),
          icon: Icons.notifications_rounded,
          label: 'Notification',
        );
    }
  }

  // ── Role colors ────────────────────────────────────────────────────────────
  static Color roleAccent(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFF7C3AED); // purple
      case 'instructor':
        return const Color(0xFF0284C7); // sky blue
      case 'student':
      default:
        return const Color(0xFF1D4ED8); // deep blue
    }
  }

  static Color roleAccentLight(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFF3E8FF);
      case 'instructor':
        return const Color(0xFFE0F2FE);
      case 'student':
      default:
        return const Color(0xFFDBEAFE);
    }
  }
}
