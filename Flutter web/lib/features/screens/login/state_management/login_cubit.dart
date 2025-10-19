import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../courses/view.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState());
  Future<void> postLoginData(
      TextEditingController emailController,
      TextEditingController passwordController,
      BuildContext context,
      ) async {
    emit(LoadingLoginState());

    try {
      final response = await Dio(BaseOptions(baseUrl: ApiResources.apiUrl)).post(
        ApiResources.loginEndPoint,
        data: {
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      if (response.statusCode == 200 ) {
        emit(LoginSuccessState());
        passwordController.clear();
        emailController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data["message"] ?? "Login successful"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  CourseScreen() ,));
      } else {
        emit(LoginErrorState());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data["message"] ?? "Invalid email or password"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on DioException catch (e) {
      emit(LoginErrorState());

      String errorMessage = "Something went wrong";

      if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data["message"] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout, please try again";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Server took too long to respond";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      emit(LoginErrorState());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unexpected error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  // Future<void> postLoginData(
  //   emailController,
  //   passwordController,
  //   context,
  // ) async {
  //   emit(LoadingLoginState());
  //   final response = await Dio(BaseOptions(baseUrl: ApiResources.apiUrl)).post(
  //     ApiResources.loginEndPoint,
  //     data: {
  //       "email": emailController.text,
  //       "password": passwordController.text,
  //     },
  //   );
  //
  //   emit(LoginSuccessState());
  //   passwordController.clear();
  //   emailController.clear();
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text(response.data["message"])));
  // }
}
