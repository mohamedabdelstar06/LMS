import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/dashboard_screen.dart';
import 'package:lms/features/screens/student_dashboard_screen.dart';


import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/cons/context/navigation_key.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../../admin/courses/home_courses/view.dart';
import '../../../instructor/home_courses/view.dart';
import '../../../student/student_courses/view.dart';
import '../user_model/data.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitialState());


  String? _validateInputs({
    required String email,
    required String password,
  }) {
    if (email.isEmpty) {
      return "Email is required";
    }

    // if (!email.endsWith("@gmail.com")) {
    //   return "Please enter a valid Gmail address";
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

    return null;
  }


  Future<void> postLoginData(
      TextEditingController emailController,
      TextEditingController passwordController,
      BuildContext context,
      ) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final validationMessage = _validateInputs(
      email: email,
      password: password,
    );

    if (validationMessage != null) {
      emit(LoginErrorState());
      _showSnackBar(message: validationMessage, isError: true);
      return;
    }

    emit(LoadingLoginState());

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiResources.apiUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.post(
        ApiResources.loginEndPoint,
        data: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final model = UserModel.fromJson(response.data);

        await PrefHelper.saveLoginData(model);
        await TokenStorageHelper.saveTokenSecure(response.data['token']);

        emailController.clear();
        passwordController.clear();

        emit(LoginSuccessState());

        _showSnackBar(
          message: response.data["message"] ?? "Login successful",
          isError: false,
        );

        if (model.user.role == "Student") {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => const StudentCourseScreen(),
            ),
          );
        } else if (model.user.role == "Instructor") {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => const TeacherCourseScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen(),
            ),
          );
        }
      } else {
        emit(LoginErrorState());
        _showSnackBar(
          message: "Invalid email or password",
          isError: true,
        );
      }
    } on DioException catch (e) {
      emit(LoginErrorState());

      String errorMessage;

      if (e.response != null) {
        final statusCode = e.response?.statusCode;

        switch (statusCode) {
          case 400:
            errorMessage = "Invalid email or password";
            break;
          case 401:
            errorMessage = "Unauthorized access";
            break;
          case 404:
            errorMessage = "Account not found";
            break;
          case 500:
            errorMessage = "Server error, please try again later";
            break;
          default:
            errorMessage =
                e.response?.data["message"] ?? "Login failed";
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = "Connection timeout, please check your internet";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "No internet connection";
      } else {
        errorMessage = "Unexpected error occurred";
      }

      _showSnackBar(message: errorMessage, isError: true);
    } catch (e) {
      emit(LoginErrorState());
      _showSnackBar(
        message: "Unexpected error: ${e.toString()}",
        isError: true,
      );
    }
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
/*
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/cons/context/navigation_key.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../../courses/admin/view.dart';
import '../../../courses/teacher/view.dart';
import '../../../student/student_courses/view.dart';
import '../user_model/data.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitialState());

  String? _validateInputs({
    required String email,
    required String password,
  }) {
    if (email.isEmpty) return "Email is required";
    if (password.isEmpty) return "Password is required";
    if (password.length < 7) return "Password must be at least 8 characters";
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain at least one capital letter";
    }
    return null;
  }

  Future<void> postLoginData(
      TextEditingController emailController,
      TextEditingController passwordController,
      BuildContext context,
      ) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final validationMessage = _validateInputs(
      email: email,
      password: password,
    );

    if (validationMessage != null) {
      emit(LoginErrorState());
      _showSnackBar(message: validationMessage, isError: true);
      return;
    }

    emit(LoadingLoginState());

    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiResources.apiUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      print("Sending login request for email: $email");

      final response = await dio.post(
        ApiResources.loginEndPoint,
        data: {
          "email": email,
          "password": password,
        },
      );

      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        final model = UserModel.fromJson(response.data);

        print("User model: $model");
        print("User id: ${model.user?.id}");
        print("User fullName: ${model.user?.fullName}");
        print("User role: ${model.user?.role}");

        // حفظ البيانات
        await PrefHelper.saveLoginData(model);
        await TokenStorageHelper.saveTokenSecure(model.token ?? '');

        emailController.clear();
        passwordController.clear();

        emit(LoginSuccessState());

        _showSnackBar(
          message: model.message ?? "Login successful",
          isError: false,
        );

        final role = model.user.role ?? '';
        if (role == "Student") {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (_) => const StudentCourseScreen()),
          );
        } else if (role == "Instructor") {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (_) => const TeacherCourseScreen()),
          );
        } else {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (_) => const AdminCourseScreen()),
          );
        }
      } else {
        emit(LoginErrorState());
        _showSnackBar(message: "Invalid email or password", isError: true);
      }
    } on DioException catch (e) {
      emit(LoginErrorState());

      String errorMessage;

      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            errorMessage = "Invalid email or password";
            break;
          case 401:
            errorMessage = "Unauthorized access";
            break;
          case 404:
            errorMessage = "Account not found";
            break;
          case 500:
            errorMessage = "Server error, please try again later";
            break;
          default:
            errorMessage = e.response?.data["message"] ?? "Login failed";
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = "Connection timeout, please check your internet";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "No internet connection";
      } else {
        errorMessage = "Unexpected error occurred";
      }

      print("DioException: $errorMessage");
      _showSnackBar(message: errorMessage, isError: true);
    } catch (e) {
      emit(LoginErrorState());
      print("Unexpected exception: $e");
      _showSnackBar(message: "Unexpected error: ${e.toString()}", isError: true);
    }
  }

  void _showSnackBar({required String message, bool isError = false}) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 15))),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }
}

 */