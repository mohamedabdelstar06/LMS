// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker_web/image_picker_web.dart';
//
// import '../../core/cons/Colors/app_colors.dart';
// import '../../core/helpers/logout_server/logout.dart';
// import '../screens/Announcement/view.dart';
// import '../screens/Create_department/State_Mangment/create_dep_cubit.dart';
// import '../screens/Create_department/State_Mangment/create_dep_state.dart';
// import '../screens/Create_user/View.dart';
// import '../screens/courses/admin/view.dart';
// import '../screens/profiles/admin_profile/view.dart';
//
// class CreateDepartmentScreen extends StatefulWidget {
//   const CreateDepartmentScreen({super.key});
//
//   @override
//   State<CreateDepartmentScreen> createState() => _CreateDepartmentScreenState();
// }
//
// class _CreateDepartmentScreenState extends State<CreateDepartmentScreen> {
//   final nameController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final headNameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   Uint8List? selectedImageBytes;
//   String selectedMenuItem = 'Create Departments';
//   String? hoveredMenuItem;
//   bool isLogoutHovered = false;
//
//   Future<void> pickImage() async {
//     final bytes = await ImagePickerWeb.getImageAsBytes();
//     if (bytes != null) {
//       setState(() => selectedImageBytes = bytes);
//     }
//   }
//
//   ImageProvider _getSafeNetworkImage(String path) {
//     const String baseUrl = "https://your-api-domain.com";
//     final fullUrl = path.startsWith('http') ? path : "$baseUrl$path";
//     return NetworkImage(fullUrl);
//   }
//
//   InputDecoration _inputStyle(String label) {
//     return InputDecoration(
//       filled: true,
//       fillColor: const Color(0xFFF8FAFC),
//       hintText: label,
//       hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               MYColors.gradientColor_3,
//               MYColors.gradientColor_2.withOpacity(0.25),
//               MYColors.gradientColor_3,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Row(
//           children: [
//             _buildSidebar(),
//             Expanded(
//               child: BlocConsumer<DepartmentCubit, DepartmentState>(
//                 listener: (context, state) {
//                   if (state is DepartmentSuccess) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text(state.message), backgroundColor: Colors.green),
//                     );
//                     _clearForm();
//                   }
//                   if (state is DepartmentError) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//                     );
//                   }
//                 },
//                 builder: (context, state) {
//                   return SingleChildScrollView(
//                     padding: const EdgeInsets.all(40),
//                     child: Center(
//                       child: _buildFormContainer(state),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _clearForm() {
//     nameController.clear();
//     descriptionController.clear();
//     headNameController.clear();
//     setState(() => selectedImageBytes = null);
//   }
//
//   Widget _buildField(
//     String label,
//     TextEditingController nameController, {
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF475569),
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           validator: (v) => v!.isEmpty ? "Field Required" : null,
//
//           controller: nameController,
//           maxLines: maxLines,
//           decoration: _inputStyle(label),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildUploadArea() {
//     return GestureDetector(
//       onTap: pickImage,
//       child: Container(
//         height: 200,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
//           color: const Color(0xFFF8FAFC),
//         ),
//         child: selectedImageBytes == null
//             ? Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.cloud_upload_outlined, size: 48, color: Color(0xFF94A3B8)),
//             SizedBox(height: 12),
//             Text("Upload Department Image", style: TextStyle(color: Color(0xFF64748B))),
//           ],
//         )
//             : ClipRRect(
//           borderRadius: BorderRadius.circular(14),
//           child: Image.memory(selectedImageBytes!, fit: BoxFit.cover),
//         ),
//       ),
//     );
//   }
//   Widget _buildActionButtons(DepartmentState state) {
//     bool isLoading = state is DepartmentLoading;
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () => Navigator.pop(context),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 22),
//               side: const BorderSide(color: Color(0xFF3B82F6)),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             child: const Text("Cancel", style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
//           ),
//         ),
//         const SizedBox(width: 20),
//         Expanded(
//           flex: 2, child:
//           InkWell(
//             onTap:
//                isLoading ? null : () {
//                 if (_formKey.currentState!.validate()) {
//                   context.read<DepartmentCubit>().createDepartment(
//                     name: nameController.text,
//                     description: descriptionController.text,
//                     headId: se,
//                     imageBytes: selectedImageBytes,
//                   );
//                 }
//
//
//             },
//             child: Container(
//               width: 470,
//               height: 45,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF1849A9),
//                     Color(0xFF53B1FD),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(
//                   12,
//                 ),
//               ),
//               child: Center(
//                 child: isLoading
//                     ? Row(
//                   mainAxisAlignment:
//                   MainAxisAlignment
//                       .center,
//                   children: [
//                     SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor:
//                         AlwaysStoppedAnimation<
//                             Color
//                         >(Colors.white),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Text(
//                       "Creating Department...",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight:
//                         FontWeight.w600,
//                         fontFamily: "inter",
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 )
//                     : Text(
//                   "Create Department",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight:
//                     FontWeight.w600,
//                     fontFamily: "inter",
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//         ),
//       ],
//     );
//   }
//   Widget _buildFormContainer(DepartmentState state) {
//     return Expanded(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: TweenAnimationBuilder(
//           duration: const Duration(milliseconds: 600),
//           tween: Tween<double>(begin: 0, end: 1),
//           builder: (context, double value, child) {
//             return Opacity(
//               opacity: value,
//               child: Transform.translate(
//                 offset: Offset(0, 20 * (1 - value)),
//                 child: child,
//               ),
//             );
//           },
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 1000),
//             padding: const EdgeInsets.all(40),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Create Department",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildField(
//                           "Full Name",
//                           nameController,
//                         ),
//                       ),
//                       const SizedBox(width: 20),
//                       Expanded(
//                         child: _buildField(
//                           "HeadName",
//                           headNameController,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//
//                   _buildField(
//                     "Description",
//                     descriptionController,
//                     maxLines: 4,
//                   ),
//                   const SizedBox(height: 24),
//
//                   const Text(
//                     "Photo",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF475569),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _buildUploadArea(),
//
//                   const SizedBox(height: 40),
//
//                   _buildActionButtons(state),
//
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   Widget _buildSidebar() {
//     return Container(
//       width: 250,
//       margin: const EdgeInsetsGeometry.directional(
//         start: 40,
//         end: 0,
//         top: 50,
//         bottom: 50,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 40),
//           _buildMenuItem(
//             Icons.person_outline,
//             Icons.person,
//             'Profile',
//             'Profile',
//             () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AdminProfileScreen(),
//                 ),
//               );
//             },
//           ),
//           _buildMenuItem(
//             Icons.book_outlined,
//             Icons.book,
//             'My Courses',
//             'My Courses',
//             () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AdminCourseScreen(),
//                 ),
//               );
//             },
//           ),
//           _buildMenuItem(
//             Icons.notifications_active_outlined,
//             Icons.notifications_active_rounded,
//             'Announcements',
//             'Announcements',
//             () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AnnouncementScreen(),
//                 ),
//               );
//             },
//           ),
//           _buildMenuItem(
//             Icons.person_add_alt_1_outlined,
//             Icons.person_add_alt_1,
//             'Create Users',
//             'Create users',
//             () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const CreateUserScreen(),
//                 ),
//               );
//             },
//           ),
//           _buildMenuItem(
//             Icons.folder_copy_outlined,
//             Icons.folder_copy_rounded,
//             'Create Departments',
//             'Create Departments',
//             () {
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.grade_outlined,
//             Icons.grade,
//             'Grades overview',
//             'Grades overview',
//             () {},
//           ),
//           const Spacer(),
//           _buildLogoutButton(),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLogoutButton() {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => isLogoutHovered = true),
//       onExit: (_) => setState(() => isLogoutHovered = false),
//       child: GestureDetector(
//         onTap: () {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Logout'),
//               content: const Text('Are you sure you want to logout?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     await LogoutServer.logout();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFEF4444),
//                   ),
//                   child: const Text('Logout'),
//                 ),
//               ],
//             ),
//           );
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           margin: const EdgeInsets.symmetric(horizontal: 12),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: isLogoutHovered
//                 ? const Color(0xFFEF4444).withOpacity(0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: isLogoutHovered
//                   ? const Color(0xFFEF4444).withOpacity(0.3)
//                   : Colors.transparent,
//               width: 1,
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.logout, color: const Color(0xFFEF4444), size: 20),
//               const SizedBox(width: 12),
//               const Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: Color(0xFFEF4444),
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMenuItem(
//     IconData outlinedIcon,
//     IconData filledIcon,
//     String title,
//     String value,
//     onTap,
//   ) {
//     final isSelected = selectedMenuItem == value;
//     final isHovered = hoveredMenuItem == value;
//
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => hoveredMenuItem = value),
//       onExit: (_) => setState(() => hoveredMenuItem = null),
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedMenuItem = value;
//           });
//         },
//         child: GestureDetector(
//           onTap: onTap,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? const Color(0xFF2563EB)
//                   : isHovered
//                   ? const Color(0xFF2563EB).withOpacity(0.1)
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: isHovered && !isSelected
//                     ? const Color(0xFF2563EB).withOpacity(0.3)
//                     : Colors.transparent,
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: Icon(
//                     isSelected ? filledIcon : outlinedIcon,
//                     key: ValueKey(isSelected),
//                     color: isSelected
//                         ? Colors.white
//                         : isHovered
//                         ? const Color(0xFF2563EB)
//                         : const Color(0xFF64748B),
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: isSelected
//                         ? Colors.white
//                         : isHovered
//                         ? const Color(0xFF2563EB)
//                         : Colors.black87,
//                     fontSize: 14,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
