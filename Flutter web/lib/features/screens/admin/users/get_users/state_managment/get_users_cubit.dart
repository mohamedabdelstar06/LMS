import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';

import '../get_user_model/view.dart';
import 'get_users_state.dart';

class GetUsersCubit extends Cubit<GetUsersState> {
  GetUsersCubit() : super(GetUsersInitial());
  Dio dio = Dio();

  bool _isFetchingMore = false;

  // ─── Core fetch (used by all other methods) ───────────────────────────────
  Future<void> fetchUsers({
    int page = 1,
    String searchQuery = '',
    int filterStatus = 0,
    String sortBy = 'createdAt',
    String order = 'desc',
    bool silent = false, // true → don't emit Loading (used after update/delete)
  }) async {
    if (page == 1 && !silent) emit(GetUsersLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetUsersError('Authentication required'));
        return;
      }

      final response = await dio.get(
        '${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}',
        queryParameters: {
          'pageNumber': page,
          'pageSize': 10,
          'search': searchQuery,
          'filterStatus': filterStatus,
          'sortBy': sortBy,
          'order': order,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        emit(const GetUsersError('Invalid response from server'));
        return;
      }

      final usersResponse = AllUsersResponseModel.fromJson(response.data);

      // Merge pages (infinite scroll) ----------------------------------------
      if (page > 1) {
        final prevState = state;
        final prevUsers = prevState is GetUsersLoaded
            ? prevState.usersResponse.users
            : <GetUserModel>[];

        final mergedUsers = [
          ...prevUsers,
          ...usersResponse.users.where(
            (newUser) => !prevUsers.any((old) => old.id == newUser.id),
          ),
        ];

        final merged = usersResponse.copyWith(users: mergedUsers);
        emit(
          GetUsersLoaded(
            usersResponse: merged,
            searchQuery: searchQuery,
            currentPage: page,
            filterStatus: filterStatus,
            sortBy: sortBy,
            order: order,
          ),
        );
      } else {
        emit(
          GetUsersLoaded(
            usersResponse: usersResponse,
            searchQuery: searchQuery,
            currentPage: page,
            filterStatus: filterStatus,
            sortBy: sortBy,
            order: order,
          ),
        );
      }
    } on DioException catch (e) {
      emit(
        GetUsersError(
          e.response?.data.toString() ?? e.message ?? 'Network error',
        ),
      );
    } catch (e, stack) {
      print('❌ UNEXPECTED ERROR\n$e\n$stack');
      emit(const GetUsersError('Unexpected error occurred'));
    }
  }

  // ─── Infinite scroll: load next page ─────────────────────────────────────
  Future<void> loadMoreUsers() async {
    if (_isFetchingMore) return;
    final cur = state;
    if (cur is! GetUsersLoaded) return;
    if (!cur.usersResponse.hasNextPage) return;

    _isFetchingMore = true;

    // Emit a "loading more" signal while keeping existing list intact
    emit(cur.copyWith(isLoadingMore: true));

    await fetchUsers(
      page: cur.currentPage + 1,
      searchQuery: cur.searchQuery,
      filterStatus: cur.filterStatus,
      sortBy: cur.sortBy,
      order: cur.order,
    );

    _isFetchingMore = false;
  }

  // ─── Filter / Sort ────────────────────────────────────────────────────────
  Future<void> filterUsers({
    String searchQuery = '',
    int filterStatus = 0,
    String sortBy = 'createdAt',
  }) => fetchUsers(
    searchQuery: searchQuery,
    filterStatus: filterStatus,
    sortBy: sortBy,
  );

  Future<void> sortUsers({
    required String sortBy,
    String order = 'desc',
  }) async {
    if (state is! GetUsersLoaded) return;
    final cur = state as GetUsersLoaded;
    await fetchUsers(
      page: 1,
      searchQuery: cur.searchQuery,
      filterStatus: cur.filterStatus,
      sortBy: sortBy,
      order: order,
    );
  }

  // ─── Deactivate ───────────────────────────────────────────────────────────
  Future<void> deactivateUser(int userId) async {
    emit(DeactivateUserLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetUsersError('Unauthorized: Please login again.'));
        return;
      }
      final response = await dio.delete(
        '${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        emit(const DeactivateUserSuccess('User deactivated successfully'));
        await fetchUsers();
      }
    } on DioException catch (e) {
      emit(
        DeactivateUserError(
          e.response?.data['message'] ?? 'Failed to deactivate user',
        ),
      );
    }
  }

  // ─── Hard delete ─────────────────────────────────────────────────────────
  Future<void> deleteUser(int userId) async {
    final prevState = state;
    emit(DeleteUserLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetUsersError('Unauthorized: Please login again.'));
        return;
      }

      final response = await dio.delete(
        '${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}/$userId',
        queryParameters: {'hardDelete': true},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const DeleteUserSuccess('User deleted successfully'));
        if (prevState is GetUsersLoaded) {
          await fetchUsers(
            page: prevState.currentPage,
            searchQuery: prevState.searchQuery,
            filterStatus: prevState.filterStatus,
            sortBy: prevState.sortBy,
            order: prevState.order,
          );
        } else {
          await fetchUsers();
        }
      } else {
        emit(const DeleteUserError('Failed to delete user'));
        if (prevState is GetUsersLoaded) emit(prevState);
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ??
          e.response?.data.toString() ??
          e.message ??
          'Connection error';
      emit(DeleteUserError(msg));
      if (prevState is GetUsersLoaded) {
        await fetchUsers(
          page: prevState.currentPage,
          searchQuery: prevState.searchQuery,
          filterStatus: prevState.filterStatus,
          sortBy: prevState.sortBy,
          order: prevState.order,
        );
      }
    } catch (e) {
      emit(DeleteUserError('Unexpected error: $e'));
    }
  }

  // ─── Get single user ──────────────────────────────────────────────────────
  Future<void> getUserById(int userId) async {
    emit(const GetUserByIdLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const GetUserByIdError('Unauthorized: Please login again.'));
        return;
      }

      final response = await dio.get(
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

  // ─── Update user ─────────────────────────────────────────────────────────
  Future<void> updateUser({
    required int userId,
    required Map<String, dynamic> userData,
  }) async {
    // Remember current list state so we can restore it after the update
    final prevListState = state is GetUsersLoaded
        ? state as GetUsersLoaded
        : null;

    emit(UpdateUsersLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const UpdateUsersError('Unauthorized: Please login again.'));
        _restoreListState(prevListState);
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

        // Re-fetch silently so the list is fresh when the user navigates back
        await fetchUsers(
          page: prevListState?.currentPage ?? 1,
          searchQuery: prevListState?.searchQuery ?? '',
          filterStatus: prevListState?.filterStatus ?? 0,
          sortBy: prevListState?.sortBy ?? 'createdAt',
          order: prevListState?.order ?? 'desc',
          silent: true,
        );
      } else {
        emit(
          UpdateUsersError(
            'Failed to update user',
            statusCode: response.statusCode,
          ),
        );
        _restoreListState(prevListState);
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
      _restoreListState(prevListState);
    } catch (e) {
      emit(UpdateUsersError('Unexpected error: $e'));
      _restoreListState(prevListState);
    }
  }

  void _restoreListState(GetUsersLoaded? state) {
    if (state != null) emit(state);
  }
}
