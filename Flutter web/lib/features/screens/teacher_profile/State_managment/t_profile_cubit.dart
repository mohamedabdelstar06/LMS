import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../user_model/view.dart';
import 't_profile_state.dart';
import '../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiResources.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<void> getProfileData() async {
    emit(ProfileLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null) {
        emit(ProfileError('Token not found, please login again'));
        return;
      }

      final response = await dio.get(
        ApiResources.getProfileEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final userJson = response.data['user'];
      final user = ProfileUserData.fromJson(userJson);

      if (user.role == "Admin" || user.role == "Instructor") {
        emit(NavigateToTeacherProfile(user));
      } else if (user.role == "Student") {
        emit(NavigateToStudentProfile(user));
      } else {
        emit(ProfileError('Unknown role: ${user.role}'));
      }
    } on DioException catch (e) {
      emit(ProfileError(e.response?.data['message'] ?? 'Failed to load profile'));
    } catch (e) {
      emit(ProfileError('Unexpected error occurred'));
    }
  }
}
