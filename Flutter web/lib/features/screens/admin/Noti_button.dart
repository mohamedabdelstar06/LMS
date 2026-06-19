import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/Noti_cubit.dart';
import 'package:lms/features/screens/admin/Noti_sheet.dart';
import 'package:lms/features/screens/admin/Noti_states.dart';
import 'package:lms/features/screens/admin/Noti_styles.dart';



class NotificationBellButton extends StatefulWidget {

  const NotificationBellButton({
    super.key,
    required this.token,
    required this.role,
  });
  final String token;
  final String role;

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton>
    with SingleTickerProviderStateMixin {
  late NotificationCubit _cubit;
  bool _hovered = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _cubit = NotificationCubit();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    // Load unread count on init
    _cubit.fetchUnreadCount(widget.token);
  }

  @override
  void dispose() {
    _cubit.close();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _openSheet() {
    _shakeCtrl.forward(from: 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: NotificationsSheet(token: widget.token, role: widget.role),
      ),
    ).then((_) {
      // Refresh unread count when sheet closes
      _cubit.fetchUnreadCount(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = NotificationStyles.roleAccent(widget.role);
    final accentLight = NotificationStyles.roleAccentLight(widget.role);

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          int unread = 0;
          if (state is NotificationUnreadCountLoaded) {
            unread = state.unreadCount;
          } else if (state is NotificationLoaded) {
            unread = state.unreadCount;
          }

          return MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _openSheet,
              child: AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) =>
                    Transform.rotate(angle: _shakeAnim.value, child: child),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hovered ? accentLight : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hovered
                          ? accent.withOpacity(0.5)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: _hovered ? accent : const Color(0xFF64748B),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: 1,
                          right: 2,
                          child: _UnreadBadge(count: unread),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();
    final isWide = count > 9; // رقمين أو أكتر → pill shape

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      height: 16,
      width: isWide ? 22 : 16,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
