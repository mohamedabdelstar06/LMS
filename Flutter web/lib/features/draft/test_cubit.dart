// import 'package:bloc/bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
// import 'package:lms/features/draft/test_models.dart';
// import 'package:lms/features/draft/test_states.dart';
// import 'package:lms/features/screens/get_years/get_All_years/state_mangement/states.dart';
//
// import '../../../../../core/helpers/cach_helper/shared_pref_helper.dart';
// import '../all_model/model.dart';
//
// class AllYearsCubit extends Cubit<AllYearsState> {
//   AllYearsCubit() : super(YearsInitial());
//
//   final Dio dio = Dio(
//     BaseOptions(baseUrl: ApiResources.apiUrl),
//   );
//
//   Future<void> fetchYearss() async {
//     emit(YearsLoading());
//
//     try {
//       final token = await TokenStorageHelper.getTokenSecure();
//
//       final response = await dio.get(
//         ApiResources.getYearEndPoint,
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $token",
//           },
//         ),
//       );
//
//       final years = (response.data as List)
//           .map((e) => GetAllYearModel.fromJson(e))
//           .toList();
//
//       emit(YearsLoaded(years));
//     } catch (e) {
//       emit(YearsError(e.toString()));
//     }
//   }
//
//   Future<void> deleteYear(int id) async {
//     final currentState = state;
//
//     if (currentState is! YearsLoaded) {
//       emit(const YearsError("Cannot delete: data not loaded"));
//       return;
//     }
//
//     try {
//       final token = await TokenStorageHelper.getTokenSecure();
//
//       if (token == null) {
//         emit(const YearsError("Unauthorized"));
//         return;
//       }
//
//       final response = await dio.delete(
//         "${ApiResources.getYearEndPoint}/$id",
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $token",
//           },
//         ),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 204) {
//         final updatedYears = currentState.years
//             .where((year) => year.id != id)
//             .toList();
//
//         emit(YearsLoaded(updatedYears));
//
//         emit(DeleteYearSuccess("Year deleted successfully"));
//         emit(YearsLoaded(updatedYears));
//       } else {
//         emit(YearsError("Failed to delete year: ${response.statusCode}"));
//       }
//     } catch (e) {
//       if (currentState is YearsLoaded) {
//         emit(YearsLoaded(currentState.years));
//       }
//       emit(YearsError("Error deleting year: ${e.toString()}"));
//     }
//   }
//
//   Future<void> updateYears({
//     required int id,
//     required String name,
//     required String description,
//     required int headId,
//   }) async {
//     final currentState = state;
//
//     try {
//       final token = await TokenStorageHelper.getTokenSecure();
//
//       if (token == null) {
//         emit(const YearsError("Unauthorized"));
//         return;
//       }
//
//       final response = await dio.put(
//         "${ApiResources.getYearEndPoint}/$id",
//         data: {
//           "name": name,
//           "description": description,
//           "headId": headId,
//         },
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $token",
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         await fetchYearss();
//       } else {
//         emit(YearsError("Failed to update year: ${response.statusCode}"));
//       }
//     } catch (e) {
//       if (currentState is YearsLoaded) {
//         emit(YearsLoaded(currentState.years));
//       }
//       emit(YearsError("Error updating year: ${e.toString()}"));
//     }
//   }
// }