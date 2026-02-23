import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_bar.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import '../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../core/helpers/logout_server/logout.dart';
import '../../../../../generated/assets.dart';
import '../../department/get_department/get_All_departments/view.dart';
import '../get_All_courses/state_mangment/cubit.dart';
import 'model/model.dart';

List<GetCourseModel> courses = [

];


class AdminCourseScreen extends StatefulWidget {
  const AdminCourseScreen({super.key});

  @override
  State<AdminCourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<AdminCourseScreen> {
  bool _isLoading = true;

  String? imageProfile;

  // void loadImageProfile() async {
  //   imageProfile = await PrefHelper.getImageProfile();
  //   setState(() {});
  // }
  // List <CourseModel> allCourses = [];
  @override
  void initState() {
    super.initState();
    // Simulate loading time and then show content
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    // allCourses = courses;

    // loadImageProfile();
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
        child: Scaffold(
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
      create: (context) => GetCourseCubit()..getCourses(),
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
          appBar: CustomAppBar(),
          backgroundColor: Colors.transparent,
          body: BlocBuilder<GetCourseCubit, GetCourseState>(
            builder: (context, state) {
              if (state is GetCourseLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is GetCourseError) {
                return Center(child: Text(state.message));
              }
              if (state is GetCourseSuccess) {
                return SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: 20),


                      Expanded(
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
                                  padding: EdgeInsets.all(24),
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
                                        offset: Offset(0, 10),
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
                                                        color: Color(
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
                                                    SizedBox(width: 8),
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
                                                        count: state.courses.length,
                                                        isLargeScreen: isLargeScreen,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "Manage your classes and track your students’ progress easily.",
                                                  style: TextStyle(
                                                    fontSize: isLargeScreen
                                                        ? 16
                                                        : 14,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "inter",
                                                    color: Color(0xFF64748B),
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
                                SizedBox(height: 30),

                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(24),
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
                                        offset: Offset(0, 8),
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
                                SizedBox(height: 40), // Bottom padding
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
            },
          ),
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
            "Total Courses = ",
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              fontFamily: "inter",
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "$count",
            style: TextStyle(
              fontSize: isLargeScreen ? 36 : 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: "inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(GetCourseModel course, int index) {
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

}

class _CourseCardWidget extends StatefulWidget {
  final GetCourseModel courseModel ;

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
          /// Todo:

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("📘 Selected: ${widget.courseModel.title}"),
              backgroundColor: Color(0xFF175CD3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: AnimatedScale(
          scale: isHovered ? 1.08 : 1.0,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(12),
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
                  offset: Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 5,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),

                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
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
                    borderRadius: BorderRadius.only(
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
                        SizedBox(height: 6),

                        Text(
                          widget.courseModel.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: "inter",
                            color: Color(0xFF175CD3),
                          ),
                          // maxLines: 2,
                          // overflow: TextOverflow.ellipsis,
                        ),






                        SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.courseModel.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "inter",
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            /// TODO : ADJUST EDIT COURSE
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DepartmentsScreen(),
                                  ),
                                );
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text("data")));
                              },
                              child: CircleAvatar(
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
                        SizedBox(height: 6),
                        Row(
                            children: [
                              Text("Enrolled Students = ${widget.courseModel.enrolledStudentsCount}",style:
                              TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF64748B),
                                fontFamily: "inter",
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
              "Profile",
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
              "Settings",
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
              "Logout",
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
    // TODO: Add profile action later
  } else if (result == 'settings') {
    // TODO: Add settings action later
  }
}