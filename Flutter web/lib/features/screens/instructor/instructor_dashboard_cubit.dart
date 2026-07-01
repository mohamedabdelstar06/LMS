import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';

import 'instructor_dashboard_model.dart';
import 'instructor_dashboard_states.dart';

class InstructorDashboardCubit extends Cubit<InstructorDashboardState> {
  InstructorDashboardCubit() : super(InstructorDashboardInitial());

  final Dio dio = Dio();

  Future<void> loadDashboard() async {
    emit(InstructorDashboardLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(InstructorDashboardError('Unauthorized. Token missing.'));
        return;
      }

      final response = await dio.get(
        '${ApiResources.apiUrl}Dashboard/instructor',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final model = InstructorDashboardModel.fromJson(response.data);
      emit(InstructorDashboardLoaded(model));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(InstructorDashboardError('Unauthorized. Please login again.'));
      } else {
        emit(
          InstructorDashboardError(
            e.response?.data?['message'] ?? e.message ?? 'Connection error',
          ),
        );
      }
    } catch (e) {
      emit(InstructorDashboardError(e.toString()));
    }
  }
}
/*import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';

import 'instructor_dashboard_model.dart';
import 'instructor_dashboard_states.dart';

class InstructorDashboardCubit extends Cubit<InstructorDashboardState> {
  InstructorDashboardCubit() : super(InstructorDashboardInitial());

  final Dio dio = Dio();

  Future<void> loadDashboard() async {
    emit(InstructorDashboardLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(InstructorDashboardError('غير مصرح. Token مفقود.'));
        return;
      }

      final response = await dio.get(
        '${ApiResources.apiUrl}Dashboard/instructor',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final model = InstructorDashboardModel.fromJson(response.data);
      emit(InstructorDashboardLoaded(model));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(InstructorDashboardError('غير مصرح. يرجى تسجيل الدخول مجدداً.'));
      } else {
        emit(
          InstructorDashboardError(
            e.response?.data?['message'] ?? e.message ?? 'Connection error',
          ),
        );
      }
    } catch (e) {
      emit(InstructorDashboardError(e.toString()));
    }
  }
}
*/