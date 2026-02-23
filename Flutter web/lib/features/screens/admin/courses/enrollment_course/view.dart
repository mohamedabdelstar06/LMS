import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/Colors/app_colors.dart';
import 'package:lms/core/helpers/logout_server/logout.dart';
import 'package:lms/features/screens/Announcement/view.dart';
import 'package:lms/features/screens/admin/admin_profile/view.dart';
import 'package:lms/features/screens/admin/courses/Enrollment_course/state_mangment/cubits.dart';
import 'package:lms/features/screens/admin/courses/Enrollment_course/state_mangment/states.dart';
import 'package:lms/features/screens/admin/courses/create_course/Adding_view.dart';
import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import 'package:lms/features/screens/admin/courses/home_courses/view.dart';
import 'package:lms/features/screens/admin/department/create_department/view.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/view.dart';
import 'package:lms/features/screens/admin/squadron/create_squadron/view.dart';
import 'package:lms/features/screens/admin/user_file/import_file/view.dart';
import 'package:lms/features/screens/admin/users/create_user/View.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/model_dropdown/view.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/state_managment/states.dart';
import 'package:lms/features/screens/admin/users/get_users/view.dart';
import 'package:lms/features/screens/admin/year/create_year/view.dart';
import 'package:lms/features/screens/admin/year/get_year/get_All_years/view.dart';

import '../home_courses/state_managment/cubit.dart';


class EnrollmentPage extends StatelessWidget {
  const EnrollmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnrollmentCubit(),
      child: const EnrollmentScreen(),
    );
  }
}

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _AddEnrollmentState();
}

class _AddEnrollmentState extends State<EnrollmentScreen> {
  int? selectedUserId;
  int? selectedCourseId;

  final _formKey = GlobalKey<FormState>();
  bool isUsersExpanded = false;
  bool isCourseExpanded = false;

  String selectedUserName = "Select user";
  String selectedCourseName = "Select Course";

  String selectedMenuItem = 'Add Enrollment';
  String? hoveredMenuItem;
  bool isLogoutHovered = false;

