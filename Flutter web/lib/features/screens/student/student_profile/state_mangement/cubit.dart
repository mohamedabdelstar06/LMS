
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../ProfileModel/view.dart';
import 'states.dart';

class StudentProfileCubit extends Cubit<StudentProfileState> {
  StudentProfileCubit() : super(StudentProfileInitial());


  Future<void> getProfile() async {
    emit(StudentProfileLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(StudentProfileError(message: "Unauthorized, token missing"));
        return;
      }

      final response = await Dio(
        BaseOptions(
          baseUrl: ApiResources.apiUrl,
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      ).get(ApiResources.getProfileEndpoint);

      if (response.statusCode == 200) {
        emit(
          StudentProfileLoaded(
            profile: StudentProfileModel.fromJson(response.data),
          ),
        );
      } else {
        emit(StudentProfileError(
          message: response.data["message"] ?? "Failed to load profile",
        ));
      }
    } catch (e) {
      emit(StudentProfileError(message: "Unexpected error: $e"));
    }
  }


  Future<void> updateProfile({
    String? city,
    DateTime? dateOfBirth,
    MultipartFile? photo,
  }) async {
    emit(StudentProfileLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(StudentProfileError(message: "Unauthorized"));
        return;
      }

      final dio = Dio(BaseOptions(
        baseUrl: ApiResources.apiUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ));

      final formData = FormData.fromMap({
        if (city != null) "city": city,
        if (dateOfBirth != null)
          "dateOfBirth":
          DateFormat('yyyy-MM-dd').format(dateOfBirth),
        if (photo != null) "profileImage": photo,
      });

      final response = await dio.patch(
        ApiResources.getProfileEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        final model = StudentProfileModel.fromJson(response.data);
        emit(StudentProfileLoaded(profile: model));
      } else {
        emit(StudentProfileError(message: "Failed to update profile"));
      }
    } on DioException catch (e) {
      emit(
        StudentProfileError(
          message: e.response?.data["message"] ?? "Update failed",
        ),
      );
    }
  }






  String formatUiDate(DateTime date) {
    return DateFormat("dd/MM/yyyy").format(date);
  }
}
