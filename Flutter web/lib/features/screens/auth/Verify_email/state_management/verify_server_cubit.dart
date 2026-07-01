import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../../core/cons/context/navigation_key.dart';
import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../ActivateAccountScreen/view.dart';
import '../../login/view.dart';
import '../user_model/data.dart';
import 'verify_state.dart';

class VerifyCubit extends Cubit<VerifyState> {
  VerifyCubit() : super(VerifyInitialState());


  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!email.endsWith('@gmail.com')) {
   return 'Please enter a valid Gmail address';
     }

    return null;
  }


  Future<void> postVerifyData(
      TextEditingController emailController,
      BuildContext context,
      ) async {
    final email = emailController.text.trim();

    final validationMessage = _validateEmail(email);
    if (validationMessage != null) {
      emit(VerifyErrorState());
      _showSnackBar(message: validationMessage, isError: true);
      return;
    }

    emit(LoadingVerifyState());

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiResources.apiUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.post(
        ApiResources.verifyUserEmailEndPoint,
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final responseData = Map<String, dynamic>.from(response.data);
        responseData['email'] = email;

        final model = UserStatusModel.fromJson(responseData);

        await VerifyStorageHelper.saveVerifyData(model);
        emailController.clear();

        emit(VerifySuccessState());

        if (!model.exists) {
          _showSnackBar(
            message: 'This email is not registered in the system',
            isError: true,
          );
          return;
        }

        if (model.exists && !model.isActivated) {
          Navigator.pushReplacement(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => const ActivateAccountScreen(),
            ),
          );
          return;
        }

        Navigator.pushReplacement(
          navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      } else {
        emit(VerifyErrorState());
        _showSnackBar(
          message: 'Verification failed, please try again',
          isError: true,
        );
      }
    } on DioException catch (e) {
      emit(VerifyErrorState());

      String errorMessage;

      if (e.response != null) {
        final statusCode = e.response?.statusCode;

        switch (statusCode) {
          case 400:
            errorMessage = 'Invalid email format';
            break;
          case 404:
            errorMessage = 'Email not found';
            break;
          case 500:
            errorMessage = 'Server error, please try again later';
            break;
          default:
            errorMessage =
                e.response?.data['message'] ?? 'Verification failed';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout, please check your internet';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      } else {
        errorMessage = 'Unexpected error occurred';
      }

      _showSnackBar(message: errorMessage, isError: true);
    } catch (e) {
      emit(VerifyErrorState());
      _showSnackBar(
        message: 'Unexpected error: ${e.toString()}',
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
