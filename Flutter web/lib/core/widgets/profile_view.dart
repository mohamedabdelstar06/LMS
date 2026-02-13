// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:lms/core/widgets/profile_picture.dart';
// import 'package:lms/core/widgets/savebutton.dart';
// import 'package:lms/core/widgets/sidebar.dart';
// import 'package:lms/core/widgets/textfield.dart';
// import 'package:lms/core/widgets/webImage.dart';
// import '../../features/screens/admin/admin_profile/model/view.dart';
// import '../../features/screens/admin/admin_profile/state_managment/cubit_d_profile.dart';
// import '../../features/screens/admin/admin_profile/state_managment/state_d_profile.dart';
// import '../cons/Colors/app_colors.dart';
// import 'dateDropDown.dart';
//
// class AdminProfileScreen extends StatefulWidget {
//   const AdminProfileScreen({super.key});
//
//   @override
//   State<AdminProfileScreen> createState() => _AdminProfileScreenState();
// }
//
// class _AdminProfileScreenState extends State<AdminProfileScreen> {
//   // State variables
//   String selectedMenuItem = 'Profile';
//   String? hoveredMenuItem;
//   bool isLogoutHovered = false;
//   bool isProfilePictureHovered = false;
//   String selectedCity = 'Select City';
//   bool isCityExpanded = false;
//   DateTime? selectedDate;
//   Uint8List? _webImage;
//   File? _selectedImage;
//
//   // Controllers and FocusNodes
//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController nationalIdController = TextEditingController();
//   final TextEditingController dobController = TextEditingController();
//   final FocusNode dobFocus = FocusNode();
//
//   // Constants
//   static const List<String> cities = [
//     'Cairo', 'Alexandria', 'Giza', 'Shubra El-Kheima', 'Port Said',
//     'Suez', 'Luxor', 'Aswan', 'Qena', 'Ismailia', 'Fayoum',
//     'Minya', 'Beni Suef', 'Assiut', 'Sohag', 'Red Sea',
//     'North Sinai', 'South Sinai', 'Matrouh', 'New Valley',
//     'Damietta', 'Kafr El Sheikh', 'Beheira', 'Monufia',
//     'Qalyubia', 'Sharqia', 'Daqahlia', 'Gharbia',
//   ];
//
//   // Image picker
//   final ImagePicker _imagePicker = ImagePicker();
//
//   // Initialization flag
//   bool _isInitialized = false;
//
//   @override
//   void dispose() {
//     _disposeControllers();
//     super.dispose();
//   }
//
//   void _disposeControllers() {
//     fullNameController.dispose();
//     emailController.dispose();
//     nationalIdController.dispose();
//     dobController.dispose();
//     dobFocus.dispose();
//   }
//
//   void _initControllers(User user) {
//     if (_isInitialized) return;
//
//     fullNameController.text = user.fullName;
//     emailController.text = user.email;
//     nationalIdController.text = user.nationalId;
//
//     if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
//       try {
//         final date = DateTime.parse(user.dateOfBirth!);
//         dobController.text = _formatDate(date);
//         selectedDate = date;
//       } catch (_) {
//         dobController.text = '';
//         selectedDate = null;
//       }
//     }
//
//     selectedCity = user.city ?? selectedCity;
//     _isInitialized = true;
//   }
//
//   String _formatDate(DateTime date) {
//     return "${date.day.toString()}/${date.month.toString()}/${date.year}";
//   }
//
//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 512,
//         maxHeight: 512,
//         imageQuality: 85,
//       );
//
//       if (pickedFile != null) {
//         if (kIsWeb) {
//           final bytes = await pickedFile.readAsBytes();
//           setState(() => _webImage = bytes);
//         } else {
//           setState(() => _selectedImage = File(pickedFile.path));
//         }
//         _showSuccessSnackbar('Profile picture selected! Click "Save Changes" to update.');
//       }
//     } catch (e) {
//       _showErrorSnackbar('Failed to pick image. Please try again.');
//     }
//   }
//
//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFF10B981),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFFEF4444),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               MYColors.gradientColor_3,
//               MYColors.gradientColor_2.withValues(alpha: 0.25),
//               MYColors.gradientColor_3,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Row(
//             children: [
//               _buildSidebar(),
//               Expanded(child: _buildProfileContent()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSidebar() {
//     return ProfileSidebar(
//       selectedMenuItem: selectedMenuItem,
//       hoveredMenuItem: hoveredMenuItem,
//       isLogoutHovered: isLogoutHovered,
//       onMenuItemSelected: (value) => setState(() => selectedMenuItem = value),
//       onMenuItemHovered: (value) => setState(() => hoveredMenuItem = value),
//       onLogoutHovered: () => setState(() => isLogoutHovered = true),
//       onLogoutExited: () => setState(() => isLogoutHovered = false),
//     );
//   }
//
//   Widget _buildProfileContent() {
//     return BlocProvider(
//       create: (context) => AdminProfileCubit()..getProfile(),
//       child: BlocBuilder<AdminProfileCubit, AdminProfileState>(
//         builder: (context, state) {
//           if (state is AdminProfileLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is AdminProfileError) {
//             return Center(child: Text(state.message));
//           } else if (state is AdminProfileLoaded) {
//             final user = state.profile.user;
//             _initControllers(user);
//             return _buildProfileForm(user: user);
//           }
//           return const Center(child: Text('Loading...'));
//         },
//       ),
//     );
//   }
//
//   Widget _buildProfileForm({required User user}) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           constraints: const BoxConstraints(maxWidth: 1132),
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 4),
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Your Profile',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF2563EB),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Here are all your personal details that you can view and update anytime',
//                   style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
//                 ),
//                 const SizedBox(height: 32),
//                 ProfilePictureWidget(
//                   userImageUrl: user.profileImageUrl,
//                   webImage: _webImage,
//                   selectedImage: _selectedImage,
//                   isHovered: isProfilePictureHovered,
//                   onTap: _pickImage,
//                   onHover: (isHovered) => setState(() => isProfilePictureHovered = isHovered),
//                 ),
//                 const SizedBox(height: 24),
//                 ProfileTextField(
//                   label: 'Full Name',
//                   controller: fullNameController,
//                   icon: Icons.person,
//                   hint: user.fullName,
//                   isReadOnly: true,
//                   isEnabled: false,
//                 ),
//                 const SizedBox(height: 16),
//                 ProfileTextField(
//                   label: 'Email address',
//                   controller: emailController,
//                   icon: Icons.email,
//                   hint: user.email,
//                   isReadOnly: true,
//                   isEnabled: false,
//                 ),
//                 const SizedBox(height: 16),
//                 ProfileTextField(
//                   label: 'National ID',
//                   controller: nationalIdController,
//                   icon: Icons.badge,
//                   hint: user.nationalId,
//                   isReadOnly: true,
//                   isEnabled: false,
//                 ),
//                 const SizedBox(height: 16),
//                 ProfileDateField(
//                   label: 'Date of Birth',
//                   controller: dobController,
//                   focusNode: dobFocus,
//                   hint: user.dateOfBirth ?? "Select Date",
//                   selectedDate: selectedDate,
//                   onDateSelected: (date) => setState(() => selectedDate = date),
//                 ),
//                 const SizedBox(height: 16),
//                 ProfileDropdownField(
//                   label: 'City',
//                   value: selectedCity,
//                   options: cities,
//                   isExpanded: isCityExpanded,
//                   onSelected: (value) {
//                     setState(() {
//                       selectedCity = value;
//                       isCityExpanded = false;
//                     });
//                   },
//                   onToggle: () => setState(() => isCityExpanded = !isCityExpanded),
//                 ),
//                 const SizedBox(height: 32),
//                 SaveButtonWidget(
//                   selectedCity: selectedCity,
//                   selectedDate: selectedDate,
//                   onSaveSuccess: () {
//                     setState(() {
//                       _webImage = null;
//                       _selectedImage = null;
//                     });
//                   },
//                   onSaveError: () {},
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }