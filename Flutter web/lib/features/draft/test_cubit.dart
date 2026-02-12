import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/draft/test_states.dart';
import '../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';

class EnrollmentCubit extends Cubit<EnrollmentState> {
  EnrollmentCubit() : super(EnrollmentInitial());

  final Dio dio = Dio(BaseOptions(baseUrl: ApiResources.apiUrl));

  Future<void> createEnrollment(int studentId, int courseId) async {
    try {
      emit(EnrollmentLoading());

      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(EnrollmentError("You are not authorized. Token missing."));
        return;
      }


      final response = await dio.post(
        ApiResources.addEnrollmentEndPoint,
        data: {
          "studentId": studentId,
          "courseId": courseId,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(EnrollmentSuccess("Enrollment created successfully"));
      } else {
        emit(EnrollmentError("Failed: ${response.statusMessage}"));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? e.message ?? "Connection Error";
      emit(EnrollmentError(errorMsg));
    } catch (e) {
      emit(EnrollmentError(e.toString()));
    }
  }
}

