import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import '../get_user_model/view.dart';
import 'get_users_state.dart';

class GetUsersCubit extends Cubit<GetUsersState> {
  GetUsersCubit() : super(GetUsersInitial());

  final Dio _dio = Dio();

  
  String _searchQuery = '';
  int _filterStatus = 0;
  String _roleFilter = '';
  String _sortBy = 'createdAt';
  String _order = 'desc';

  int _currentPage = 1;
  List<GetUserModel> _allUsers = [];
  int _totalCount = 0;
  int _totalPages = 0;
  bool _hasNextPage = false;

  String get currentRoleFilter => _roleFilter;

  Future<void> loadUsers({
    String searchQuery = '',
    int filterStatus = 0,
    String roleFilter = '',
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    _searchQuery = searchQuery;
    _filterStatus = filterStatus;
    _roleFilter = roleFilter;
    _sortBy = sortBy;
    _order = order;

    _currentPage = 1;
    _allUsers = [];

    emit(GetUsersLoading());
    await _fetchPage();
  }

  
  Future<void> loadMore() async {
    if (state is! GetUsersLoaded) return;
    final loaded = state as GetUsersLoaded;
    if (!loaded.hasNextPage) return;

    emit(
      GetUsersLoadingMore(
        currentUsers: List.from(_allUsers),
        totalCount: _totalCount,
        currentPage: _currentPage,
        totalPages: _totalPages,
        searchQuery: _searchQuery,
        filterStatus: _filterStatus,
        sortBy: _sortBy,
        order: _order,
      ),
    );

    _currentPage++;
    await _fetchPage();
  }

  
  Future<void> filterUsers({
    String searchQuery = '',
    int filterStatus = 0,
    String roleFilter = '',
    String sortBy = 'createdAt',
    String order = 'desc',
  }) => loadUsers(
    searchQuery: searchQuery,
    filterStatus: filterStatus,
    roleFilter: roleFilter,
    sortBy: sortBy,
    order: order,
  );

  Future<void> searchUsers(String query) async {
    _searchQuery = query.isEmpty ? '' : query;
    await loadUsers(
      searchQuery: _searchQuery,
      filterStatus: _filterStatus,
      roleFilter: _roleFilter,
      sortBy: _sortBy,
      order: _order,
    );
  }

  Future<void> sortUsers({required String sortBy, String order = 'desc'}) {
    final cur = state;
    return loadUsers(
      searchQuery: cur is GetUsersLoaded ? cur.searchQuery : _searchQuery,
      filterStatus: cur is GetUsersLoaded ? cur.filterStatus : _filterStatus,
      roleFilter: cur is GetUsersLoaded ? cur.roleFilter : _roleFilter,
      sortBy: sortBy,
      order: order,
    );
  }

  Future<void> clearFilters() async {
    _searchQuery = '';
    _filterStatus = 0;
    _roleFilter = '';
    _sortBy = 'createdAt';
    _order = 'desc';
    await loadUsers();
  }

  

  Future<void> getUserById(int userId) async {
    emit(const GetUserByIdLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetUserByIdError('Unauthorized: Please login again.'));
        return;
      }
      final response = await _dio.get(
        '${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        emit(GetUserByIdSuccess(GetUserModel.fromJson(response.data)));
      } else {
        emit(
          GetUserByIdError(
            'Failed to load user. Status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      emit(
        GetUserByIdError(
          e.response?.data?['message'] ?? e.message ?? 'Connection error',
        ),
      );
    } catch (e) {
      emit(GetUserByIdError('Unexpected error: $e'));
    }
  }

  Future<void> updateUser({
    required int userId,
    required Map<String, dynamic> userData,
  }) async {
    emit(UpdateUsersLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const UpdateUsersError('Unauthorized: Please login again.'));
        return;
      }
      final response = await Dio().put(
        '${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}/$userId',
        data: userData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(
          UpdateUsersSuccess(
            'User updated successfully',
            statusCode: response.statusCode,
          ),
        );
      } else {
        emit(
          UpdateUsersError(
            'Failed to update user',
            statusCode: response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      emit(
        UpdateUsersError(
          e.response?.data?['message'] ??
              e.message ??
              'Error while updating user',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      emit(UpdateUsersError('Unexpected error: $e'));
    }
  }

  Future<void> deactivateUser(int userId) async {
    emit(DeactivateUserLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetUsersError('Unauthorized: Please login again.'));
        return;
      }
      final response = await _dio.delete(
        '${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        emit(const DeactivateUserSuccess('User deactivated successfully'));
        await loadUsers(
          searchQuery: _searchQuery,
          filterStatus: _filterStatus,
          sortBy: _sortBy,
          order: _order,
        );
      }
    } on DioException catch (e) {
      emit(
        DeactivateUserError(
          e.response?.data['message'] ?? 'Failed to deactivate user',
        ),
      );
    }
  }

  Future<void> deleteUser(int userId) async {
    emit(DeleteUserLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetUsersError('Unauthorized: Please login again.'));
        return;
      }
      final response = await _dio.delete(
        '${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}/$userId',
        queryParameters: {'hardDelete': true},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const DeleteUserSuccess('User deleted successfully'));
        await loadUsers(
          searchQuery: _searchQuery,
          filterStatus: _filterStatus,
          sortBy: _sortBy,
          order: _order,
        );
      } else {
        emit(const DeleteUserError('Failed to delete user'));
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ??
          e.response?.data.toString() ??
          e.message ??
          'Connection error';
      emit(DeleteUserError(msg));
    } catch (e) {
      emit(DeleteUserError('Unexpected error: $e'));
    }
  }

  

  Future<void> _fetchPage() async {
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetUsersError('Authentication required'));
        return;
      }

      final response = await _dio.get(
        '${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}',
        queryParameters: {
          'pageNumber': _currentPage,
          'pageSize': 10,
          'search': _searchQuery,
          'filterStatus': _filterStatus,
          if (_roleFilter.isNotEmpty) 'role': _roleFilter,
          'sortBy': _sortBy,
          'order': _order,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        emit(const GetUsersError('Invalid response from server'));
        return;
      }

      final usersResponse = AllUsersResponseModel.fromJson(response.data);

      if (_currentPage == 1) {
        _allUsers = usersResponse.users;
      } else {
        
        final existingIds = _allUsers.map((u) => u.id).toSet();
        final newUsers = usersResponse.users
            .where((u) => !existingIds.contains(u.id))
            .toList();
        _allUsers = [..._allUsers, ...newUsers];
      }

      _totalCount = usersResponse.totalCount;
      _totalPages = usersResponse.totalPages;
      _hasNextPage = usersResponse.hasNextPage;

      emit(
        GetUsersLoaded(
          users: List.from(_allUsers),
          totalCount: _totalCount,
          currentPage: _currentPage,
          totalPages: _totalPages,
          hasNextPage: usersResponse.hasNextPage,
          hasPreviousPage: usersResponse.hasPreviousPage,
          searchQuery: _searchQuery,
          filterStatus: _filterStatus,
          roleFilter: _roleFilter,
          sortBy: _sortBy,
          order: _order,
        ),
      );
    } on DioException catch (e) {
      emit(
        GetUsersError(
          e.response?.data.toString() ?? e.message ?? 'Network error',
        ),
      );
    } catch (e) {
      emit(const GetUsersError('Unexpected error occurred'));
    }
  }
}
