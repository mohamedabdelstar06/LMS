import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/admin/Noti_styles.dart';
import 'package:lms/features/screens/admin/Notifications_model.dart';


class NotificationTile extends StatefulWidget {
  final NotificationModel notification;
  final bool isMarking;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.isMarking,
    required this.onTap,
    required this.onMarkRead,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.985,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final config = NotificationStyles.forType(n.type);
    final isUnread = !n.isRead;

    final bg = isUnread ? config.unreadBackground : config.readBackground;
    final border = isUnread ? config.unreadBorder : config.readBorder;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animCtrl.forward(),
        onTapUp: (_) {
          _animCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _animCtrl.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: _hovered ? Color.lerp(bg, Colors.white, 0.4) : bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hovered ? config.iconColor.withOpacity(0.4) : border,
                width: isUnread ? 1.5 : 1,
              ),
              boxShadow: isUnread && !widget.isMarking
                  ? [
                      BoxShadow(
                        color: config.iconColor.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Icon ────────────────────────────────────────────────
                  _buildIcon(config),
                  const SizedBox(width: 12),

                  // ── Content ─────────────────────────────────────────────
                  Expanded(child: _buildContent(n, config, isUnread)),

                  // ── Actions ─────────────────────────────────────────────
                  if (isUnread) _buildMarkReadButton(config),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(NotificationTypeConfig config) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: config.iconBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(config.icon, color: config.iconColor, size: 22),
      ),
    );
  }

  Widget _buildContent(
    NotificationModel n,
    NotificationTypeConfig config,
    bool isUnread,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge + time
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: config.iconBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                config.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: config.iconColor,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const Spacer(),
            Text(
              _formatTime(n.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: isUnread
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: config.iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // Title
        Text(
          n.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
            color: isUnread ? const Color(0xFF0F172A) : const Color(0xFF475569),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),

        // Body
        Text(
          n.body,
          style: TextStyle(
            fontSize: 13,
            color: isUnread ? const Color(0xFF334155) : const Color(0xFF94A3B8),
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMarkReadButton(NotificationTypeConfig config) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2),
      child: widget.isMarking
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: config.iconColor,
              ),
            )
          : GestureDetector(
              onTap: widget.onMarkRead,
              child: Tooltip(
                message: 'Mark as read',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _hovered
                        ? config.iconBackground
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.done_all_rounded,
                    size: 16,
                    color: config.iconColor.withOpacity(0.7),
                  ),
                ),
              ),
            ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
