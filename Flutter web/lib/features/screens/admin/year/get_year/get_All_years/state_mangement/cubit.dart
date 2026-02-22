import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/features/screens/admin/year/get_year/get_All_years/state_mangement/states.dart';
import '../../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../all_model/model.dart';

class AllYearsCubit extends Cubit<AllYearsState> {
  AllYearsCubit() : super(YearsInitial()) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiResources.apiUrl,
      receiveDataWhenStatusError: true,
      validateStatus: (status) {
        return status != null && status <= 500;
      },
    ),
  );


  Future<void> fetchYearss() async {
    emit(YearsLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      final response = await dio.get(
        ApiResources.getYearEndPoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final years = (response.data as List)
            .map((e) => GetAllYearModel.fromJson(e))
            .toList();

        emit(YearsLoaded(years));
      } else {
        emit(YearsError(
            'Failed to load years. Status Code: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      _handleDioError(e, emitYearsError: true);
    } catch (e) {
      emit(YearsError('Unexpected Error: ${e.toString()}'));
    }
  }


  Future<void> deleteYear(int id) async {
    emit(DeleteYearLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit(const DeleteYearError('Unauthorized: No token provided'));
        return;
      }

      final response = await dio.delete(
        '${ApiResources.getYearEndPoint}/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(const DeleteYearSuccess('Year deleted successfully'));
        await fetchYearss();
      } else {
        emit(DeleteYearError(
            'Failed to delete year. Status Code: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      _handleDioError(e, emitDeleteError: true);
    } catch (e) {
      emit(DeleteYearError('Unexpected Error: ${e.toString()}'));
    }
  }

  Future<void> updateYears({
    required int id,
    required String name,
    required String description,
    required String departmentName,
    required int departmentId,
    required int totalHours,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(UpdateYearLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit(const UpdateYearError('Unauthorized'));
        return;
      }
      if (departmentId == 0) {
        emit(const UpdateYearError('Please select a valid department'));
        return;
      }

      final response = await dio.put(
        '${ApiResources.getYearEndPoint}/$id',
        data: {
          'name': name,
          'description': description,
          'departmentName': departmentName,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'totalHours': totalHours,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        emit(const UpdateYearSuccess('Year updated successfully'));



        unawaited(fetchYearss());
      } else {
        emit(UpdateYearError(
            'Failed to update year. Status Code: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      _handleDioError(e, emitUpdateError: true);
    } catch (e) {
      emit(UpdateYearError('Unexpected Error: ${e.toString()}'));
    }
  }



  Future<void> fetchYearById(int id) async {
    emit(YearByIdLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token == null || token.isEmpty) {
        emit(const YearByIdError('Unauthorized: Please login again.'));
        return;
      }

      final response = await dio.get(
        '${ApiResources.getYearEndPoint}/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final year = GetAllYearModel.fromJson(response.data);
        emit(YearByIdLoaded(year));
      } else {
        emit(YearByIdError(
            'Failed to load year. Status Code: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      _handleDioError(e, emitYearByIdError: true);
    }
  }


  void _handleDioError(
      DioException e, {
        bool emitYearsError = false,
        bool emitDeleteError = false,
        bool emitUpdateError = false,
        bool emitYearByIdError = false,
      }) {
    String errorMessage = 'Something went wrong';
    int? statusCode;

    if (e.response != null) {
      statusCode = e.response?.statusCode;

      print('========= API ERROR =========');
      print('STATUS CODE: $statusCode');
      print('RESPONSE DATA: ${e.response?.data}');
      print('=============================');

      if (e.response?.data is Map &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      } else {
        errorMessage = 'Server Error: $statusCode';
      }
    } else {
      errorMessage = 'Network Error: ${e.message}';
    }

    if (emitYearsError) emit(YearsError(errorMessage));
    if (emitDeleteError) emit(DeleteYearError(errorMessage));
    if (emitUpdateError) emit(UpdateYearError(errorMessage));
    if (emitYearByIdError) emit(YearByIdError(errorMessage));
  }
}
