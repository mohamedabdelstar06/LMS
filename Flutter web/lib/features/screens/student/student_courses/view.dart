import 'dart:ui_web' as ui;
import 'dart:html' as html;


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms/features/screens/admin/Noti_button.dart';
import 'package:lms/features/screens/student/student_courses/course_details_screen.dart';
import 'package:lms/features/screens/student/student_courses/state_managment/cubit.dart';
import 'package:lms/features/screens/student/student_courses/state_managment/states.dart';
import 'package:lms/features/screens/student_dashboard_screen.dart';

import '../../../../core/cons/Colors/app_colors.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../../../core/helpers/logout_server/logout.dart';
import '../../../../generated/assets.dart';
import '../../student/student_profile/view.dart' hide buildImageUrl;
import 'model/view.dart';

String buildProfileImageUrl(String? image) {
  if (image == null || image.isEmpty) return '';
  if (image.startsWith('https')) return image;
  return 'https://skylearn.runasp.net$image';
}



class StudentCourseScreen extends StatefulWidget {
  const StudentCourseScreen({super.key});

  @override
  State<StudentCourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<StudentCourseScreen> {
  bool _isLoading = true;
  Map<String, dynamic> userData = {};







String? imageProfile;



void loadImageProfile() async {
  imageProfile = await PrefHelper.getImageProfile();
  setState(() {});
}
  Future<void> _loadUserData() async {
    final data = await PrefHelper.getUserData();
    setState(() {
      userData = data;
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

    loadImageProfile();
    _loadUserData();

  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return
        Container(
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
                  'Loading Courses...',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'inter',
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
  create: (context) => GetCourseStudentCubit()..getCourses(),
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
        body: BlocBuilder<GetCourseStudentCubit, GetCourseStudentState>(
  builder: (context, state) {
    if (state is GetCourseStudentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GetCourseStudentError) {
      return Center(child: Text(state.message));
    }
    if (state is GetCourseStudentSuccess) {
      return SafeArea(
        child: Column(
          children: [
            CoursesAppBar()
        /*    Container(
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
FutureBuilder<String?>(
                                  future: TokenStorageHelper.getTokenSecure(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }

                                    return NotificationBellButton(
                                      token: snapshot.data!,
                                      role: 'student',
                                    );
                                  },
                                ),
                      const SizedBox(width: 20),
                      buildUserProfile(context),
                    ],
                  ),
                ],
              ),
            ),*/

            ,Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
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
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                            'Welcome Back',
                                            style: TextStyle(
                                              color: const Color(0xff175CD3),

                                              fontSize: isLargeScreen
                                                  ? 36
                                                  : 28,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'inter',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Image.asset(
                                            Assets.iconsHand,
                                            width: isLargeScreen ? 32 : 24,
                                            height: isLargeScreen ? 32 : 24,
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            width: isLargeScreen ? 260 : 220,

                                            child: _buildCoursesCounter(
                                              count: state.courses.length,
                                              isLargeScreen: isLargeScreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Start your learning journey now — your next big achievement starts here!',
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 16 : 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'inter',
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
                              color: Colors.grey.withValues(alpha: 0.15),
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
                              physics: const NeverScrollableScrollPhysics(),
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: true,
                              addSemanticIndexes: false,
                              cacheExtent: 0,
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: state.courses.length,
                              itemBuilder: (context, index) {
                                final course = state.courses[index];

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

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }),
      ),
    ),
);
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




 /* Widget buildUserProfile(BuildContext context) {
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
            onPressed: () => showUserMenu(context),
          ),
        ],
      ),
    );
  }*/

  Widget _buildCourseCard(CourseEnrollmentModel course, int index) {
    return _CourseCardWidget(
      courseModel: course,
      index: index,

    );
  }
}

class _CourseCardWidget extends StatefulWidget {
  final CourseEnrollmentModel courseModel;
  final int index;

  const _CourseCardWidget({
    required this.courseModel,
    required this.index,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailsScreen(
                courseId: widget.courseModel.courseId,
                preview: widget
                    .courseModel, // عشان العنوان/الصورة يظهروا فوراً من غير ما تستنى الـ API
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
          boxShadow: isHovered ? [
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
          ] : [
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                             Text(
                               widget.courseModel.courseTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'inter',
                                color: Color(0xFF175CD3),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                             Text(
                               widget.courseModel.courseDescription,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'inter',
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFF59E0B),
                                  size: 14,
                                ),
                                const Spacer(),
                                 Text(
                                   '${widget.courseModel.creditHours} Hours',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
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

  }


void showUserMenu(BuildContext context) async {
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
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StudentProfileScreen(),));

  } else if (result == 'settings') {
    // TODO: Add settings action later
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


class CoursesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CoursesAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(400);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1200;
    final isMediumScreen = screenWidth >= 800 && screenWidth < 1200;
    return SafeArea(
      child:             Container(
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
                  border: Border.all(color: const Color(0xffE2E8F0), width: 1),
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
                FutureBuilder<String?>(
                  future: TokenStorageHelper.getTokenSecure(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    return NotificationBellButton(
                      token: snapshot.data!,
                      role: 'student',
                    );
                  },
                ),
                const SizedBox(width: 20),
                buildUserProfile(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserProfile(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentDashboardScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffE2E8F0), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.space_dashboard_rounded,
                color: Color(0xFF175CD3),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Management',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'inter',
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

