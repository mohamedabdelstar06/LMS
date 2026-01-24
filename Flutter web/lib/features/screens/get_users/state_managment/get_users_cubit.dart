
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cons/api_helper_resources/api_resources.dart';

import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../get_user_model/view.dart';
import 'get_users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  int currentPage = 1;

  Future<void> getUsers({int page = 1}) async {
    emit(UsersLoading());

    try {
      final response = await DioHelper.getData(
        url: '${ApiResources.getusersEndPoint}?pageIndex=$page&pageSize=10',
      );

      if (response.data is List) {
        final users = (response.data as List)
            .map((e) => GetUserModel.fromJson(e))
            .toList();

        currentPage = page;

        emit(UsersLoaded(
          users: users,
          pageIndex: currentPage,
          totalPages: 1,
        ));
        return;
      }

      final usersResponse = UsersResponseModel.fromJson(response.data);

      currentPage = usersResponse.pageNumber;

      emit(UsersLoaded(
        users: usersResponse.users,
        pageIndex: usersResponse.pageNumber,
        totalPages: usersResponse.totalPages,
      ));
    } on DioException catch (e) {
      print('DIO ERROR => ${e.response?.statusCode}');
      print('DIO DATA => ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        emit(UsersUnauthorized());
      } else {
        emit(
          UsersError(e.response?.data.toString() ?? 'Server Error'),
        );
      }
    } catch (e) {
      print('UNKNOWN ERROR => $e');

      if (e.toString().contains('NO_TOKEN')) {
        emit(UsersUnauthorized());
      } else {
        emit(UsersError(e.toString()));
      }
    }
  }

  void nextPage() {
    if (state is UsersLoaded) {
      final loaded = state as UsersLoaded;
      if (loaded.pageIndex < loaded.totalPages) {
        getUsers(page: loaded.pageIndex + 1);
      }
    }
  }

  void previousPage() {
    if (state is UsersLoaded) {
      final loaded = state as UsersLoaded;
      if (loaded.pageIndex > 1) {
        getUsers(page: loaded.pageIndex - 1);
      }
    }
  }
}




class DioHelper {
  static Dio? dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiResources.apiUrl,
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Response> getData({
    required String url,
  }) async {
    if (dio == null) {
      init(); // 🔥 حماية
    }

    final token = await TokenStorageHelper.getTokenSecure();

    if (token == null || token.isEmpty) {
      throw Exception('NO_TOKEN');
    }

    dio!.options.headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json',
      // 'Accept': 'application/json',
    };

    return await dio!.get(url);
  }
}
