import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart'; // Required for MediaType
import '../../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import 'create_dep_state.dart';

class DepartmentCubit extends Cubit<DepartmentState> {
  DepartmentCubit() : super(DepartmentInitial());

  final Dio dio = Dio(BaseOptions(baseUrl: ApiResources.apiUrl));

  Future<void> createDepartment(
     TextEditingController fullNameController,
     TextEditingController descriptionController,
     String headName,
    Uint8List? imageBytes,
  ) async {
    try {
      emit(DepartmentLoading());

      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(DepartmentError('You are not authorized. Token missing.'));
        return;
      }

      final formData = FormData.fromMap({
        'name': fullNameController.text.trim(),
        'description': descriptionController.text.trim(),
        'headName': headName,
        if (imageBytes != null)
          'image': MultipartFile.fromBytes(
            imageBytes,
            filename: 'department.png',
            contentType: MediaType('image', 'png'),
          ),
      });

      final response = await dio.post(
        ApiResources.createDepartmentEndPoint,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(DepartmentSuccess('Department created successfully'));
      } else {
        emit(DepartmentError('Failed: ${response.statusMessage}'));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? e.message ?? 'Connection Error';
      emit(DepartmentError(errorMsg));
    } catch (e) {
      emit(DepartmentError(e.toString()));
    }
  }
}