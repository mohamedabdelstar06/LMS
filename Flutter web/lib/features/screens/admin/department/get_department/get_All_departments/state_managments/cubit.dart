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
 
    Future<void> fetchDepartmentById(int id) async {
    emit(DepartmentByIdLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(DepartmentByIdError("Unauthorized: Please login again."));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        "${ApiResources.apiUrl}${ApiResources.getDepartmentEndPoint}/$id",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final department = GetAllDepartmentModel.fromJson(response.data);
        emit(DepartmentByIdLoaded(department));
      } else {
        emit(
          DepartmentByIdError(
            "Failed to load department. Status: ${response.statusCode}",
          ),
        );
      }
    } on DioException catch (e) {
      emit(
        DepartmentByIdError(
          e.response != null
              ? "Server Error: ${e.response?.statusCode}"
              : "Connection Error",
        ),
      );
    }
  }

  Future<void> updateDepartment(GetAllDepartmentModel model) async {
    emit(UpdateDepartmentLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(DepartmentByIdError("Unauthorized: Please login again."));
        return;
      }

      final dio = Dio();
      final response = await dio.put(
        "${ApiResources.apiUrl}${ApiResources.getDepartmentEndPoint}/${model.id}",
        data: model.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(UpdateDepartmentSuccess("Department updated successfully"));
        fetchDepartments();
      } else {
        emit(
          DepartmentByIdError(
            "Failed to update department. Status: ${response.statusCode}",
          ),
        );
      }
    } on DioException catch (e) {
      emit(
        DepartmentByIdError(
          e.response != null
              ? "Server Error: ${e.response?.statusCode}"
              : "Connection Error",
        ),
      );
    }
  }

}

