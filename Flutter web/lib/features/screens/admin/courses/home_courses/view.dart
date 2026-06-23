import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/management/management_layout.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import 'package:lms/features/screens/admin/courses/update_course/view.dart';
import '../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../core/helpers/logout_server/logout.dart';
import '../../../../../generated/assets.dart';
import '../course_details/layout.dart';
import '../get_All_courses/state_mangment/cubit.dart';
import 'model/model.dart';

List<GetCoursesModel> courses = [];

class AdminCourseScreen extends StatefulWidget {
  const AdminCourseScreen({super.key});

  @override
  State<AdminCourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<AdminCourseScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ManagementScaffold(
        selectedMenuItem: 'My Courses',
        role: ManagementRole.admin,
        child: Center(
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
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;

    return BlocProvider(
      create: (context) => GetCoursesCubit()..getCourses(),
      child: ManagementScaffold(
        selectedMenuItem: 'My Courses',
        role: ManagementRole.admin,
        child: BlocConsumer<GetCoursesCubit, GetCourseStates>(
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
              if (
              state is GetCourseLoading ||
                  state is DeleteCourseLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetCourseError) {
                return Center(child: Text(state.message));
              }
              final courses = context.read<GetCoursesCubit>().currentCourses;

              if (state is GetCourseSuccess ||
                  state is DeleteCourseSuccess ||
                  state is DeleteCourseError) {
                return SafeArea(
                  child: Column(
                    children: [
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
                                        color:
                                        Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                                alpha: 0.05),
                                            blurRadius: 20,
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
                                                          'Welcome Back',
                                                          style: TextStyle(
                                                            color: const Color(
                                                                0xff175CD3),
                                                            fontSize:
                                                            isLargeScreen
                                                                ? 36
                                                                : 28,
                                                            fontWeight:
                                                            FontWeight.w700,
                                                            fontFamily: 'inter',
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
                                                          width: isLargeScreen
                                                              ? 260
                                                              : 220,
                                                          child:
                                                          _buildCoursesCounter(
                                                            count:
                                                            courses.length,
                                                            isLargeScreen:
                                                            isLargeScreen,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Manage your classes and track your students\' progress easily.',
                                                      style: TextStyle(
                                                        fontSize: isLargeScreen
                                                            ? 16
                                                            : 14,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        fontFamily: 'inter',
                                                        color: const Color(
                                                            0xFF64748B),
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
                                            color: Colors.grey
                                                .withValues(alpha: 0.15),
                                            blurRadius: 20,
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
                                          } else if (constraints.maxWidth >
                                              900) {
                                            crossAxisCount = 3;
                                            childAspectRatio = 1.3;
                                          } else if (constraints.maxWidth >
                                              600) {
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
                                            addSemanticIndexes: false,
                                            cacheExtent: 0,
                                            gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: 20,
                                              mainAxisSpacing: 20,
                                              childAspectRatio: childAspectRatio,
                                            ),
                                            itemCount: courses.length,
                                            itemBuilder: (context, index) {
                                              final course = courses[index];
                                              return _buildCourseCard(
                                                  course, index);
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
                                            color: Colors.grey
                                                .withValues(alpha: 0.15),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: _buildDangerZone(context, courses),
                                    ),
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
              return const SizedBox();
            },
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
          colors: [Color(0xFF175CD3), Color(0xFF4F8DFD)],
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

  Widget _buildCourseCard(GetCoursesModel course, int index) {
    return _CourseCardWidget(
      courseModel: course,
      index: index,
      onDelete: (courseIndex) {},
    );
  }
}

class _CourseCardWidget extends StatefulWidget {
  const _CourseCardWidget({
    required this.index,
    required this.onDelete,
    required this.courseModel,
  });

  final GetCoursesModel courseModel;
  final int index;
  final ValueChanged<int> onDelete;

  @override
  State<_CourseCardWidget> createState() => _CourseCardWidgetState();
}

class _CourseCardWidgetState extends State<_CourseCardWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CourseLayout(courseModel: widget.courseModel),
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
              ),
              boxShadow: isHovered
                  ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
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
                    borderRadius: BorderRadius.circular(16),
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
                Expanded(
                  child: SizedBox(
                    width: 304,
                    height: 86,
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
                                      child: UpdateNewCoursePage(
                                        courseId: widget.courseModel.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Color(0xff175CD3),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enrolled Students = ${widget.courseModel.enrolledStudentsCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            fontFamily: 'inter',
                          ),
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

  String buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    return 'http://skylearn.runasp.net${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
  }
}

class WebImage extends StatelessWidget {
  WebImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  }) {
    _register();
  }

  final String url;
  final double width;
  final double height;

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
            Text('Profile',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      const PopupMenuItem<String>(
        value: 'settings',
        child: Row(
          children: [
            Icon(Icons.settings, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text('Settings',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
            Text('Logout',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626))),
          ],
        ),
      ),
    ],
  );

  if (result == 'logout') {
    await LogoutServer.logout();
  }
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
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.co_present,
            size: 18,
            color: Color(0xFF2563EB),
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
              // const Row(
              //   children: [
              //     Icon(Icons.people_outline, size: 13, color: Color(0xFF64748B)),
              //   ],
              // ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Tooltip(
          message: 'Delete ${course.title}',
          child: ElevatedButton.icon(
            onPressed: () => _showDangerDeleteDialog(context, course),
            icon: const Icon(Icons.delete_forever, size: 16),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(16)),
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
                              color:
                              const Color(0xFFEF4444).withOpacity(0.15),
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
                                  color: const Color(0xFFFED7AA)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 16, color: Color(0xFFD97706)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'You are about to permanently delete "${course.title}". This will remove all associated data.',
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
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.keyboard,
                                    size: 14, color: Color(0xFF64748B)),
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
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEF4444), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: isConfirmed
                                  ? const Icon(Icons.check_circle,
                                  color: Colors.green)
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
                                  Icon(Icons.close,
                                      size: 14, color: Color(0xFFEF4444)),
                                  SizedBox(width: 4),
                                  Text(
                                    'course name does not match',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFEF4444)),
                                  ),
                                ],
                              ),
                            ),
                          if (isConfirmed)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.check,
                                      size: 14, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'Name confirmed — you can now delete',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.green),
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
                                    color: Color(0xFFE2E8F0)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BlocBuilder<GetCoursesCubit,
                                GetCourseStates>(
                              builder: (context, state) {
                                final isLoading =
                                state is DeleteCourseLoading;
                                if (isLoading) {
                                  return ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444)
                                          .withOpacity(0.7),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                      const Color(0xFFEF4444)
                                          .withOpacity(0.7),
                                      disabledForegroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const SizedBox(
                                      height: 18,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 17,
                                              child:
                                              CircularProgressIndicator(
                                                strokeWidth: 1.4,
                                                valueColor:
                                                AlwaysStoppedAnimation<
                                                    Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Deleting...',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'inter',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ElevatedButton.icon(
                                  onPressed: isConfirmed
                                      ? () => cubit.deleteCourse(course.id)
                                      : null,
                                  icon: const Icon(Icons.delete_forever,
                                      size: 18),
                                  label: const Text('Delete Forever',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                    Colors.grey.shade200,
                                    disabledForegroundColor:
                                    Colors.grey.shade400,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                );
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