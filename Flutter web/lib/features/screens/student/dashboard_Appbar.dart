import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/core/helpers/logout_server/logout.dart';
import 'package:lms/features/screens/admin/Noti_button.dart';

import 'package:lms/features/screens/student/student_activities_screen.dart';
import 'package:lms/features/screens/student/student_courses/view.dart';
import 'package:lms/features/screens/student/student_profile/view.dart';
import 'package:lms/generated/assets.dart';
import 'package:web/helpers.dart' as html;

/// AppBar for the Student Dashboard screen.
class StudentDashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
   StudentDashboardAppBar({super.key, this.onNavigateToGrades});

  final Map<String, dynamic> userData = {};

  /// Called when the user taps the "Grades" quick-access button.
  /// If null, shows a dialog prompting the student to pick a course first.
  final VoidCallback? onNavigateToGrades;

  @override
  Size get preferredSize => const Size.fromHeight(400);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1200;
    final isMediumScreen = screenWidth >= 800 && screenWidth < 1200;
    final isCompact = screenWidth < 700;

    return SafeArea(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isLargeScreen
              ? 1400
              : (isMediumScreen ? 1000 : double.infinity),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
          vertical: 20,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xffE3F6FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          
          children: [
            // ── Title / greeting block ─────────────────────────
            if (!isCompact) ...[_DashboardTitle(), const SizedBox(width: 20)],
            const Spacer(),
            // ── Courses Button (replaces search bar) ───────────
            _QuickAccessButton(
              icon: Icons.menu_book_rounded,
              label: 'Courses',
              color: const Color(0xFF0D9488),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentCourseScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),

            // ── Quick access: Activities & Grades ──────────────
            if (!isCompact) ...[
              _QuickAccessButton(
                icon: Icons.timeline_rounded,
                label: 'Activities',
                color: const Color(0xFF2563EB),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentActivitiesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              
            ],
            const Spacer(),

            // ── Notifications + profile ────────────────────────
            FutureBuilder<String?>(
              future: TokenStorageHelper.getTokenSecure(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return NotificationBellButton(
                  token: snapshot.data!,
                  role: 'student',
                );
              },
            ),
            const SizedBox(width: 20),
            buildUserProfile(context),
          ],
        ),
      ),
    );
  }

  /// Shows a dialog explaining that the student needs to pick a course
  /// before viewing grades, then navigates to [StudentCourseScreen].
  
Widget buildUserProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          webProfileAvatar(
            imageUrl: buildProfileImageUrl(userData['profileImageUrl']),
          ),
          const SizedBox(width: 8),
          Text(
            userData['fullName'] ?? 'User',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'inter',
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Color(0xFF64748B),
              size: 20,
            ),
            onPressed: () => showUserMenu(context),
          ),
        ],
      ),
    );
  }

  Widget webProfileAvatar({
    required String? imageUrl,
    double radius = 16,
    bool isOnline = true,
  }) {
    final size = radius * 2;
    final indicatorSize = radius * 0.6;

    return SizedBox(
      // +indicatorSize/2 عشان الـ indicator مش يتقطع
      width: size + indicatorSize / 2,
      height: size + indicatorSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Avatar ────────────────────────────────────────
          ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? WebImage(url: imageUrl, width: size, height: size)
                  : _avatarFallback(size),
            ),
          ),

          // ── Online dot ────────────────────────────────────
          if (isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Fallback avatar عند غياب الصورة — حرف أول الاسم أو أيقونة.
  Widget _avatarFallback(double size) {
    final name = (userData['fullName'] as String?) ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE3F6FF),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF175CD3),
          fontFamily: 'inter',
        ),
      ),
    );
  }
  Widget avatarPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF175CD3),
        ),
      ),
    );
  }

  Widget onlineIndicator({bool isOnline = true, double size = 10}) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? Colors.green : Colors.grey,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  void showUserMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, color: Color(0xFF175CD3)),
              SizedBox(width: 8),
              Text(
                'Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: Color(0xFF059669)),
              SizedBox(width: 8),
              Text(
                'Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == 'logout') {
      await LogoutServer.logout();
    } else if (result == 'profile') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentProfileScreen()),
      );
    } else if (result == 'settings') {
      // TODO: Add settings action later
    }
  }
}

// ── Dashboard Title ───────────────────────────────────────────
class _DashboardTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF0D2772)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.space_dashboard_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                fontFamily: 'inter',
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Welcome back 👋',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'inter',
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Quick Access Button ───────────────────────────────────────
class _QuickAccessButton extends StatelessWidget {
  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'inter',
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compact Quick Access Menu ─────────────────────────────────
class _CompactQuickAccessMenu extends StatelessWidget {
  final VoidCallback? onNavigateToGrades;
  const _CompactQuickAccessMenu({Key? key, this.onNavigateToGrades}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Quick access',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Colors.white,
        icon: const Icon(Icons.apps_rounded, color: Color(0xFF2563EB)),
        onSelected: (value) {
          if (value == 'courses') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentCourseScreen()),
            );
          } else if (value == 'activities') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentActivitiesScreen(),
              ),
            );
          } else if (value == 'grades') {
            onNavigateToGrades?.call();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'courses',
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, color: Color(0xFF0D9488)),
                SizedBox(width: 8),
                Text(
                  'Courses',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'activities',
            child: Row(
              children: [
                Icon(Icons.timeline_rounded, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text(
                  'Activities',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'grades',
            child: Row(
              children: [
                Icon(Icons.grade_rounded, color: Color(0xFF7C3AED)),
                SizedBox(width: 8),
                Text(
                  'Grades',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Web Image ─────────────────────────────────────────────────
class WebImage extends StatelessWidget {
  WebImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  }) {
    _register();
  }
  final String url;
  final double width;
  final double height;

  static final Set<String> _registeredViews = {};

  void _register() {
    if (_registeredViews.contains(url)) return;
    ui.platformViewRegistry.registerViewFactory(url, (int _) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';
      return img;
    });
    _registeredViews.add(url);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: url),
    );
  }
}