  // void showSuccessSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       behavior: SnackBarBehavior.floating,
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       content: TweenAnimationBuilder<double>(
  //         tween: Tween(begin: 0, end: 1),
  //         duration: const Duration(milliseconds: 400),
  //         builder: (context, value, child) {
  //           return Transform.scale(scale: value, child: child);
  //         },
  //         child: Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.green.shade600,
  //             borderRadius: BorderRadius.circular(14),
  //             boxShadow: const [
  //               BoxShadow(color: Colors.black26, blurRadius: 10),
  //             ],
  //           ),
  //           child: Row(
  //             children: const [
  //               Icon(Icons.check_circle, color: Colors.white),
  //               SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   "Upload completed successfully",
  //                   style: TextStyle(color: Colors.white, fontSize: 15),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            BlocConsumer<EnrollmentCubit, EnrollmentState>(
              listener: (context, state) {
                if (state is EnrollmentActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _clearForm();
                }
                if (state is EnrollmentError) {
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
    setState(() {
      selectedUserId = null;
      selectedCourseId = null;
    });
  }

  // setState(() => selectedImageBytes = null);

  Widget _buildSidebar() {
    return Container(
      width: 250,
      margin: const EdgeInsetsDirectional.only(
        start: 40,
        end: 0,
        top: 50,
        bottom: 50,
      ),
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
      child: ListView(
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
                  builder: (context) => const AdminProfileScreen(),
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
                  builder: (context) => const AdminCourseScreen(),
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
                  builder: (context) => const AnnouncementScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            Icons.person_add_alt_1_outlined,
            Icons.person_add_alt_1,
            'Create Users',
            'Create users',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateUserScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            Icons.folder_copy_outlined,
            Icons.folder_copy_rounded,
            'Create Departments',
            'Create Departments',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateDepartmentPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.calendar_month,
            Icons.calendar_month_outlined,
            'Create Years',
            'Create Years',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateYearPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.calendar_month,
            Icons.calendar_month_outlined,
            'Add Enrollment',
            'Add Enrollment',
            () {},
          ),
          _buildMenuItem(
            Icons.event_available,
            Icons.event_note_outlined,
            'Create New Course',
            'Create New Course',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateNewCoursePage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.airplanemode_active,
            Icons.airplanemode_active_rounded,
            'Create Squadrons',
            'Create Squadrons',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateSquadronsPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.supervised_user_circle_rounded,
            Icons.supervised_user_circle_outlined,
            'All Users',
            'All Users',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GetUsersPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.school_outlined,
            Icons.school,
            'All Departments',
            'All Departments',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DepartmentsScreen()),
              );
            },
          ),
          _buildMenuItem(
            Icons.auto_awesome_motion_rounded,
            Icons.auto_awesome_motion_outlined,
            'All Years',
            'All Years',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => YearsScreen()),
              );
            },
          ),

          _buildMenuItem(
            Icons.file_open_outlined,
            Icons.file_open,
            'Import users File',
            'Import users File',
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ImportStudentsScreen()),
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
          child: Row(
            children: [
              Icon(Icons.logout, color: const Color(0xFFEF4444), size: 20),
              const SizedBox(width: 12),
              const Text(
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
    List<UserLiteModel> users,
    bool isExpanded,
    Function(UserLiteModel) onSelected,
    Function() onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "User Name",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "inter",
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
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return InkWell(
                  onTap: () => onSelected(user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${user.fullName} (${user.role})",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (displayValue == user.fullName)
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
    List<GetCourseModel> courses,
    bool isExpanded,
    Function(GetCourseModel) onSelected,
    Function() onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Course Name",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "inter",
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
            child: courses.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        "No courses already created ",
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
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return InkWell(
                        onTap: () => onSelected(course),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              if (displayValue == course.title)
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

  Widget _buildFormContainer(EnrollmentState state) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BlocProvider(
                      create: (_) => UsersCubitDrop()..fetchStudents(),
                      child: BlocBuilder<UsersCubitDrop, UsersStateDrop>(
                        builder: (context, UsersStateDrop) {
                          if (UsersStateDrop is UsersLoadingState) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (UsersStateDrop is UsersErrorState) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                "Error: ${UsersStateDrop.message}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (UsersStateDrop is UsersLoadedState) {
                            if (UsersStateDrop.users.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text("No users found"),
                              );
                            }

                            List<UserLiteModel> users = UsersStateDrop.users
                                .whereType<UserLiteModel>()
                                .toList();

                            return _buildDropdownField(
                              selectedUserName,
                              users,
                              isUsersExpanded,
                              (chosenUser) {
                                setState(() {
                                  selectedUserId = chosenUser.id;

                                  selectedUserName = chosenUser.fullName;
                                  isUsersExpanded = false;
                                });
                              },
                              () => setState(
                                () => isUsersExpanded = !isUsersExpanded,
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
                    child: BlocProvider(
                      create: (_) => GetCourseCubit()..getCourses(),
                      child: BlocBuilder<GetCourseCubit, GetCourseState>(
                        builder: (context, courseState) {
                          if (courseState is GetCourseLoading) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (courseState is GetCourseError) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                "Error: ${courseState.message}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (courseState is GetCourseSuccess) {
                            if (courseState.courses.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text("No courses found"),
                              );
                            }

                            List<GetCourseModel> courses = courseState.courses
                                .whereType<GetCourseModel>()
                                .toList();

                            return _buildSecondDropdownField(
                              selectedCourseName,
                              courses,
                              isCourseExpanded,
                              (chosenCourse) {
                                setState(() {
                                  selectedCourseName = chosenCourse.title;
                                  selectedCourseId = chosenCourse.id;

                                  isCourseExpanded = false;
                                });
                              },
                              () => setState(
                                () => isCourseExpanded = !isCourseExpanded,
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

              _buildActionButtons(state),

              const SizedBox(height: 24),

              BlocConsumer<EnrollmentCubit, EnrollmentState>(
                listenWhen: (previous, current) =>
                    current is EnrollmentActionSuccess ||
                    current is EnrollmentError,
                listener: (context, state) {
                  if (state is EnrollmentActionSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }

                  if (state is EnrollmentError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                buildWhen: (previous, current) =>
                    current is EnrollmentLoaded || current is EnrollmentLoading,
                builder: (context, state) {
                  if (state is EnrollmentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is EnrollmentLoaded) {
                    if (state.enrollments.isEmpty) {
                      return const Text("No enrollments yet");
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.enrollments.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final enrollment = state.enrollments[index];

                        return ListTile(
                          key: ValueKey(
                            "${enrollment.userId}-${enrollment.courseId}",
                          ),
                          title: Text(enrollment.userName),
                          subtitle: Text(enrollment.courseName),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<EnrollmentCubit>().deleteEnrollment(
                                enrollment.userId,
                                enrollment.courseId,
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(EnrollmentState state) {
    bool isLoading = state is EnrollmentLoading;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedUserName == "Select User" ||
                          selectedUserName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a user Name"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (selectedCourseName == "Select course" ||
                          selectedCourseName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a course Name"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      context.read<EnrollmentCubit>().createEnrollment(
                        studentId: selectedUserId!,
                        courseId: selectedCourseId!,
                        userName: selectedUserName,
                        courseName: selectedCourseName,
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
                            "Adding Enrollment...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        "Add Enrollment",
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
