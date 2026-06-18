import 'package:lms/features/screens/admin/Notifications_model.dart';



abstract class NotificationState {}

// ── Initial ────────────────────────────────────────────────────────────────
class NotificationInitial extends NotificationState {}

// ── Loading ────────────────────────────────────────────────────────────────
class NotificationLoading extends NotificationState {}

class NotificationLoadingMore extends NotificationState {
  final List<NotificationModel> currentItems;
  final int unreadCount;

  NotificationLoadingMore({
    required this.currentItems,
    required this.unreadCount,
  });
}

// ── Loaded ─────────────────────────────────────────────────────────────────
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final int unreadCount;
  final bool hasMore;

  NotificationLoaded({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.unreadCount,
  }) : hasMore = currentPage < totalPages;
}

// ── Error ──────────────────────────────────────────────────────────────────
class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

// ── Action Results ─────────────────────────────────────────────────────────
class NotificationMarkingRead extends NotificationState {
  final List<NotificationModel> items;
  final int unreadCount;
  final int? markingId; // null = mark-all

  NotificationMarkingRead({
    required this.items,
    required this.unreadCount,
    this.markingId,
  });
}

// ── Unread count only (for badge) ─────────────────────────────────────────
class NotificationUnreadCountLoaded extends NotificationState {
  final int unreadCount;

  NotificationUnreadCountLoaded(this.unreadCount);
}
