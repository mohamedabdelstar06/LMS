import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/logs/state_mangement/repositery_fetch.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../model.dart';
import 'logs_state.dart';

class ActivityLogsCubit extends Cubit<ActivityLogsState> {

  ActivityLogsCubit(this._repository) : super(ActivityLogsInitial());
  final ActivityLogsRepository _repository;

  String? _activeComponent;
  String? _activeOrigin;
  String? _searchQuery;
  int _currentPage = 1;
  List<ActivityLog> _allLogs = [];
  int _totalCount = 0;
  int _totalPages = 0;

  Future<void> loadLogs() async {
    emit(ActivityLogsLoading());
    _currentPage = 1;
    _allLogs = [];
    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (state is! ActivityLogsLoaded) return;
    final loaded = state as ActivityLogsLoaded;
    if (!loaded.hasNextPage) return;

    emit(ActivityLogsLoadingMore(
      currentLogs: _allLogs,
      totalCount: _totalCount,
      currentPage: _currentPage,
      totalPages: _totalPages,
      activeComponent: _activeComponent,
      activeOrigin: _activeOrigin,
      searchQuery: _searchQuery,
    ));

    _currentPage++;
    await _fetchPage();
  }

  Future<void> applyFilter({String? component, String? origin}) async {
    _activeComponent = component;
    _activeOrigin = origin;
    await loadLogs();
  }

  Future<void> search(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    await loadLogs();
  }

  Future<void> clearFilters() async {
    _activeComponent = null;
    _activeOrigin = null;
    _searchQuery = null;
    await loadLogs();
  }

  Future<void> _fetchPage() async {
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(ActivityLogsError('Unauthorized: Please login again.'));
        return;
      }

      final response = await _repository.fetchLogs(
        token: token,
        pageNumber: _currentPage,
        component: _activeComponent,
        origin: _activeOrigin,
        search: _searchQuery,
      );

      if (_currentPage == 1) {
        _allLogs = response.logs;
      } else {
        _allLogs = [..._allLogs, ...response.logs];
      }

      _totalCount = response.totalCount;
      _totalPages = response.totalPages;

      emit(ActivityLogsLoaded(
        logs: List.from(_allLogs),
        totalCount: _totalCount,
        currentPage: _currentPage,
        totalPages: _totalPages,
        hasNextPage: response.hasNextPage,
        hasPreviousPage: response.hasPreviousPage,
        activeComponent: _activeComponent,
        activeOrigin: _activeOrigin,
        searchQuery: _searchQuery,
      ));
    } catch (e) {
      emit(ActivityLogsError(e.toString()));
    }
  }
}