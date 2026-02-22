// ignore_for_file: unused_element

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lms/core/widgets/custome_sidebar.dart';
import 'package:lms/features/screens/admin/courses/create_course/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/courses/create_course/state_managment/states.dart';
import 'package:lms/features/screens/instructor/teacher_profile/view.dart';
import '../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../core/helpers/logout_server/logout.dart';

import '../../Announcement/view.dart';
import '../../admin/admin_profile/view.dart';
import '../../admin/courses/home_courses/view.dart';
import '../../admin/department/get_department/model/model.dart';
import '../../admin/department/get_department/state_mangment/cubit.dart';
import '../../admin/department/get_department/state_mangment/states.dart';
import '../../admin/year/get_year/model.dart';
import '../../admin/year/get_year/state_managment/cubit.dart';
import '../../admin/year/get_year/state_managment/states.dart';
import '../home_courses/view.dart';




class TeacherCreateNewCoursePage extends StatelessWidget {
  const TeacherCreateNewCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateCourseCubit(),
      child: const AddCourseScreen(),
    );
  }
}

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  Uint8List? coverImage;
  Uint8List? introVideo;
  PlatformFile? attachment;
  String selectedAttempts = 'Unlimited Attempts';
  DateTime? selectedDate;

  String? selectedDepartmentId;
  String? selectedYearId;
  List<YearModel> availableYears = [];

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final creditHoursController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isDepartmentExpanded = false;

  String selectedMenuItem = 'Create New Course';
  String? hoveredMenuItem;
  bool isLogoutHovered = false;
  String selectedDepartmentName = 'Select Department';
  String selectedYearName = 'Select Year';
  bool isYearExpanded = false;

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Upload completed successfully',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> pickImage() async {
    final img = await ImagePickerWeb.getImageAsBytes();
    if (img != null) {
      setState(() => coverImage = img);
      showSuccessSnackBar('Image uploaded successfully');
    }
  }

  Future<void> pickVideo() async {
    final video = await ImagePickerWeb.getVideoAsBytes();
    if (video != null) {
      setState(() => introVideo = video);
      showSuccessSnackBar('Video uploaded successfully');
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => attachment = result.files.first);
      showSuccessSnackBar('File uploaded successfully');
    }
  }

  Widget uploadBox({
    required String title,
    required VoidCallback onTap,
    Uint8List? image,
    Uint8List? video,
    PlatformFile? file,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.blue.shade200),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : video != null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, size: 40, color: Colors.blue),
                  SizedBox(height: 8),
                  Text('Video uploaded', style: TextStyle(fontSize: 14)),
                ],
              )
            : file != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insert_drive_file, size: 40, color: Colors.blue),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      file.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 38, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text('Upload $title', style: const TextStyle(fontSize: 14)),
                ],
              ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  IconData _getAttemptsIcon(String? attempts) {
    switch (attempts) {
      case 'Unlimited Attempts':
        return Icons.all_inclusive;
      case '1 Attempt':
        return Icons.looks_one;
      case '3 Attempts':
        return Icons.looks_3;
      case '5 Attempts':
        return Icons.looks_5;
      default:
        return Icons.help_outline;
    }
  }

  Color _getAttemptsColor(String? attempts) {
    switch (attempts) {
      case 'Unlimited Attempts':
        return Colors.green;
      case '1 Attempt':
        return Colors.red;
      case '3 Attempts':
        return Colors.orange;
      case '5 Attempts':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getAttemptsInfo(String? attempts) {
    switch (attempts) {
      case 'Unlimited Attempts':
        return 'No limit';
      case '1 Attempt':
        return 'Strict';
      case '3 Attempts':
        return 'Moderate';
      case '5 Attempts':
        return 'Flexible';
      default:
        return '';
    }
  }

  String _getAttemptsDescription(String? attempts) {
    switch (attempts) {
      case 'Unlimited Attempts':
        return 'Students can attempt the activity as many times as they want. Only the highest score will be recorded.';
      case '1 Attempt':
        return 'Students can only attempt the activity once. Make sure they are prepared before starting.';
      case '3 Attempts':
        return 'Students can attempt the activity up to 3 times. The highest score will be recorded.';
      case '5 Attempts':
        return 'Students can attempt the activity up to 5 times. This provides more flexibility while maintaining some structure.';
      default:
        return 'Select the number of attempts allowed for this activity.';
    }
  }

  void _showChangeNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getAttemptsIcon(selectedAttempts),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('Attempts set to: $selectedAttempts'),
          ],
        ),
        backgroundColor: _getAttemptsColor(selectedAttempts),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MYColors.gradientColor_3,
              MYColors.gradientColor_2.withValues(alpha: 0.25),
              MYColors.gradientColor_3,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            _buildSidebar(),
            BlocConsumer<CreateCourseCubit, CreateCourseState>(
              listener: (context, state) {
                if (state is CreateCourseSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _clearForm();
                }
                if (state is CreateCourseError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: _buildFormContainer(state)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    creditHoursController.clear();

    // setState(() => selectedImageBytes = null);
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      margin: const EdgeInsetsDirectional.only(
        start: 30,
        end: 0,
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherProfileScreen(),
                ),
              );
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
                  builder: (context) => const AnnouncementScreen(),
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
                width: 1,
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
              width: 1,
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

  Widget _buildDropdownField(
    String displayValue,
    List<GetDepartmentModel> departments,
    bool isExpanded,
    Function(GetDepartmentModel) onSelected,
    Function() onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
            color: Colors.blue[900],
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: isExpanded
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        displayValue,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final department = departments[index];
                return InkWell(
                  onTap: () => onSelected(department),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${department.name} (${department.headName})',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (displayValue == department.name)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSecondDropdownField(
    String displayValue,
    List<YearModel> years,
    bool isExpanded,
    Function(YearModel) onSelected,
    Function() onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Year Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
            color: Colors.blue[900],
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: isExpanded
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        displayValue,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 250),
            child: years.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No years already created for this department',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                return InkWell(
                  onTap: () => onSelected(year),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            year.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (displayValue == year.name)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }



  Widget _buildFormContainer(CreateCourseState state) {
    return SingleChildScrollView(
      child: Container(
        width: 1100,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 30)],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Course Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'inter',
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,

                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  hintText: 'Introduction to Marketing',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Course Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'inter',
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Brief overview of what the course covers',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Course CreditHours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'inter',
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: creditHoursController,
                decoration: const InputDecoration(
                  hintText: 'Number of credit hours',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child:
                    BlocProvider(
                      create: (_) => DepartmentsCubitDrop()..fetchDepartments(),
                      child:
                          BlocBuilder<
                            DepartmentsCubitDrop,
                            DepartmentsStateDrop
                          >(
                            builder: (context, departmentState) {
                              if (departmentState is DepartmentLoadingState) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 30),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (departmentState is DepartmentsErrorState) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Text(
                                    'Error: ${departmentState.message}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              if (departmentState is DepartmentLoadedState) {
                                if (departmentState.departments.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Text('No departments found'),
                                  );
                                }

                                List<GetDepartmentModel> departments =
                                    departmentState.departments
                                        .whereType<GetDepartmentModel>()
                                        .toList();

                                return _buildDropdownField(
                                  selectedDepartmentName,
                                  departments,
                                  isDepartmentExpanded,
                                  (chosenDep) {
                                    setState(() {
                                      selectedDepartmentId = chosenDep.id
                                          .toString();
                                      availableYears = chosenDep.years;
                                      selectedYearName = 'Select Year';
                                      selectedYearId = null;
                                      selectedDepartmentName = chosenDep.name;
                                      isDepartmentExpanded = false;
                                    });
                                  },
                                  () => setState(
                                    () => isDepartmentExpanded =
                                        !isDepartmentExpanded,
                                  ),
                                );
                              }

                              return const SizedBox(height: 50);
                            },
                          ),
                    ),
                  ),

                  const SizedBox(width: 30),
                  Expanded(
                    child:
                    BlocProvider(
                      create: (_) => YearsCubitDrop()..fetchYears(),
                      child: BlocBuilder<YearsCubitDrop, YearsStateDrop>(
                        builder: (context, yearState) {
                          if (yearState is YearLoadingState) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (yearState is YearsErrorState) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                'Error: ${yearState.message}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (yearState is YearLoadedState) {
                            if (yearState.years.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text('No years found'),
                              );
                            }

                            // ignore: unused_local_variable
                            List<GetYearModel> years = yearState.years
                                .whereType<GetYearModel>()
                                .toList();

                            return _buildSecondDropdownField(
                              selectedYearName,
                              availableYears,

                              isYearExpanded,
                              (chosenYear) {
                                setState(() {
                                  selectedYearName = chosenYear.name;
                                  selectedYearId = chosenYear.id.toString();

                                  isYearExpanded = false;
                                });
                              },
                              () => setState(
                                () => isYearExpanded = !isYearExpanded,
                              ),
                            );
                          }

                          return const SizedBox(height: 50);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: uploadBox(
                      title: 'Cover Image',
                      onTap: pickImage,
                      image: coverImage,
                      icon: Icons.image,
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 32),
              _buildActionButtons(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(CreateCourseState state) {
    bool isLoading = state is CreateCourseLoading;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedDepartmentName == 'Select Department' ||
                          selectedDepartmentName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a department Name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (selectedYearName == 'Select Year' ||
                          selectedYearName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a year Name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      context.read<CreateCourseCubit>().createCourse(
                        nameController,
                        descriptionController,

                        selectedDepartmentName,
                        selectedYearName,
                        creditHoursController,
                        coverImage,
                      );
                    }
                  },
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1849A9), Color(0xFF53B1FD)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Creating Course...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Create Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
