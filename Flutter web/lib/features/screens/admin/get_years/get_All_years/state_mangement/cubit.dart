
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';

import 'package:lms/features/screens/admin/get_years/get_All_years/state_mangement/states.dart';

import '../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../all_model/model.dart';

class AllYearsCubit extends Cubit<AllYearsState> {
  AllYearsCubit() : super(YearsInitial());

  final Dio dio = Dio(
    BaseOptions(baseUrl: ApiResources.apiUrl),
  );

  Future<void> fetchYearss() async {
    emit(YearsLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      final response = await dio.get(
        ApiResources.getYearEndPoint,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final years = (response.data as List)
          .map((e) => GetAllYearModel.fromJson(e))
          .toList();

      emit(YearsLoaded(years));
    } catch (e) {
      emit(YearsError(e.toString()));
    }
  }

  Future<void> deleteYear(int id) async {
    emit(DeleteYearLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit(const DeleteYearError("Unauthorized: No token provided"));
        return;
      }

      final response = await dio.delete(
        "${ApiResources.getYearEndPoint}/$id",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const DeleteYearSuccess("Year deleted successfully"));
        await fetchYearss();
      } else {
        emit(DeleteYearError("Failed to delete year. Status code: ${response.statusCode}"));
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to delete year";

      if (e.response != null) {
        errorMessage = "Server error: ${e.response?.statusCode}";
        if (e.response?.data is Map &&
            e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
      } else {
        errorMessage = "Network error: ${e.message}";
      }

      emit(DeleteYearError(errorMessage));
    } catch (e) {
      emit(DeleteYearError("Unexpected error: ${e.toString()}"));
    }
  }

  Future<void> updateYears({
    required int id,
    required String name,
    required String description,
    required int headId,
  }) async {
    emit(UpdateYearLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null) {
        emit(const UpdateYearError("Unauthorized"));
        return;
      }

      final response = await dio.put(
        "${ApiResources.getYearEndPoint}/$id",
        data: {
          "name": name,
          "description": description,
          "headId": headId,
        },
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        emit(const UpdateYearSuccess("Year updated successfully"));
        await fetchYearss();
      } else {
        emit(UpdateYearError("Failed to update year. Status code: ${response.statusCode}"));
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to update year";

      if (e.response != null) {
        errorMessage = "Server error: ${e.response?.statusCode}";
        if (e.response?.data is Map &&
            e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
      } else {
        errorMessage = "Network error: ${e.message}";
      }

      emit(UpdateYearError(errorMessage));
    } catch (e) {
      emit(UpdateYearError("Unexpected error: ${e.toString()}"));
    }
  }
}