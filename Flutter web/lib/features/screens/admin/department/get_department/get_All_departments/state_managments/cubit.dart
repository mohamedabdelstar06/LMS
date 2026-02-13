import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/state_managments/states.dart';
import '../../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../all_model/model.dart';


class DepartmentsCubit extends Cubit<DepartmentsState> {
  DepartmentsCubit() : super(DepartmentsInitial());

  final Dio dio = Dio(
    BaseOptions(baseUrl: ApiResources.apiUrl),
  );

  Future<void> fetchDepartments() async {
    emit(DepartmentsLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      final response = await dio.get(
        ApiResources.getDepartmentEndPoint,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final departments = (response.data as List)
          .map((e) => GetAllDepartmentModel.fromJson(e))
          .toList();

      emit(DepartmentsLoaded(departments));
    } catch (e) {
      emit(DepartmentsError(e.toString()));
    }
  }

  Future<void> deleteDepartment(int id) async {
    emit(DeleteDepartmentLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit(const DeleteDepartmentError("Unauthorized: No token provided"));
        return;
      }

      final response = await dio.delete(
        "${ApiResources.getDepartmentEndPoint}/$id",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const DeleteDepartmentSuccess("Department deleted successfully"));
        await fetchDepartments();
      } else {
        emit(DeleteDepartmentError("Failed to delete department. Status code: ${response.statusCode}"));
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to delete Department";

      if (e.response != null) {
        errorMessage = "Server error: ${e.response?.statusCode}";
        if (e.response?.data is Map &&
            e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
      } else {
        errorMessage = "Network error: ${e.message}";
      }

      emit(DeleteDepartmentError(errorMessage));
    } catch (e) {
      emit(DeleteDepartmentError("Unexpected error: ${e.toString()}"));
    }
  }
  Future<void> updateDepartment({
    required int id,
    required String name,
    required String description,
    required int headId,
  }) async {
    emit(UpdateDepartmentLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null) {
        emit(const UpdateDepartmentError("Unauthorized"));
        return;
      }

      await dio.put(
        "${ApiResources.getDepartmentEndPoint}/$id",
        data: {
          "name": name,
          "description": description,
          "headId": headId,
        },
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      emit(const UpdateDepartmentSuccess("Department updated successfully"));
      fetchDepartments();
    } catch (e) {
      emit(UpdateDepartmentError(e.toString()));
    }
  }
}

