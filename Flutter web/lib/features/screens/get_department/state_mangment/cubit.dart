import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/get_department/model/model.dart';
import 'package:lms/features/screens/get_department/state_mangment/states.dart';

import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';

class DepartmentsCubitDrop extends Cubit<DepartmentsStateDrop> {
  DepartmentsCubitDrop() : super(DepartmentInitialState());

  Future<void> fetchDepartments() async {
    emit(DepartmentLoadingState());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(DepartmentsErrorState("Unauthorized: No token provided"));
        return;
      }

      final dio = Dio();

      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      ));
      final response = await dio.get(
        "http://skylearn.runasp.net/api/Department",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List usersJson = response.data;
          final departments = usersJson
              .map((e) => GetDepartmentModel.fromJson(e))
              .where((department) => department != null)
              .cast<GetDepartmentModel>()
              .toList();

          emit(DepartmentLoadedState(departments));
        } else {
          emit(DepartmentsErrorState("Invalid response format: Expected a list"));
        }
      } else {
        emit(DepartmentsErrorState("Server error: ${response.statusCode}"));
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to load departments";
      if (e.response != null) {
        errorMessage = "Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}";
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout. Please check your internet connection.";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Receive timeout. Server is taking too long to respond.";
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = "Bad response: ${e.message}";
      }
      emit(DepartmentsErrorState(errorMessage));
    } catch (e) {
      emit(DepartmentsErrorState("Unexpected error: ${e.toString()}"));
    }
  }
}