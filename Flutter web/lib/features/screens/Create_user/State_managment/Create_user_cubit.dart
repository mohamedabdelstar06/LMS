// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/cons/api_helper_resources/api_resources.dart';
// import '../../../../core/cons/context/navigation_key.dart';
// import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
//
// import '../User_model/ProfileModel.dart';
// import 'Create_user_state.dart';
//
//
// class CreateUserCubit extends Cubit<CreateState> {
//   CreateUserCubit() : super(CreateUserInitialState());
//   Future<void> postCreatedUserData(
//       TextEditingController emailController,
//       TextEditingController passwordController,
//       TextEditingController fullNameController,
//       TextEditingController nationalIdController,
//       TextEditingController genderController,
//       TextEditingController academicLevelController,
//       DateTime dateOfBirth,
//       String city,
//       String role,
//       bool isActive,
//       BuildContext context, {
//         Uint8List? profileImageBytes,
//       }
//       ) async {
//     emit(LoadingCreateUserState());
//     try {
//       final response = await Dio(BaseOptions(baseUrl: ApiResources.apiUrl)).post(
//         ApiResources.createUserEndPoint,
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//           },
//         ),
//         data: {
//           "email": emailController.text,
//           "fullName": fullNameController.text,
//           "nationalId": nationalIdController.text,
//           "password": passwordController.text,
//           "city": city,
//           "gender": genderController.text,
//           "isActive": isActive,
//           "academicLevel": academicLevelController.text,
//           "role": role,
//           "dateOfBirth": dateOfBirth.toIso8601String(),
//           "profileImageUrl": "https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1QQYTz.img?w=768&h=432&m=6&x=395&y=144&s=122&d=122",
//
//         },
//       );
//
//       if (response.statusCode == 200 ) {
//         emit(CreateUserSuccessState());
//         final ProfileModel = CreateUserModel.fromJson(response.data);
//         await PrefHelper.saveCreatedUserData(ProfileModel);
//         passwordController.clear();
//         emailController.clear();
//         fullNameController.clear();
//         nationalIdController.clear();
//         genderController.clear();
//         academicLevelController.clear();
//         city = "Select City";
//         role = "Select Role";
//
//
//         ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     response.data["message"] ?? "User Created Successfully",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.green.shade600,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             duration: const Duration(seconds: 3),
//             elevation: 6,
//           ),
//
//
//
//         );
//
//
//
//
//
//
//       } else {
//         emit(CreateUserErrorState());
//         ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
//           SnackBar(
//             content: Text(response.data["message"] ?? "Invalid email or password"),
//             backgroundColor: Colors.redAccent,
//           ),
//         );
//       }
//     } on DioException catch (e) {
//       emit(CreateUserErrorState());
//
//       String errorMessage = "Something went wrong";
//
//       if (e.response != null && e.response?.data is Map) {
//         errorMessage = e.response?.data["message"] ?? errorMessage;
//       } else if (e.type == DioExceptionType.connectionTimeout) {
//         errorMessage = "Connection timeout, please try again";
//       } else if (e.type == DioExceptionType.receiveTimeout) {
//         errorMessage = "Server took too long to respond";
//       }
//
//       ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     } catch (e) {
//       emit(CreateUserErrorState());
//       ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
//         SnackBar(
//           content: Text("Unexpected error: $e"),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }
//
// }

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cons/api_helper_resources/api_resources.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../User_model/model.dart';
import 'Create_user_state.dart';

class CreateUserCubit extends Cubit<CreateState> {
  CreateUserCubit() : super(CreateUserInitialState());

