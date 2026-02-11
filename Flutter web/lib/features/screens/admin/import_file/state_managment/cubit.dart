
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:lms/features/screens/admin/import_file/state_managment/states.dart';
import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../model/model.dart';


class ImportStudentsCubit extends Cubit<ImportStudentsState> {
  ImportStudentsCubit() : super(ImportStudentsInitial());

  final Dio dio = Dio(
    BaseOptions(baseUrl: ApiResources.apiUrl),
  );

  Future<void> uploadCSVFile(String filePath, List<int> fileBytes, String fileName) async {
    emit(ImportStudentsLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null) {
        emit(ImportStudentsError("Unauthorized: No token found"));
        return;
      }

      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        "${ApiResources.apiUrl}${ApiResources.importStudentsEndPoint}",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        final importResponse = ImportStudentsResponseModel.fromJson(response.data);
        emit(ImportStudentsSuccess(importResponse));
      } else {
        emit(ImportStudentsError('Failed to upload file: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        emit(ImportStudentsError(
            'Server error: ${e.response?.data['message'] ?? e.message}'));
      } else {
        emit(ImportStudentsError('Network error: ${e.message}'));
      }
    } catch (e) {
      emit(ImportStudentsError('Unexpected error: ${e.toString()}'));
    }
  }

  void resetState() {
    emit(ImportStudentsInitial());
  }
}