import 'dart:ui_web' as ui;
import 'dart:html' as html;


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../../../core/cons/Colors/app_colors.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../../../core/helpers/logout_server/logout.dart';
import '../../../../generated/assets.dart';

import '../../admin/courses/home_courses/model/model.dart';
import '../../admin/courses/get_All_courses/state_mangment/cubit.dart';
import '../../admin/courses/home_courses/state_managment/cubit.dart';
import '../../admin/courses/home_courses/state_managment/states.dart';
import '../../admin/courses/update_course/view.dart';
import '../../admin/department/get_department/get_All_departments/view.dart';
import '../../instructor/teacher_profile/view.dart';
String buildProfileImageUrl(String? image) {
  if (image == null || image.isEmpty) return '';
  if (image.startsWith('https')) return image;
  return 'https://skylearn.runasp.net$image';
}


List<GetCoursesModel> courses = [

];


class TeacherCourseScreen extends StatefulWidget {
  const TeacherCourseScreen({super.key});


  @override
  State<TeacherCourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<TeacherCourseScreen> {
  bool _isLoading = true;
  Map<String, dynamic> userData = {};


  String? profileImageUrl;
  String? fullName;
  void _loadProfileImage() async {
    profileImageUrl = await PrefHelper.getImageProfile();
    setState(() {});
  }

  Future<void> _loadUserData() async {
    final data = await PrefHelper.getUserData();
    setState(() {
      userData = data;
    });
  }
  Future<void> _loadFullName() async {
    final name = await PrefHelper.getFulName();
    setState(() {
      fullName = name;
    });
  }


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    // allCourses = courses;

    _loadProfileImage();
    _loadFullName();
    _loadUserData();
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
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
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  "Loading Courses...",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "inter",
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;

    return BlocProvider(
      create: (context) => GetCoursesCubit()..getCourses(),
      child: Container(
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocConsumer<GetCoursesCubit, GetCourseStates>(
            listener: (context, state) {
              if (state is DeleteCourseSuccess) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Course deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                context.read<GetCoursesCubit>().getCourses();
              } else if (state is DeleteCourseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(state.message),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is GetCourseLoading || state is DeleteCourseLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetCourseError) {
                return Center(child: Text(state.message));
              }
              final courses = context.read<GetCoursesCubit>().currentCourses;

              if (state is GetCourseSuccess ||
                  state is DeleteCourseSuccess ||
                  state is DeleteCourseError)     {
                return SafeArea(
                  child: Column(
                    children: [

                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: isLargeScreen
                              ? 1400
                              : (isMediumScreen ? 1000 : double.infinity),
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
                          vertical: 20,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xffE3F6FF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [

                            Expanded(
                              flex: isLargeScreen ? 2 : 1,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xffF8FAFC),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color(0xffE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    hintText: 'Search courses...',
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'inter',
                                      color: Color(0xFF64748B),
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SvgPicture.asset(
                                        Assets.courseSearchIcon,
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF64748B),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),


                            Row(
                              children: [
                                _buildNotificationButton(
                                  icon: Assets.iconsMessageIcon,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 12),
                                _buildNotificationButton(
                                  icon: Assets.iconsBellIcon,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 20),
                                _buildUserProfile(context),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxWidth: isLargeScreen
                                      ? 1400
                                      : (isMediumScreen ? 1000 : double.infinity),
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: isLargeScreen
                                      ? 40
                                      : (isMediumScreen ? 20 : 16),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 20,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Welcome Back",
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xff175CD3,
                                                            ),
                                                            fontSize: isLargeScreen
                                                                ? 36
                                                                : 28,
                                                            fontWeight:
                                                            FontWeight.w700,
                                                            fontFamily: "inter",
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Image.asset(
                                                          Assets.iconsHand,
                                                          width: isLargeScreen
                                                              ? 32
                                                              : 24,
                                                          height: isLargeScreen
                                                              ? 32
                                                              : 24,
                                                        ),
                                                        const Spacer(),
                                                        SizedBox(
                                                          width: isLargeScreen ? 260 : 220,

                                                          child: _buildCoursesCounter(
                                                            count: courses.length,
                                                            isLargeScreen: isLargeScreen,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      "Manage your classes and track your students’ progress easily.",
                                                      style: TextStyle(
                                                        fontSize: isLargeScreen
                                                            ? 16
                                                            : 14,
                                                        fontWeight: FontWeight.w400,
                                                        fontFamily: "inter",
                                                        color: const Color(0xFF64748B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 30),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 20,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          int crossAxisCount;
                                          double childAspectRatio;

                                          if (constraints.maxWidth > 1200) {
                                            crossAxisCount = 4;
                                            childAspectRatio = 1.18;
                                          } else if (constraints.maxWidth > 900) {
                                            crossAxisCount = 3;
                                            childAspectRatio = 1.14;
                                          } else if (constraints.maxWidth > 600) {
                                            crossAxisCount = 2;
                                            childAspectRatio = 1.14;
                                          } else {
                                            crossAxisCount = 1;
                                            childAspectRatio = 1.5;
                                          }

                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                            const NeverScrollableScrollPhysics(),
                                            addAutomaticKeepAlives: false,
                                            addRepaintBoundaries: true,
                                            addSemanticIndexes: false,
                                            cacheExtent: 0,
                                            gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: 20,
                                              mainAxisSpacing: 20,
                                              childAspectRatio:
                                              childAspectRatio,
                                            ),
                                            itemCount: courses.length,
                                            itemBuilder: (context, index) {
                                              final course = courses[index];

                                              return _buildCourseCard(
                                                course,
                                                index,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 40),

                                    Container(

                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 20,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: _buildDangerZone(
                                        context,
                                        courses,
                                      ),
                                    ),// Bottom padding
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }


              //   if (state is GetCourseLoading) {
              //   return const Center(child: CircularProgressIndicator());
              // }

              // if (state is GetCourseError) {
              //   return Center(child: Text(state.message));
              // }
              // if (state is GetCourseSuccess)

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton({
    required String icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffE2E8F0), width: 1),
          ),
          child: Center(
            child: Badge(
              smallSize: 6,
              backgroundColor: const Color(0xffFF3B30),
              offset: const Offset(-1, 1),
              child: SvgPicture.asset(
                icon,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF175CD3),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCourseCard(GetCoursesModel course, int index) {
    return _CourseCardWidget(
      courseModel: course,
      index: index,
      onDelete: (int courseIndex) {
        setState(() {
          if (courseIndex >= 0 && courseIndex < courses.length) {
            courses.removeAt(courseIndex);
          }
        });
      },
    );
  }
  Widget webProfileAvatar({
    required String? imageUrl,
    double radius = 16,
    bool isOnline = true,
  }) {
    final size = radius * 2;
    return Stack(
      children: [
        ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? WebImage(
              url: imageUrl,
              width: size,
              height: size,
            )
                : avatarPlaceholder(size),
          ),
        ),
        onlineIndicator(isOnline: isOnline, size: radius / 2),
      ],
    );
  }


  Widget avatarPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF175CD3),
        ),
      ),
    );
  }
  Widget onlineIndicator({bool isOnline = true, double size = 10}) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? Colors.green : Colors.grey,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    );
  }
  Widget _buildUserProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          webProfileAvatar(
            imageUrl: buildProfileImageUrl(userData['profileImageUrl']),
            radius: 16,
            isOnline: true,
            //   userData["profileImageUrl"]
          ),

          const SizedBox(width: 8),
          Text(
            userData['fullName'] ?? 'User',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'inter',
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Color(0xFF64748B),
              size: 20,
            ),
            onPressed: () => _showUserMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, dynamic courses) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    Text(
                      'These actions are irreversible. Please proceed with caution.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEF4444)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Color(0xFFFFE4E4),
              indent: 24,
              endIndent: 24,
            ),
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildDangerZoneRow(context, course);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDangerZoneRow(BuildContext context, GetCoursesModel course) {
    // final hasStudents = course.enrolledStudentsCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
              // hasStudents
              // ? Colors.grey.withOpacity(0.1)
              // :
              const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.airplanemode_active,
              size: 18,
              color:
              // hasStudents ?
              // Colors.grey :
              const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 13,
                      color:
                      // hasStudents
                      //     ? const Color(0xFFEF4444)
                      //     :

                      const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    // Text(
                    //   hasStudents
                    //       ? '${course.enrolledStudentsCount} student${course.enrolledStudentsCount > 1 ? 's' : ''} — cannot delete'
                    //       :
                    //   'No students — safe to delete',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: hasStudents
                    //         ? const Color(0xFFEF4444)
                    //         : const Color(0xFF64748B),
                    //     fontWeight: hasStudents
                    //         ? FontWeight.w500
                    //         : FontWeight.normal,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Tooltip(
            message:
            // hasStudents
            //     ? 'Remove all students before deleting'
            //     :

            'Delete ${course.title}',
            child: ElevatedButton.icon(
              onPressed:
              // hasStudents
              //     ? null
              //     :
                  () => _showDangerDeleteDialog(context, course),
              icon: const Icon(Icons.delete_forever, size: 16),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDangerDeleteDialog(BuildContext context, dynamic course) {
    final TextEditingController confirmController = TextEditingController();
    final String confirmText = course.title;
    bool isConfirmed = false;
    final cubit = context.read<GetCoursesCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,

          child: StatefulBuilder(
            builder: (_, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  width: 480,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEF4444,
                                ).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_forever,
                                color: Color(0xFFEF4444),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delete Course Permanently',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'This action cannot be undone',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFED7AA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'You are about to permanently delete squadron"${course.title}". This will remove all associated data.',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'To confirm, type the course name below:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.keyboard,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    confirmText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: confirmController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Type course name here...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEF4444),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: isConfirmed
                                    ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                                    : null,
                              ),
                              onChanged: (value) {
                                setDialogState(() {
                                  isConfirmed = value.trim() == confirmText;
                                });
                              },
                            ),
                            if (!isConfirmed &&
                                confirmController.text.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Color(0xFFEF4444),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'course name does not match',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (isConfirmed)
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Name confirmed — you can now delete',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  confirmController.dispose();
                                  Navigator.pop(dialogContext);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF64748B),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child:
                              BlocBuilder<
                                  GetCoursesCubit,
                                  GetCourseStates
                              >(
                                builder: (context, state) {

                                  final isLoading =
                                  state is DeleteCourseLoading;

                                  if (isLoading )
                                  {
                                    return ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFEF4444,
                                        ).withOpacity(0.7),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                        const Color(
                                          0xFFEF4444,
                                        ).withOpacity(0.7),
                                        disabledForegroundColor:
                                        Colors.white,
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const SizedBox(
                                          height: 18,
                                          child:
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 17,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 1.4,
                                                    valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color
                                                    >(Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Deleting...',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    fontFamily: 'inter',
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  }
                                  return ElevatedButton.icon(
                                    onPressed: isConfirmed
                                        ? () {
                                      // Navigator.pop(
                                      //   dialogContext,
                                      // );
                                      cubit.deleteCourse(
                                        course.id,
                                      );
                                    }
                                        : null,
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Delete Forever',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFFEF4444,
                                      ),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                      Colors.grey.shade200,
                                      disabledForegroundColor:
                                      Colors.grey.shade400,
                                      padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                  );


                                  // return isLoading
                                  //     ? ElevatedButton(
                                  //         onPressed: null,
                                  //         style: ElevatedButton.styleFrom(
                                  //           backgroundColor: const Color(
                                  //             0xFFEF4444,
                                  //           ).withOpacity(0.7),
                                  //           foregroundColor: Colors.white,
                                  //           disabledBackgroundColor:
                                  //               const Color(
                                  //                 0xFFEF4444,
                                  //               ).withOpacity(0.7),
                                  //           disabledForegroundColor:
                                  //               Colors.white,
                                  //           padding:
                                  //               const EdgeInsets.symmetric(
                                  //                 vertical: 14,
                                  //               ),
                                  //           shape: RoundedRectangleBorder(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(8),
                                  //           ),
                                  //           elevation: 0,
                                  //         ),
                                  //         child: const SizedBox(
                                  //           height: 18,
                                  //           child:
                                  //               CircularProgressIndicator(
                                  //                 strokeWidth: 2,
                                  //                 color: Colors.white,
                                  //               ),
                                  //         ),
                                  //       )
                                  //     : ElevatedButton.icon(
                                  //         onPressed: isConfirmed
                                  //             ? () {
                                  //                 // Navigator.pop(
                                  //                 //   dialogContext,
                                  //                 // );
                                  //                 cubit.deleteSquadron(
                                  //                   squadron.id,
                                  //                 );
                                  //               }
                                  //             : null,
                                  //         icon: const Icon(
                                  //           Icons.delete_forever,
                                  //           size: 18,
                                  //         ),
                                  //         label: const Text(
                                  //           'Delete Forever',
                                  //           style: TextStyle(
                                  //             fontWeight: FontWeight.w600,
                                  //           ),
                                  //         ),
                                  //         style: ElevatedButton.styleFrom(
                                  //           backgroundColor: const Color(
                                  //             0xFFEF4444,
                                  //           ),
                                  //           foregroundColor: Colors.white,
                                  //           disabledBackgroundColor:
                                  //               Colors.grey.shade200,
                                  //           disabledForegroundColor:
                                  //               Colors.grey.shade400,
                                  //           padding:
                                  //               const EdgeInsets.symmetric(
                                  //                 vertical: 14,
                                  //               ),
                                  //           shape: RoundedRectangleBorder(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(8),
                                  //           ),
                                  //           elevation: 0,
                                  //         ),
                                  //       );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}







  Widget _buildCoursesCounter({
    required int count,
    required bool isLargeScreen,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF175CD3),
            Color(0xFF4F8DFD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Courses = ',
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              fontFamily: 'inter',
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: isLargeScreen ? 36 : 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'inter',
            ),
          ),
        ],
      ),
    );
  }





class _CourseCardWidget extends StatefulWidget {
  final GetCoursesModel courseModel ;

  final int index;
  final ValueChanged<int> onDelete;

  const _CourseCardWidget({
    required this.index,
    required this.onDelete, required this.courseModel,
  });

  @override
  State<_CourseCardWidget> createState() => _CourseCardWidgetState();
}

class _CourseCardWidgetState extends State<_CourseCardWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () {
       ///todo:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📘 Selected: ${widget.courseModel.title}'),
              backgroundColor: const Color(0xFF175CD3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: AnimatedScale(
          scale: isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(12),
            width: 304,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: isHovered
                  ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 5,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),

                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 304,
                  height: 164,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child:    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: widget.courseModel.imageUrl.isNotEmpty
                          ? IgnorePointer(
                        child: WebImage(
                          url: buildImageUrl(widget.courseModel.imageUrl),
                          width: double.infinity,
                          height: 120,
                        ),
                      )
                          : const SizedBox(
                        height: 120,
                        child: Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SizedBox(
                    width: 304,
                    height: 86,
                    // padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        Text(
                          widget.courseModel.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'inter',
                            color: Color(0xFF175CD3),
                          ),
                          // maxLines: 2,
                          // overflow: TextOverflow.ellipsis,
                        ),






                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.courseModel.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'inter',
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            InkWell(
                              onTap: () {

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<GetCoursesCubit>(),
                                      child: UpdateNewCoursePage(courseId: widget.courseModel.id),
                                    ),
                                  ),
                                );

                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Color(0xff175CD3),
                                child: Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),

                                //),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                            children: [
                              Text('Enrolled Students = ${widget.courseModel.enrolledStudentsCount}',style:
                              const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF64748B),
                                fontFamily: 'inter',
                              ),),
                            ]
                        )

                      ],
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
  String buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    return 'http://skylearn.runasp.net${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
  }

}
class WebImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  WebImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  }) {
    _register();
  }

  static final Set<String> _registeredViews = {};

  void _register() {
    if (_registeredViews.contains(url)) return;

    ui.platformViewRegistry.registerViewFactory(url, (int _) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      return img;
    });

    _registeredViews.add(url);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: url),
    );
  }
}


void _showUserMenu(BuildContext context) async {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
  Overlay.of(context).context.findRenderObject() as RenderBox;

  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );

  final result = await showMenu<String>(
    context: context,
    position: position,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    items: [
      const PopupMenuItem<String>(
        value: 'profile',
        child: Row(
          children: [
            Icon(Icons.person, color: Color(0xFF175CD3)),
            SizedBox(width: 8),
            Text(
              'Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      const PopupMenuItem<String>(
        value: 'settings',
        child: Row(
          children: [
            Icon(Icons.settings, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text(
              'Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem<String>(
        value: 'logout',
        child: Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  if (result == 'logout') {
    await LogoutServer.logout();
  } else if (result == 'profile') {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherProfileScreen()));

  } else if (result == 'settings') {
    // TODO: Add settings action later
  }
}
