import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:lms/features/draft/test_models.dart';
import 'package:lms/features/draft/test_states.dart';
import 'package:lms/features/screens/courses/admin/state_managment/states.dart';
import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../model/model.dart';

class GetCourseCubit extends Cubit<GetCourseState> {
  GetCourseCubit() : super(GetCourseInitial());

  Future<void> getCourses() async {
    emit(GetCourseLoading());

    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(GetCourseError("You are not authorized. Token missing."));
        return;
      }

      final response = await http.get(
        Uri.parse("${ApiResources.apiUrl}${ApiResources.getCourseEndPoint}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        final List<GetCourseModel> courses = data
            .map<GetCourseModel>((e) => GetCourseModel.fromJson(e))
            .toList();

        emit(GetCourseSuccess(courses));
      } else if (response.statusCode == 401) {
        emit(GetCourseError("Unauthorized. Please login again."));
      } else {
        emit(GetCourseError("Failed to load courses"));
      }
    } catch (e) {
      emit(GetCourseError(e.toString()));
    }
  }
}

