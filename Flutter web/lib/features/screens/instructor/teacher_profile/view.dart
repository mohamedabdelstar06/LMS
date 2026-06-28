import 'dart:ui_web' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:lms/core/helpers/api_url_helper.dart';
import 'package:lms/features/screens/instructor/home_courses/view.dart';
import 'package:lms/features/screens/instructor/teacher_profile/state_managment/cubit_d_profile.dart';
import 'package:lms/features/screens/instructor/teacher_profile/state_managment/state_d_profile.dart';



import 'package:lms/core/widgets/management/management_layout.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';
import '../../../../core/helpers/logout_server/logout.dart';
import '../../../../generated/assets.dart';
import '../../Announcement/view.dart';
import '../../admin/admin_profile/view.dart';
import '../../admin/courses/create_course/Adding_view.dart';
import '../../student/student_courses/view.dart';
import '../create_course/Adding_view.dart';
import 'model/view.dart';
import 'dart:html' as html;


class WebImage extends StatelessWidget {

  const WebImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });
  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final viewId = url;

    ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      return img;
    });

    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewId),
    );
  }
}

String buildImageUrl(String? imageUrl) {
  return ApiUrlHelper.resolveMediaUrl(imageUrl) ?? '';
}

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<TeacherProfileScreen> {
  Uint8List? _webImage;
  String selectedMenuItem = 'Profile';
  bool isNextButtonHovered = false;
  String? hoveredMenuItem;
  bool isLogoutHovered = false;
  bool isProfilePictureHovered = false;
  String selectedStartYear = '2020';
  String selectedEndYear = '2025';

  bool isStartExpanded = false;
  bool isEndExpanded = false;
  DateTime? selectedDate;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();


  List<String> yearsList = [for (int y = 1980; y <= 2060; y++) y.toString()];


  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode nationalIdFocus = FocusNode();
  final FocusNode dobFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController dobController = TextEditingController();


  String selectedCity = 'Select City';
  bool isCityExpanded = false;


  final List<String> cities = [
    'Cairo',
    'Alexandria',
    'Giza',
    'Shubra El-Kheima',
    'Port Said',
    'Suez',
    'Luxor',
    'Aswan',
    'Qena',
    'Ismailia',
    'Fayoum',
    'Minya',
    'Beni Suef',
    'Assiut',
    'Sohag',
    'Red Sea',
    'North Sinai',
    'South Sinai',
    'Matrouh',
    'New Valley',
    'Damietta',
    'Kafr El Sheikh',
    'Beheira',
    'Monufia',
    'Qalyubia',
    'Sharqia',
    'Daqahlia',
    'Gharbia',
  ];

  @override
  void dispose() {

    fullNameController.dispose();
    emailController.dispose();
    nationalIdController.dispose();
    dobController.dispose();
    fullNameFocus.dispose();
    emailFocus.dispose();
    nationalIdFocus.dispose();
    dobFocus.dispose();
    super.dispose();
  }


  bool _isInitialized = false;

  void _initControllers(User user) {
    if (_isInitialized) return;

    fullNameController.text = user.fullName ;
    emailController.text = user.email ;
    nationalIdController.text = user.nationalId ;


    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      try {
        final date = DateTime.parse(user.dateOfBirth!);
        dobController.text = _formatDate(date);
        selectedDate = date;
      } catch (_) {
        dobController.text = '';
        selectedDate = null;
      }
    }

    selectedCity = user.city ?? selectedCity;

    _isInitialized = true;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString()}/'
        '${date.month.toString()}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TeacherProfileCubit()..getProfile(),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ManagementScaffold(
        selectedMenuItem: selectedMenuItem,
        role: ManagementRole.instructor,
        child: BlocBuilder<TeacherProfileCubit, TeacherProfileState>(
          builder: (context, state) {
            if (state is TeacherProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TeacherProfileError) {
              return Center(child: Text(state.message));
            } else if (state is TeacherProfileLoaded) {
              final user = state.profile.user;

              _initControllers(user);
              return _buildProfileContent(user: user);
            }
            return const Center(child: Text('Loading...'));
          },
        ),
      ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      margin: const EdgeInsetsDirectional.only(
        start: 30,
        top: 50,
        bottom: 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildMenuItem(
            Icons.person_outline,
            Icons.person,
            'Profile',
            'Profile',
                () {

            },
          ),
          _buildMenuItem(
            Icons.book_outlined,
            Icons.book,
            'My Courses',
            'My Courses',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherCourseScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(

            Icons.event_available,
            Icons.event_note_outlined,
            'Create New Course',
            'Create New Course',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherCreateNewCoursePage(),
                ),
              );
            },
          ),

          _buildMenuItem(
            Icons.notifications_active_outlined,
            Icons.notifications_active_rounded,
            'Announcements',
            'Announcements',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllAnnouncementScreen(),
                ),
              );
            },
          ),

          _buildMenuItem(
            Icons.grade_outlined,
            Icons.grade,
            'Grades overview',
            'Grades overview',
                () {},
          ),
          const Spacer(),
          _buildLogoutButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      IconData outlinedIcon,
      IconData filledIcon,
      String title,
      String value,
      onTap,
      ) {
    final isSelected = selectedMenuItem == value;
    final isHovered = hoveredMenuItem == value;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hoveredMenuItem = value),
      onExit: (_) => setState(() => hoveredMenuItem = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMenuItem = value;
          });
        },
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : isHovered
                  ? const Color(0xFF2563EB).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHovered && !isSelected
                    ? const Color(0xFF2563EB).withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? filledIcon : outlinedIcon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? Colors.white
                        : isHovered
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isHovered
                        ? const Color(0xFF2563EB)
                        : Colors.black87,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isLogoutHovered = true),
      onExit: (_) => setState(() => isLogoutHovered = false),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await LogoutServer.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isLogoutHovered
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLogoutHovered
                  ? const Color(0xFFEF4444).withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent({required User user}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          constraints: const BoxConstraints(maxWidth: 1132),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Text(
                  'Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Here are all your personal details that you can view and update anytime',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 32),
                _buildProfilePicture(userImageUrl: user.profileImageUrl),
                const SizedBox(height: 24),
                _buildTextField(
                  true,
                  'Full Name',
                  fullNameController,
                  Icons.person,
                  user.fullName,
                  true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  true,
                  'Email address',
                  emailController,
                  Icons.email,
                  user.email,
                  true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  true,
                  'National ID',
                  nationalIdController,
                  Icons.badge,
                  user.nationalId,
                  true,
                  maxLength: 14,
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  'Date of Birth',
                  dobController,
                  dobFocus,
                  user.dateOfBirth ?? 'Select Date',
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  'City',
                  selectedCity,
                  cities,
                  isCityExpanded,
                      (value) {
                    setState(() {
                      selectedCity = value;
                      isCityExpanded = false;
                    });
                  },
                      () {
                    setState(() {
                      isCityExpanded = !isCityExpanded;
                    });
                  },
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildProfilePicture({String? userImageUrl}) {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isProfilePictureHovered = true),
        onExit: (_) => setState(() => isProfilePictureHovered = false),
        child: GestureDetector(
          onTap: _pickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.identity()
              ..scale(isProfilePictureHovered ? 1.05 : 1.0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isProfilePictureHovered
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF2563EB).withOpacity(0.3),
                      width: isProfilePictureHovered ? 4 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF2563EB,
                        ).withOpacity(isProfilePictureHovered ? 0.3 : 0.1),
                        blurRadius: isProfilePictureHovered ? 20 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(child: _buildProfileImage(userImageUrl)),
                  ),
                ),
                if (isProfilePictureHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Change Photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..rotateZ(isProfilePictureHovered ? 0.2 : 0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.5),
                            blurRadius: isProfilePictureHovered ? 12 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isProfilePictureHovered ? Icons.edit : Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? userImageUrl) {
    if (_webImage != null && kIsWeb) {
      return Image.memory(
        _webImage!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    if (_selectedImage != null && !kIsWeb) {
      return Image.file(
        _selectedImage!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    if (userImageUrl != null && userImageUrl.isNotEmpty) {
      return kIsWeb
          ? WebImage(url: buildImageUrl(userImageUrl), width: 100, height: 100)
          : Image.network(
        buildImageUrl(userImageUrl),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return Image.asset(
            Assets.logo,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return Image.asset(Assets.logo, width: 100, height: 100, fit: BoxFit.cover);
  }

  Future<void> _pickImage() async {
    await _pickImageFromSource(ImageSource.gallery);
  }
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _webImage = bytes);
        } else {
          setState(() => _selectedImage = File(pickedFile.path));
        }
        _showSuccessSnackbar(
          'Profile picture selected! Click "Save Changes" to update.',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image. Please try again.');
    }
  }
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTextField(
      bool isEnabled,
      String label,
      TextEditingController controller,
      IconData icon,
      String hint,
      bool isReadOnly,
      {int? maxLength}
      ) {
    return StatefulBuilder(
      builder: (context, setFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
              child: Text(label),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLength: maxLength,
              enabled: false,
              readOnly: true,
              controller: controller,
              enableInteractiveSelection: false,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.3),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                counter: const SizedBox.shrink(),
                hintText: hint,
                prefixIcon: Icon(
                  icon,
                  color: const Color(0xFF94A3B8).withOpacity(0.5),
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  Widget _buildDateField(
      String label,
      TextEditingController controller,
      FocusNode focusNode,
      String hint,
      ) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isFocused ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                  width: isFocused ? 2 : 1,
                ),
                boxShadow: isFocused
                    ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: true,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF94A3B8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      controller.text = _formatDate(picked);
                    });
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildDropdownField(
      String label,
      String value,
      List<String> options,
      bool isExpanded,
      Function(String) onSelected,
      Function() onToggle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isExpanded ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isExpanded
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                  width: isExpanded ? 2 : 1,
                ),
                boxShadow: isExpanded
                    ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.public,
                        color: isExpanded
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isExpanded
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option == value;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onSelected(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: isSelected
                          ? const Color(0xFF2563EB).withOpacity(0.1)
                          : Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF1E293B),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return BlocConsumer<TeacherProfileCubit, TeacherProfileState>(
      listener: (context, state) {
        if (state is TeacherProfileLoaded) {
          _showSuccessSnackbar('Profile updated successfully!');
          setState(() {
            _webImage = null;
            _selectedImage = null;
          });
        } else if (state is TeacherProfileError) {
          _showErrorSnackbar(state.message);
        }
      },
      builder: (context, state) {
        final bool isLoading = state is TeacherProfileLoading;

        return InkWell(
          onTap: isLoading
              ? null
              : () async {
            MultipartFile? image;

            if (kIsWeb && _webImage != null) {
              image = MultipartFile.fromBytes(
                _webImage!,
                filename: 'profile_image.jpg',
              );
            } else if (!kIsWeb && _selectedImage != null) {
              image = await MultipartFile.fromFile(
                _selectedImage!.path,
                filename: _selectedImage!.path.split('/').last,
              );
            }

            context.read<TeacherProfileCubit>().updateProfile(
              city: selectedCity,
              dateOfBirth: selectedDate,
              photo: image,
            );

          },
          child: Center(
            child: Container(
              width: 470,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1849A9),
                    Color(0xFF53B1FD),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<
                            Color
                        >(Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Saving...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w600,
                        fontFamily: 'inter',
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),


                    Icon(Icons.save, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

class DateRangeSelector extends StatelessWidget {

   DateRangeSelector({super.key});
  final List<String> years = [for (int y = 1980; y <= 2030; y++) y.toString()];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start / End Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _buildDropdown('2020')),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdown('2025')),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String initialValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xF3F7FBFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: initialValue,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        decoration: const InputDecoration(border: InputBorder.none),
        items: years
            .map(
              (y) => DropdownMenuItem(
            value: y,
            child: Text(y, style: const TextStyle(fontSize: 15)),
          ),
        )
            .toList(),
        onChanged: (value) {},
      ),
    );
  }
}


