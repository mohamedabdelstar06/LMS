import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/Noti_Tile.dart';
import 'package:lms/features/screens/admin/Noti_cubit.dart';
import 'package:lms/features/screens/admin/Noti_states.dart';
import 'package:lms/features/screens/admin/Noti_styles.dart';
import 'package:lms/features/screens/admin/Notifications_model.dart';


class NotificationsSheet extends StatefulWidget {
  final String token;
  final String role;

  const NotificationsSheet({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  final ScrollController _scrollController = ScrollController();
  bool? _filterRead; // null = all, false = unread, true = read
  String? _filterType;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<NotificationCubit>().loadNotifications(
      token: widget.token,
      isRead: _filterRead,
      type: _filterType,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_loadingMore) {
        _loadingMore = true;
        context
            .read<NotificationCubit>()
            .loadMore(
              token: widget.token,
              isRead: _filterRead,
              type: _filterType,
            )
            .then((_) => _loadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = NotificationStyles.roleAccent(widget.role);
    final accentLight = NotificationStyles.roleAccentLight(widget.role);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Handle ──────────────────────────────────────────────────
            _buildHandle(),

            // ── Header ──────────────────────────────────────────────────
            _buildHeader(accent, accentLight),

            // ── Filter chips ────────────────────────────────────────────
            _buildFilters(accent),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: BlocConsumer<NotificationCubit, NotificationState>(
                listener: (context, state) {
                  if (state is NotificationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return _buildBody(state, accent);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(Color accent, Color accentLight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.notifications_rounded, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (_, state) {
                    int unread = 0;
                    if (state is NotificationLoaded) unread = state.unreadCount;
                    if (state is NotificationMarkingRead) {
                      unread = state.unreadCount;
                    }
                    if (unread == 0) {
                      return const Text(
                        'All caught up!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      );
                    }
                    return Text(
                      '$unread unread',
                      style: TextStyle(
                        fontSize: 12,
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Mark all read
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final hasUnread =
                  state is NotificationLoaded && state.unreadCount > 0;
              final isMarking =
                  state is NotificationMarkingRead && state.markingId == null;

              if (!hasUnread && !isMarking) return const SizedBox.shrink();

              return TextButton.icon(
                onPressed: isMarking
                    ? null
                    : () => context.read<NotificationCubit>().markAllAsRead(
                        token: widget.token,
                      ),
                icon: isMarking
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      )
                    : Icon(Icons.done_all_rounded, size: 16, color: accent),
                label: Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 12,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(Color accent) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _FilterChip(
            label: 'All',
            selected: _filterRead == null && _filterType == null,
            accent: accent,
            onTap: () {
              setState(() {
                _filterRead = null;
                _filterType = null;
              });
              _loadData();
            },
          ),
          _FilterChip(
            label: 'Unread',
            icon: Icons.circle,
            selected: _filterRead == false,
            accent: accent,
            onTap: () {
              setState(() {
                _filterRead = false;
                _filterType = null;
              });
              _loadData();
            },
          ),
          _FilterChip(
            label: 'Enrollment',
            icon: Icons.school_rounded,
            selected: _filterType == 'Enrollment',
            accent: accent,
            onTap: () {
              setState(() {
                _filterType = _filterType == 'Enrollment' ? null : 'Enrollment';
                _filterRead = null;
              });
              _loadData();
            },
          ),
          _FilterChip(
            label: 'Assignment',
            icon: Icons.assignment_rounded,
            selected: _filterType == 'Assignment',
            accent: accent,
            onTap: () {
              setState(() {
                _filterType = _filterType == 'Assignment' ? null : 'Assignment';
                _filterRead = null;
              });
              _loadData();
            },
          ),
          _FilterChip(
            label: 'Grade',
            icon: Icons.grade_rounded,
            selected: _filterType == 'Grade',
            accent: accent,
            onTap: () {
              setState(() {
                _filterType = _filterType == 'Grade' ? null : 'Grade';
                _filterRead = null;
              });
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NotificationState state, Color accent) {
    if (state is NotificationLoading) {
      return _buildSkeletonList(accent);
    }

    List<NotificationModel> items = [];
    bool hasMore = false;
    Set<int> markingIds = {};

    if (state is NotificationLoaded) {
      items = state.items;
      hasMore = state.hasMore;
    } else if (state is NotificationLoadingMore) {
      items = state.currentItems;
      hasMore = true;
    } else if (state is NotificationMarkingRead) {
      items = state.items;
      if (state.markingId != null) markingIds.add(state.markingId!);
    }

    if (items.isEmpty) {
      return _buildEmptyState(accent);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index >= items.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: accent,
                ),
              ),
            ),
          );
        }

        final notification = items[index];
        return NotificationTile(
          notification: notification,
          isMarking: markingIds.contains(notification.id),
          onTap: () {
            if (!notification.isRead) {
              context.read<NotificationCubit>().markAsRead(
                token: widget.token,
                notificationId: notification.id,
              );
            }
            // TODO: navigate to referenceActivityId if needed
          },
          onMarkRead: () {
            context.read<NotificationCubit>().markAsRead(
              token: widget.token,
              notificationId: notification.id,
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonList(Color accent) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 6,
      itemBuilder: (_, __) => _SkeletonTile(),
    );
  }

  Widget _buildEmptyState(Color accent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 36,
              color: const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "You're all caught up. We'll notify you\nwhen something new arrives.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? accent : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: selected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton tile ────────────────────────────────────────────────────────────
class _SkeletonTile extends StatefulWidget {
  @override
  State<_SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<_SkeletonTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: 0.4 + 0.3 * _anim.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Container(
                        height: 13,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 11,
                        width: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
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
