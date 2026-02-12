import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import '../model_dropdown/view.dart';
import 'states.dart' hide UsersState;

class UsersCubitDrop extends Cubit<UsersStateDrop> {
  UsersCubitDrop() : super(UsersInitialState());

  Future<void> fetchAdminsAndInstructors() async {
    emit(UsersLoadingState());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(UsersErrorState("Unauthorized"));
        return;
      }

      final allUsers = await _fetchAllUsers(token);

      final filteredUsers = allUsers
          .where((u) =>
      u.role.toLowerCase() == "admin" ||
          u.role.toLowerCase() == "instructor")
          .toList();

      emit(UsersLoadedState(filteredUsers));
    } catch (e) {
      emit(UsersErrorState("Failed to load users"));
    }
  }

  Future<void> fetchStudents() async {
    emit(UsersLoadingState());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(UsersErrorState("Unauthorized"));
        return;
      }

      final allUsers = await _fetchAllUsers(token);

      final students = allUsers
          .where((u) => u.role.toLowerCase() == "student")
          .toList();

      emit(UsersLoadedState(students));
    } catch (e) {
      emit(UsersErrorState("Failed to load users"));
    }
  }

  Future<List<UserLiteModel>> _fetchAllUsers(String token) async {
    final List<UserLiteModel> allUsers = [];
    int page = 1;
    bool hasNext = true;

    while (hasNext) {
      final response = await Dio().get(
       "${ApiResources.apiUrl}${ApiResources.getUsersEndPoint}",
        queryParameters: {
          'pageNumber': page,
          'pageSize': 100,
        },
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode != 200 || response.data['users'] == null) {
        throw Exception("Failed to fetch users from server");
      }

      final List usersJson = response.data['users'];
      allUsers.addAll(usersJson.map((e) => UserLiteModel.fromJson(e)));

      final int totalPages = response.data['totalPages'] ?? 1;
      page++;
      hasNext = page <= totalPages;
    }

    return allUsers;
  }
}
