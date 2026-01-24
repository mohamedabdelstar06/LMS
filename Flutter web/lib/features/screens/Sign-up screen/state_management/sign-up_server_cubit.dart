import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../core/cons/context/navigation_key.dart';

import '../../login/view.dart';
import '../user_model/data.dart';
import 'sign-up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitialState());
  Future<void> postSignUpData(
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController confirmedPasswordController,
      BuildContext context,
      ) async {
    emit(LoadingSignUpState());

    try {
      final response = await Dio(BaseOptions(baseUrl: ApiResources.apiUrl)).post(
        ApiResources.signUpUserEndPoint,
        data: {
          "email": emailController.text,
          "password": passwordController.text,
          "passwordConfirmed": confirmedPasswordController.text,

        },
      );

      if (response.statusCode == 200 ) {
        emit(SignUpSuccessState());
        final model = SignUpUserModel.fromJson(response.data);
        // TODO: Handle successful login and Save in SharedPreferences
        // await PrefHelper.saveLoginData(model);
        // await TokenStorageHelper.saveTokenSecure(model);




        passwordController.clear();
        emailController.clear();
        confirmedPasswordController.clear();

        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    response.data["message"] ?? "Sign-Up successful",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            duration: const Duration(seconds: 3),
            elevation: 6,
          ),


          // ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          //   SnackBar(
          //     content: Text(response.data["message"] ?? "Login successful",),
          //     backgroundColor: Colors.green,
          //   ),
        );


        if (model.user!.role == "Student" || model.user!.role == "Instructor" ||model.user!.role ==  "Admin"){
          Navigator.pushReplacement(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) =>  LoginScreen() ,));
        }




      } else {
        emit(SignUpErrorState());
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(response.data["message"] ?? "Invalid email or password"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on DioException catch (e) {
      emit(SignUpErrorState());

      String errorMessage = "Something went wrong";

      if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data["message"] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout, please try again";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Server took too long to respond";
      }

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      emit(SignUpErrorState());
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text("Unexpected error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

}