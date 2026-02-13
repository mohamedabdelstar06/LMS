import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/cons/context/navigation_key.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../../admin/courses/home_courses/view.dart';
import '../../../instructor/home_courses/view.dart';
import '../../../student/student_courses/view.dart';
import '../user_model/data.dart';
import 'activate_state.dart';

class ActivateCubit extends Cubit<ActivateState> {
  ActivateCubit() : super(ActivateInitialState());

  Future<void> postActivateData(
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController confirmPasswordController,
      BuildContext context,
      ) async {
    final validationMessage = _validateInputs(
      email: emailController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    if (validationMessage != null) {
      _showSnackBar(message: validationMessage, isError: true);
      return;
    }

    emit(LoadingSActivateState());

    try {
      final response = await Dio(
        BaseOptions(
          baseUrl: ApiResources.apiUrl,
          validateStatus: (status) => true,
        ),
      ).post(
        ApiResources.activateUserEmailEndPoint,
        data: {
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "confirmPassword": confirmPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        final model = ActivateUserModel.fromJson(response.data);

        final token = response.data['token'];
        if (token != null && token.toString().isNotEmpty) {
          await TokenStorageHelper.saveTokenSecure(token);
        }

        await ActivateUserPrefs.saveActivateUserData(model);

        emit(ActivateSuccessState());

        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        _showSnackBar(
          message: response.data["message"] ?? "Account activated successfully",
        );

        if (model.user.role == "Student") {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (_) => StudentCourseScreen()),
          );
        } else if (model.user.role == "Instructor") {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (_) => TeacherCourseScreen()),
          );
        } else {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (_) => AdminCourseScreen()),
          );
        }
      } else {
        emit(ActivateErrorState());
        _showSnackBar(
          message: response.data["message"] ?? "Activation failed",
          isError: true,
        );
      }
    } on DioException catch (e) {
      emit(ActivateErrorState());

      String errorMessage = "Network error occurred";

      if (e.response?.data is Map) {
        errorMessage = e.response?.data["message"] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout, please try again";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Server is not responding";
      }

      _showSnackBar(message: errorMessage, isError: true);
    } catch (e) {
      emit(ActivateErrorState());
      _showSnackBar(
        message: "Unexpected error, please try again",
        isError: true,
      );
    }
  }

  String? _validateInputs({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (email.isEmpty) {
      return "Email is required";
    }

    // if (!email.endsWith("@gmail.com")) {
    //   return "Email must be a valid Gmail address";
    // }

    if (password.isEmpty) {
      return "Password is required";
    }

    if (password.length < 7) {
      return "Password must be at least 8 characters";
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain at least one capital letter";
    }

    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    return null;
  }

  void _showSnackBar({
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor:
        isError ? Colors.redAccent : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }
}
