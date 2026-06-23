import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/management/management_layout.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';
import 'package:lms/features/screens/admin/courses/Enrollment_course/state_mangment/cubits.dart';
import 'package:lms/features/screens/admin/courses/Enrollment_course/state_mangment/states.dart';
import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/model_dropdown/view.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/state_managment/states.dart';

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

  String selectedUserName = 'Select user';
  String selectedCourseName = 'Select Course';

  String selectedMenuItem = 'Add Enrollment';
  String? hoveredMenuItem;
  bool isLogoutHovered = false;

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
      selectedMenuItem: selectedMenuItem,
      role: ManagementRole.admin,
      child: BlocConsumer<EnrollmentCubit, EnrollmentState>(
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
    );
  }

  void _clearForm() {
    setState(() {
      selectedUserId = null;
      selectedCourseId = null;
    });
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
          'User Name',
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
                            '${user.fullName} (${user.role})',
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
    List<GetCoursesModel> courses,
    bool isExpanded,
    Function(GetCoursesModel) onSelected,
    Function() onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Name',
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
            child: courses.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No courses already created ',
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
                                'Error: ${UsersStateDrop.message}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (UsersStateDrop is UsersLoadedState) {
                            if (UsersStateDrop.users.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text('No users found'),
                              );
                            }

                            final List<UserLiteModel> users = UsersStateDrop
                                .users
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
                      create: (_) => GetCoursesCubit()..getCourses(),
                      child: BlocBuilder<GetCoursesCubit, GetCourseStates>(
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
                                'Error: ${courseState.message}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (courseState is GetCourseSuccess) {
                            if (courseState.courses.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text('No courses found'),
                              );
                            }

                            final List<GetCoursesModel> courses = courseState
                                .courses
                                .whereType<GetCoursesModel>()
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
                  if (state is EnrollmentActionSuccess) {}

                  if (state is EnrollmentError) {}
                },
                buildWhen: (previous, current) =>
                    current is EnrollmentLoaded || current is EnrollmentLoading,
                builder: (context, state) {
                  if (state is EnrollmentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is EnrollmentLoaded) {
                    if (state.enrollments.isEmpty) {
                      return const Text('No enrollments yet');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Enrolled students',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${state.enrollments.length} enrollments',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1849A9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Animated list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.enrollments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final enrollment = state.enrollments[index];
                            final initials = enrollment.userName
                                .trim()
                                .split(' ')
                                .take(2)
                                .map(
                                  (w) => w.isNotEmpty ? w[0].toUpperCase() : '',
                                )
                                .join();

                            return TweenAnimationBuilder<double>(
                              key: ValueKey(
                                '${enrollment.userId}-${enrollment.courseId}',
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 300 + index * 60,
                              ),
                              curve: Curves.easeOut,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 16 * (1 - value)),
                                  child: child,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Avatar circle
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFEFF6FF),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1849A9),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Name + course badge
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            enrollment.userName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                                width: 0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.menu_book_outlined,
                                                  size: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  enrollment.courseName,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Delete button
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        context
                                            .read<EnrollmentCubit>()
                                            .deleteEnrollment(
                                              enrollment.userId,
                                              enrollment.courseId,
                                            );
                                      },
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                            width: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
    final bool isLoading = state is EnrollmentLoading;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedUserName == 'Select User' ||
                          selectedUserName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a user Name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (selectedCourseName == 'Select course' ||
                          selectedCourseName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a course Name'),
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
                            'Adding Enrollment...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Add Enrollment',
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
