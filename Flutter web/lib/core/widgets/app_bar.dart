import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lms/features/screens/admin/dashboard_cubit.dart';
import 'package:lms/features/screens/admin/dashboard_screen.dart';

import '../../features/screens/admin/admin_profile/view.dart';
import '../../features/screens/logs/state_mangement/logs_cubit.dart';
import '../../features/screens/logs/state_mangement/repositery_fetch.dart';
import '../../features/screens/logs/view/view.dart';
import '../../generated/assets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // ── Logo + Brand ─────────────────────────────────
              _LogoBrand(),

              const Spacer(),

              // ── Nav links ────────────────────────────────────
              _NavLink(
                label: 'Dashboard',
                icon: Icons.dashboard_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => DashboardCubit(),
                        child: const AdminDashboardScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              _NavLink(
                label: 'System Logs',
                icon: Icons.receipt_long_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) =>
                            ActivityLogsCubit(ActivityLogsRepository()),
                        child: const ActivityLogsScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              _NavLink(
                label: 'Management',
                icon: Icons.manage_accounts_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminProfileScreen()),
                  );
                },
              ),

              const SizedBox(width: 20),

              // ── Divider ──────────────────────────────────────
              Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),

              const SizedBox(width: 20),

              // ── Notification bell ────────────────────────────
              _IconBtn(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Notifications',
                badge: 3,
                onTap: () {},
              ),

              const SizedBox(width: 4),

              // ── Avatar ───────────────────────────────────────
              _AdminAvatar(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo + Brand ─────────────────────────────────────────────

class _LogoBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulsingLogo(),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SkyLearn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D2772),
                letterSpacing: -0.3,
                fontFamily: 'inter',
              ),
            ),
            Text(
              'Admin Portal',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PulsingLogo extends StatefulWidget {
  @override
  State<_PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<_PulsingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D2772).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage(Assets.logo),
        ),
      ),
    );
  }
}

// ── Nav link button ──────────────────────────────────────────

class _NavLink extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _hovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'inter',
                  color: _hovered
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Icon button with optional badge ─────────────────────────

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final int badge;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    this.badge = 0,
    required this.onTap,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _hovered
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _hovered
                    ? const Color(0xFFBFDBFE)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: _hovered
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                ),
                if (widget.badge > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Admin avatar with dropdown ───────────────────────────────

class _AdminAvatar extends StatefulWidget {
  @override
  State<_AdminAvatar> createState() => _AdminAvatarState();
}

class _AdminAvatarState extends State<_AdminAvatar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminProfileScreen()),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0D2772)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'inter',
                    ),
                  ),
                  Text(
                    'System Administrator',
                    style: TextStyle(
                      fontSize: 9,
                      color: const Color(0xFF94A3B8),
                      fontFamily: 'inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: _hovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
