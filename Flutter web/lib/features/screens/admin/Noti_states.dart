import 'package:lms/features/screens/admin/Notifications_model.dart';



abstract class NotificationState {}

// ── Initial ────────────────────────────────────────────────────────────────
class NotificationInitial extends NotificationState {}

// ── Loading ────────────────────────────────────────────────────────────────
class NotificationLoading extends NotificationState {}

class NotificationLoadingMore extends NotificationState {

  NotificationLoadingMore({
    required this.currentItems,
    required this.unreadCount,
  });
  final List<NotificationModel> currentItems;
  final int unreadCount;
}

// ── Loaded ─────────────────────────────────────────────────────────────────
class NotificationLoaded extends NotificationState {

  NotificationLoaded({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.unreadCount,
  }) : hasMore = currentPage < totalPages;
  final List<NotificationModel> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final int unreadCount;
  final bool hasMore;
}

// ── Error ──────────────────────────────────────────────────────────────────
class NotificationError extends NotificationState {

  NotificationError(this.message);
  final String message;
}

// ── Action Results ─────────────────────────────────────────────────────────
class NotificationMarkingRead extends NotificationState { // null = mark-all

  NotificationMarkingRead({
    required this.items,
    required this.unreadCount,
    this.markingId,
  });
  final List<NotificationModel> items;
  final int unreadCount;
  final int? markingId;
}

// ── Unread count only (for badge) ─────────────────────────────────────────
class NotificationUnreadCountLoaded extends NotificationState {

  NotificationUnreadCountLoaded(this.unreadCount);
  final int unreadCount;
}
