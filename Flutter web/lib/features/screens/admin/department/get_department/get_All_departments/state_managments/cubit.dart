import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/state_managments/states.dart';
import '../../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../all_model/model.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class DepartmentsCubit extends Cubit<DepartmentsState> {
  DepartmentsCubit() : super(DepartmentsInitial());

  final Dio dio = Dio(BaseOptions(baseUrl: ApiResources.apiUrl));

  Future<void> fetchDepartments() async {
    emit(DepartmentsLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      final response = await dio.get(
        ApiResources.getDepartmentEndPoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
        emit(const DeleteDepartmentError('Unauthorized: No token provided'));
        return;
      }

      final response = await dio.delete(
        '${ApiResources.getDepartmentEndPoint}/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const DeleteDepartmentSuccess('Department deleted successfully'));
        await fetchDepartments();
      } else {
        emit(
          DeleteDepartmentError(
            'Failed to delete department. Status code: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('====== DIO ERROR ======');
        print('Status Code: ${e.response?.statusCode}');
        print('Status Message: ${e.response?.statusMessage}');
        print('Response Data: ${e.response?.data}');
        print('Headers: ${e.response?.headers}');
        print('Request Path: ${e.requestOptions.path}');
        print('Request Data: ${e.requestOptions.data}');
        print('=======================');
      }

      String errorMessage = 'Failed to delete Department';

      if (e.response != null) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }

      emit(DeleteDepartmentError(errorMessage));
    } catch (e) {
      emit(DeleteDepartmentError('Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> fetchDepartmentById(int id) async {
    emit(DepartmentByIdLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const DepartmentByIdError('Unauthorized: Please login again.'));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '${ApiResources.apiUrl}${ApiResources.getDepartmentEndPoint}/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final department = GetAllDepartmentModel.fromJson(response.data);
        emit(DepartmentByIdLoaded(department));
      } else {
        emit(
          DepartmentByIdError(
            'Failed to load department. Status: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      emit(
        DepartmentByIdError(
          e.response != null
              ? 'Server Error: ${e.response?.statusCode}'
              : 'Connection Error',
        ),
      );
    }
  }

  Future<void> updateDepartment(
      int id,
      String name,
      String description,
      Uint8List? selectedImageBytes,
      String headName,
      ) async {
    emit(UpdateDepartmentLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const DepartmentByIdError('Unauthorized: Please login again.'));
        return;
      }

      final formData = FormData.fromMap({
        'Name': name,
        'Description': description,
        'HeadName': headName,
        if (selectedImageBytes != null)
          'Image': MultipartFile.fromBytes(
            selectedImageBytes,
            filename: 'Course.png',
            contentType: MediaType('image', 'png'),
          ),
      });

      final dio = Dio();
      print('Sending request to update department with id: $id');
      print('FormData: ${formData.fields} | Files: ${formData.files}');

      final response = await dio.put(
        '${ApiResources.apiUrl}${ApiResources.getDepartmentEndPoint}/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const UpdateDepartmentSuccess('Department updated successfully'));
        fetchDepartments();
      } else {
        emit(
          DepartmentByIdError(
            'Failed to update department. Status: ${response.statusCode} | Body: ${response.data}',
          ),
        );
      }
    } on DioException catch (e) {
      print('Dio Exception: $e');
      emit(
        DepartmentByIdError(
          e.response != null
              ? 'Server Error: ${e.response?.statusCode} | Data: ${e.response?.data}'
              : 'Connection Error',
        ),
      );
    } catch (e) {
      print('Unexpected Error: $e');
      emit(DepartmentByIdError('Unexpected Error: $e'));
    }
  }

}