  Future<void> postCreatedUserData(
      TextEditingController emailController,
      // TextEditingController passwordController,
      TextEditingController fullNameController,
      TextEditingController nationalIdController,
      TextEditingController genderController,
      TextEditingController academicLevelController,
      DateTime dateOfBirth,
      String city,
      String role,
      bool isActive,
      BuildContext context, {
        Uint8List? profileImageBytes,
      }) async {

    if (emailController.text.trim().isEmpty ||
        // passwordController.text.trim().isEmpty ||
        fullNameController.text.trim().isEmpty) {
      emit(CreateUserErrorState("Please fill all required fields"));
      return;
    }

    emit(LoadingCreateUserState());

    try {
      final token = await TokenStorageHelper.getTokenSecure();

      if (token != null) {
      }

      if (token == null || token.isEmpty) {
        emit(CreateUserErrorState("Authentication required. Please login first.", statusCode: 401));
        return;
      }

      // final fullUrl = '${ApiResources.apiUrl}${ApiResources.createUserEndPoint}';
      // print('🌐 Base URL: ${ApiResources.apiUrl}');
      // print('🌐 Endpoint: ${ApiResources.createUserEndPoint}');
      // print('🌐 Full URL: $fullUrl');
      // print('🌐 ════════════════════════════════════════');

      final requestData = {
        "email": emailController.text.trim(),
        "fullName": fullNameController.text.trim(),
        "nationalId": nationalIdController.text.trim(),
        // "password": passwordController.text.trim(),
        "city": city,
        "gender": genderController.text.trim(),
        "isActive": isActive,
        "academicLevel": academicLevelController.text.trim(),
        "role": role,
        "dateOfBirth": dateOfBirth.toIso8601String(),
        "profileImageUrl": "https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1QQYTz.img?w=768&h=432&m=6&x=395&y=144&s=122&d=122",
      };

      // print('📤 Request Data: $requestData');
      // print('🔐 Authorization: Bearer ${token.substring(0, min(20, token.length))}...');

      final response = await Dio(BaseOptions(
        baseUrl: ApiResources.apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      )).post(
        ApiResources.createUserEndPoint,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
        data: requestData,
      );

      // print('📥 Response Status Code: ${response.statusCode}');
      // print('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final model = CreateUserModel.fromJson(response.data);
        await UserStorageHelper.saveCreatedUserData(model);

        emit(CreateUserSuccessState(
          statusCode: response.statusCode,
          message: response.data?["message"] ?? "User Created Successfully",
        ));

        if (context.mounted) {
          // passwordController.clear();
          emailController.clear();
          fullNameController.clear();
          nationalIdController.clear();
          genderController.clear();
          academicLevelController.clear();
        }
      } else {
        final errorMsg = response.data?["message"] ?? "Failed to create user";
        emit(CreateUserErrorState(
          errorMsg,
          statusCode: response.statusCode,
        ));
      }
    } on DioException catch (e) {
      // print('❌ DioException Type: ${e.type}');
      // print('❌ Status Code: ${e.response?.statusCode}');
      // print('❌ Response Data: ${e.response?.data}');
      // print('❌ Error Message: ${e.message}');

      String errorMessage = "Something went wrong";
      int? statusCode = e.response?.statusCode;

      if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data["message"] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout, please try again";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Server took too long to respond";
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = "No internet connection";
      }

      emit(CreateUserErrorState(errorMessage, statusCode: statusCode));
    } catch (e) {
      emit(CreateUserErrorState("Unexpected error: ${e.toString()}"));
    }
  }
}
/*

Future<void> postCreatedUserData(
  TextEditingController emailController,
  TextEditingController passwordController,
  TextEditingController fullNameController,
  TextEditingController nationalIdController,
  TextEditingController genderController,
  TextEditingController academicLevelController,
  DateTime dateOfBirth,
  String city,
  String role,
  bool isActive,
  BuildContext context, {
  Uint8List? profileImageBytes,
}) async {
  // Validation
  if (emailController.text.trim().isEmpty ||
      passwordController.text.trim().isEmpty ||
      fullNameController.text.trim().isEmpty) {
    emit(CreateUserErrorState("Please fill all required fields"));
    return;
  }

  emit(LoadingCreateUserState());

  try {
    final token = await TokenStorageHelper.getTokenSecure();

    if (token == null || token.isEmpty) {
      emit(CreateUserErrorState(
          "Authentication required. Please login first.",
          statusCode: 401));
      return;
    }

    final formData = FormData.fromMap({
      "email": emailController.text.trim(),
      "fullName": fullNameController.text.trim(),
      "nationalId": nationalIdController.text.trim(),
      "password": passwordController.text.trim(),
      "city": city,
      "gender": genderController.text.trim(),
      "isActive": isActive,
      "academicLevel": academicLevelController.text.trim(),
      "role": role,
      "dateOfBirth": dateOfBirth.toIso8601String(),

      if (profileImageBytes != null)
        'profileImage': MultipartFile.fromBytes(
          profileImageBytes,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
    });

    final response = await Dio(BaseOptions(
      baseUrl: ApiResources.apiUrl,
      connectTimeout: const Duration(seconds: 60), // زود الوقت للصور
      receiveTimeout: const Duration(seconds: 60),
    )).post(
      ApiResources.createUserEndPoint,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          // Content-Type: multipart/form-data هيتحدد automatically
        },
      ),
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final ProfileModel = CreateUserModel.fromJson(response.data);
      await PrefHelper.saveCreatedUserData(ProfileModel);

      emit(CreateUserSuccessState(
        statusCode: response.statusCode,
        message: response.data?["message"] ?? "User Created Successfully",
      ));

      if (context.mounted) {
        passwordController.clear();
        emailController.clear();
        fullNameController.clear();
        nationalIdController.clear();
        genderController.clear();
        academicLevelController.clear();
      }
    } else {
      final errorMsg = response.data?["message"] ?? "Failed to create user";
      emit(CreateUserErrorState(errorMsg, statusCode: response.statusCode));
    }
  } on DioException catch (e) {
    String errorMessage = "Something went wrong";
    int? statusCode = e.response?.statusCode;

    if (e.response != null && e.response?.data is Map) {
      errorMessage = e.response?.data["message"] ?? errorMessage;
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = "Connection timeout, please try again";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Server took too long to respond";
    } else if (e.type == DioExceptionType.unknown) {
      errorMessage = "No internet connection";
    }

    emit(CreateUserErrorState(errorMessage, statusCode: statusCode));
  } catch (e) {
    emit(CreateUserErrorState("Unexpected error: ${e.toString()}"));
  }
}
 */

