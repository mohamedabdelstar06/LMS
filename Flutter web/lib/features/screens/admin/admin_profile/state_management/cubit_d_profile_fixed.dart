import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/admin/admin_profile/state_management/state_d_profile.dart';

import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../../../../core/helpers/profile_response_parser.dart';

class AdminProfileCubit extends Cubit<AdminProfileState> {
  AdminProfileCubit() : super(AdminProfileInitial());

  Future<void> getProfile() async {
    emit(AdminProfileLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit(
          AdminProfileError(message: 'You are not authorized. Token missing.'),
        );
        return;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiResources.apiUrl,
          headers: {'Authorization': 'Bearer $token'},
          receiveDataWhenStatusError: true,
        ),
      );

      final response = await dio.get(ApiResources.getProfileEndpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final model = parseAdminProfileResponse(response.data);
        emit(AdminProfileLoaded(profile: model));
      } else {
        final message = response.data is Map
            ? response.data['message'] ??
                  'Failed to load profile (${response.statusCode})'
            : 'Failed to load profile (${response.statusCode})';
        emit(AdminProfileError(message: message));
      }
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        errorMessage = 'Session expired or unauthorized. Please log in again.';
      } else if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout, please try again';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      emit(AdminProfileError(message: errorMessage));
    } catch (e) {
      emit(AdminProfileError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> updateProfile({
    String? city,
    DateTime? dateOfBirth,
    MultipartFile? photo,
  }) async {
    emit(AdminProfileLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(AdminProfileError(message: 'Unauthorized'));
        return;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiResources.apiUrl,
          headers: {'Authorization': 'Bearer $token'},
          receiveDataWhenStatusError: true,
        ),
      );

      final formData = FormData.fromMap({
        if (city != null) 'city': city,
        if (dateOfBirth != null)
          'dateOfBirth': DateFormat('yyyy-MM-dd').format(dateOfBirth),
        if (photo != null) 'profileImage': photo,
      });

      final response = await dio.patch(
        ApiResources.getProfileEndpoint,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final model = parseAdminProfileResponse(response.data);
        emit(AdminProfileLoaded(profile: model));
      } else {
        final message = response.data is Map
            ? response.data['message'] ?? 'Failed to update profile'
            : 'Failed to update profile';
        emit(AdminProfileError(message: message));
      }
    } on DioException catch (e) {
      String errorMessage = 'Update failed';
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        errorMessage = 'Session expired. Please log in again.';
      } else if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      emit(AdminProfileError(message: errorMessage));
    } catch (e) {
      emit(AdminProfileError(message: 'Unexpected error: $e'));
    }
  }
}
