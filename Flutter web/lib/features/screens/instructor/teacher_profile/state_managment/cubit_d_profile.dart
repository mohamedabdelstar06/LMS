import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/instructor/teacher_profile/state_managment/state_d_profile.dart';


import '../../../../../core/cons/api_helper_resources/api_resources.dart';

import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../../../../core/helpers/profile_response_parser.dart';


class TeacherProfileCubit extends Cubit<TeacherProfileState> {
  TeacherProfileCubit() : super(TeacherProfileInitial());

  Future<void> getProfile() async {
    emit(TeacherProfileLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit( TeacherProfileError(message: 'You are not authorized. Token missing.'));
        return;
      }

      final response = await Dio(BaseOptions(
        baseUrl: ApiResources.apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
          // 'Content-Type': 'application/json',
        },
      )).get(ApiResources.getProfileEndpoint);

      if (response.statusCode == 200) {
        final model = parseTeacherProfileResponse(response.data);
        emit(TeacherProfileLoaded(profile: model));
      } else {
        emit(TeacherProfileError(
            message: response.data['message'] ?? 'Failed to load profile'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout, please try again';
      }

      emit(TeacherProfileError(message: errorMessage));
    } catch (e) {
      emit(TeacherProfileError(message: 'Unexpected error: $e'));
    }
  }
  Future<void> updateProfile({
    String? city,
    DateTime? dateOfBirth,
    MultipartFile? photo,
  }) async {
    emit(TeacherProfileLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(TeacherProfileError(message: 'Unauthorized'));
        return;
      }

      final dio = Dio(BaseOptions(
        baseUrl: ApiResources.apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ));

      final formData = FormData.fromMap({
        if (city != null) 'city': city,
        if (dateOfBirth != null)
          'dateOfBirth':
          DateFormat('yyyy-MM-dd').format(dateOfBirth),
        if (photo != null) 'profileImage': photo,
      });

      final response = await dio.patch(
        ApiResources.getProfileEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final model = parseTeacherProfileResponse(response.data);
        emit(TeacherProfileLoaded(profile: model));
      } else {
        emit(TeacherProfileError(message: 'Failed to update profile'));
      }
    } on DioException catch (e) {
      emit(
        TeacherProfileError(
          message: e.response?.data['message'] ?? 'Update failed',
        ),
      );
    }
  }
}