// import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
// import 'dart:typed_data' hide Uint8List;
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/cons/api_helper_resources/api_resources.dart';
// import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
// import '../User_model/ProfileModel.dart';
// import 'Create_user_state.dart';
//
// class CreateUserCubit extends Cubit<CreateState> {
//   CreateUserCubit() : super(CreateUserInitialState());
//
//   // متغير لحفظ الصورة المختارة
//   Uint8List? selectedImageBytes;
//
//   // دالة لاختيار الصورة
//   void selectImage(Uint8List imageBytes) {
//     selectedImageBytes = imageBytes;
//     emit(ImageSelectedState(imageBytes ));
//   }
//
//   // دالة لمسح الصورة
//   void clearImage() {
//     selectedImageBytes = null;
//     emit(ImageClearedState());
//   }
//
//   Future<void> postCreatedUserData(
//       TextEditingController emailController,
//       TextEditingController passwordController,
//       TextEditingController fullNameController,
//       TextEditingController nationalIdController,
//       TextEditingController genderController,
//       TextEditingController academicLevelController,
//       DateTime dateOfBirth,
//       String city,
//       String role,
//       bool isActive,
//       BuildContext context) async {
//
//     // Validation
//     if (emailController.text.trim().isEmpty ||
//         passwordController.text.trim().isEmpty ||
//         fullNameController.text.trim().isEmpty) {
//       emit(CreateUserErrorState("Please fill all required fields"));
//       return;
//     }
//
//     emit(LoadingCreateUserState());
//
//     try {
//       final token = await TokenStorageHelper.getTokenSecure();
//
//       if (token == null || token.isEmpty) {
//         emit(CreateUserErrorState("Authentication required. Please login first.", statusCode: 401));
//         return;
//       }
//
//       String? profileImageBase64;
//       if (selectedImageBytes != null) {
//         final base64String = base64Encode(selectedImageBytes );
//         profileImageBase64 = 'data:image/png;base64,$base64String';
//       }
//
//       final requestData = {
//         "email": emailController.text.trim(),
//         "fullName": fullNameController.text.trim(),
//         "nationalId": nationalIdController.text.trim(),
//         "password": passwordController.text.trim(),
//         "city": city,
//         "gender": genderController.text.trim(),
//         "isActive": isActive,
//         "academicLevel": academicLevelController.text.trim(),
//         "role": role,
//         "dateOfBirth": dateOfBirth.toIso8601String(),
//         // لو فيه صورة نبعتها، لو مفيش نبعت null أو نشيل الحقل ده
//         if (profileImageBase64 != null) "profileImageUrl": profileImageBase64,
//       };
//
//       final response = await Dio(BaseOptions(
//         baseUrl: ApiResources.apiUrl,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//       )).post(
//         ApiResources.createUserEndPoint,
//         options: Options(
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $token",
//           },
//         ),
//         data: requestData,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final ProfileModel = CreateUserModel.fromJson(response.data);
//         await PrefHelper.saveCreatedUserData(ProfileModel);
//
//         emit(CreateUserSuccessState(
//           statusCode: response.statusCode,
//           message: response.data?["message"] ?? "User Created Successfully",
//         ));
//
//         if (context.mounted) {
//           passwordController.clear();
//           emailController.clear();
//           fullNameController.clear();
//           nationalIdController.clear();
//           genderController.clear();
//           academicLevelController.clear();
//           clearImage(); // مسح الصورة بعد النجاح
//         }
//       } else {
//         final errorMsg = response.data?["message"] ?? "Failed to create user";
//         emit(CreateUserErrorState(
//           errorMsg,
//           statusCode: response.statusCode,
//         ));
//       }
//     } on DioException catch (e) {
//       String errorMessage = "Something went wrong";
//       int? statusCode = e.response?.statusCode;
//
//       if (e.response != null && e.response?.data is Map) {
//         errorMessage = e.response?.data["message"] ?? errorMessage;
//       } else if (e.type == DioExceptionType.connectionTimeout) {
//         errorMessage = "Connection timeout, please try again";
//       } else if (e.type == DioExceptionType.receiveTimeout) {
//         errorMessage = "Server took too long to respond";
//       } else if (e.type == DioExceptionType.unknown) {
//         errorMessage = "No internet connection";
//       }
//
//       emit(CreateUserErrorState(errorMessage, statusCode: statusCode));
//     } catch (e) {
//       emit(CreateUserErrorState("Unexpected error: ${e.toString()}"));
//     }
//   }
// }

