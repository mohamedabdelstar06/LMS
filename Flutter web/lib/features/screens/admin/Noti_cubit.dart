import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/Noti_repo.dart';
import 'package:lms/features/screens/admin/Noti_states.dart';
import 'package:lms/features/screens/admin/Notifications_model.dart';



class NotificationCubit extends Cubit<NotificationState> {

  NotificationCubit({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepository(),
      super(NotificationInitial());
  final NotificationRepository _repository;

  int _currentPage = 1;
  List<NotificationModel> _allItems = [];
  int _unreadCount = 0;

  Future<void> fetchUnreadCount(String token) async {
    try {
      final count = await _repository.getUnreadCount(token: token);
      _unreadCount = count;
      emit(NotificationUnreadCountLoaded(count));
    } catch (e) {
      // Silently fail for badge — don't disrupt main UI
    }
  }

  Future<void> loadNotifications({
    required String token,
    bool? isRead,
    String? type,
  }) async {
    if (token.isEmpty) {
      emit(NotificationError('You are not authorized. Token missing.'));
      return;
    }

    emit(NotificationLoading());
    _currentPage = 1;
    _allItems = [];

    try {
      final response = await _repository.getNotifications(
        token: token,
        pageNumber: _currentPage,
        isRead: isRead,
        type: type,
      );

      _allItems = response.items;
      _unreadCount = response.unreadCount;

      emit(
        NotificationLoaded(
          items: List.unmodifiable(_allItems),
          totalCount: response.totalCount,
          currentPage: _currentPage,
          totalPages: response.totalPages,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  // ── Load next page (pagination) ────────────────────────────────────────────
  Future<void> loadMore({
    required String token,
    bool? isRead,
    String? type,
  }) async {
    final currentState = state;
    if (currentState is! NotificationLoaded || !currentState.hasMore) return;
    if (token.isEmpty) return;

    emit(
      NotificationLoadingMore(
        currentItems: _allItems,
        unreadCount: _unreadCount,
      ),
    );

    try {
      _currentPage++;
      final response = await _repository.getNotifications(
        token: token,
        pageNumber: _currentPage,
        isRead: isRead,
        type: type,
      );

      _allItems = [..._allItems, ...response.items];
      _unreadCount = response.unreadCount;

      emit(
        NotificationLoaded(
          items: List.unmodifiable(_allItems),
          totalCount: response.totalCount,
          currentPage: _currentPage,
          totalPages: response.totalPages,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      _currentPage--;
      emit(NotificationError(e.toString()));
    }
  }

  // ── Mark single notification as read ──────────────────────────────────────
  Future<void> markAsRead({
    required String token,
    required int notificationId,
  }) async {
    if (token.isEmpty) return;

    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Optimistic update
    _allItems = _allItems.map((n) {
      if (n.id == notificationId && !n.isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }
      return n;
    }).toList();

    emit(
      NotificationMarkingRead(
        items: List.unmodifiable(_allItems),
        unreadCount: _unreadCount,
        markingId: notificationId,
      ),
    );

    try {
      await _repository.markAsRead(token: token, id: notificationId);

      emit(
        NotificationLoaded(
          items: List.unmodifiable(_allItems),
          totalCount: currentState.totalCount,
          currentPage: _currentPage,
          totalPages: currentState.totalPages,
          unreadCount: _unreadCount,
        ),
      );
    } catch (e) {
      // Revert optimistic update
      _allItems = _allItems.map((n) {
        if (n.id == notificationId) {
          _unreadCount++;
          return n.copyWith(isRead: false);
        }
        return n;
      }).toList();

      emit(
        NotificationLoaded(
          items: List.unmodifiable(_allItems),
          totalCount: currentState.totalCount,
          currentPage: _currentPage,
          totalPages: currentState.totalPages,
          unreadCount: _unreadCount,
        ),
      );
    }
  }

  // ── Mark all as read ──────────────────────────────────────────────────────
  Future<void> markAllAsRead({required String token}) async {
    if (token.isEmpty) return;

    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Optimistic update
    _allItems = _allItems
        .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
    _unreadCount = 0;

    emit(
      NotificationMarkingRead(
        items: List.unmodifiable(_allItems),
        unreadCount: 0,
      ),
    );

    try {
      await _repository.markAllAsRead(token: token);

      emit(
        NotificationLoaded(
          items: List.unmodifiable(_allItems),
          totalCount: currentState.totalCount,
          currentPage: _currentPage,
          totalPages: currentState.totalPages,
          unreadCount: 0,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
