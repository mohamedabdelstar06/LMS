import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/Enrollment_course/state_mangment/states.dart';
import '../../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../../core/helpers/cach_helper/shared_pref_helper.dart';

class EnrollmentCubit extends Cubit<EnrollmentState> {
  EnrollmentCubit() : super(EnrollmentInitial());

  final Dio dio = Dio(BaseOptions(baseUrl: ApiResources.apiUrl));

  List<EnrollmentModel> _enrollments = [];

  List<EnrollmentModel> get enrollments => List.unmodifiable(_enrollments);

  Future<void> createEnrollment({
    required int studentId,
    required int courseId,
    required String userName,
    required String courseName,
  }) async {
    try {
      emit(EnrollmentLoading());

      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(const EnrollmentError("Unauthorized"));
        return;
      }

      final response = await dio.post(
        ApiResources.addEnrollmentEndPoint,
        data: {
          "studentId": studentId,
          "courseId": courseId,
        },
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newEnrollment = EnrollmentModel(
          userId: studentId,
          userName: userName,
          courseId: courseId,
          courseName: courseName,
        );

        _enrollments = [..._enrollments, newEnrollment];

        emit(EnrollmentLoaded(_enrollments));
        emit(const EnrollmentActionSuccess("Enrollment added successfully"));
      } else {
        emit(EnrollmentError("Server Error: ${response.statusCode}"));
      }
    } catch (e) {
      emit(EnrollmentError(e.toString()));
    }
  }

  Future<void> deleteEnrollment(int userId, int courseId) async {
    try {
      emit(EnrollmentLoading());

      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null) {
        emit(const EnrollmentError("Unauthorized"));
        return;
      }

      final response = await dio.delete(
        "/Enrollment/student/$userId/course/$courseId",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _enrollments = _enrollments
            .where((e) =>
        !(e.userId == userId && e.courseId == courseId))
            .toList();

        emit(EnrollmentLoaded(_enrollments));
        emit(const EnrollmentActionSuccess("Enrollment deleted successfully"));
      } else {
        emit(const EnrollmentError("Delete failed"));
      }
    } catch (e) {
      emit(EnrollmentError(e.toString()));
    }
  }
}
