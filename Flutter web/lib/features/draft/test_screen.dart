// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
//
//
//
// class UploadCoursePage extends StatefulWidget {
//   const UploadCoursePage({super.key});
//
//   @override
//   State<UploadCoursePage> createState() => _UploadCoursePageState();
// }
//
// class _UploadCoursePageState extends State<UploadCoursePage> {
//   File? selectedFile;
//   bool isLoading = false;
//
//   Future<void> pickFile() async {
//     final result = await FilePicker.platform.pickFiles();
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         selectedFile = File(result.files.single.path!);
//       });
//     }
//   }
//
//   Future<void> uploadCourse() async {
//     if (selectedFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a file first')),
//       );
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     try {
//       var dio = Dio();
//
//       var headers = {
//         'Authorization':
//         'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9....' // حط التوكن بتاعك هنا
//       };
//
//       var data = FormData.fromMap({
//         'files': [
//           await MultipartFile.fromFile(selectedFile!.path,
//               filename: selectedFile!.path.split('/').last)
//         ],
//         'Title': 'Introduction to AI',
//         'Description': 'A beginner course about Artificial Intelligence',
//         'DepartmentId': '4',
//         'YearId': '9',
//         'CreditHours': '2004'
//       });
//
//       var response = await dio.post(
//         'http://skylearnapi.runasp.net/api/Course/create',
//         data: data,
//         options: Options(headers: headers),
//       );
//
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Upload successful ✅')),
//         );
//         print(jsonEncode(response.data));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Upload failed: ${response.statusMessage}')),
//         );
//       }
//     } catch (e) {
//       print('Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Course')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (selectedFile != null)
//               Text('Selected file: ${selectedFile!.path.split('/').last}'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: pickFile,
//               child: const Text('Pick File'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isLoading ? null : uploadCourse,
//               child: isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Upload to API'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
