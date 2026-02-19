import 'package:flutter/material.dart';
import 'package:lms/core/helpers/logout_server/logout.dart';
import 'package:lms/features/screens/Announcement/view.dart';
import 'package:lms/features/screens/admin/admin_profile/view.dart';
import 'package:lms/features/screens/admin/courses/Enrollment_course/view.dart';
import 'package:lms/features/screens/admin/courses/create_course/Adding_view.dart';
import 'package:lms/features/screens/admin/courses/home_courses/view.dart';
import 'package:lms/features/screens/admin/department/create_department/view.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/view.dart';
import 'package:lms/features/screens/admin/squadron/create_squadron/view.dart';
import 'package:lms/features/screens/admin/user_file/import_file/view.dart';
import 'package:lms/features/screens/admin/users/create_user/View.dart';
import 'package:lms/features/screens/admin/users/get_users/view.dart';
import 'package:lms/features/screens/admin/year/create_year/view.dart';
import 'package:lms/features/screens/admin/year/get_year/get_All_years/view.dart';

import '../../features/screens/admin/squadron/get_squadron/get_all squadrons/view.dart';

class CustomeSidebar extends StatefulWidget {
  final String selectedMenuItem;

  const CustomeSidebar({super.key, required this.selectedMenuItem});

  @override
  State<CustomeSidebar> createState() => _CustomeSidebarState();
}

class _CustomeSidebarState extends State<CustomeSidebar> {
  String? _hoveredMenuItem;
  bool _isLogoutHovered = false;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          const SizedBox(height: 40),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  Icons.person_outline,
                  Icons.person,
                  'Profile',
                  'Profile',
                  () => _navigate(context, const AdminProfileScreen()),
                ),
                _buildMenuItem(
                  context,
                  Icons.book_outlined,
                  Icons.book,
                  'My Courses',
                  'My Courses',
                  () => _navigate(context, const AdminCourseScreen()),
                ),
                _buildMenuItem(
                  context,
                  Icons.notifications_active_outlined,
                  Icons.notifications_active_rounded,
                  'Announcements',
                  'Announcements',
                  () => _navigate(context, const AnnouncementScreen()),
                ),
                _buildMenuItem(
                  context,
                  Icons.person_add_alt_1_outlined,
                  Icons.person_add_alt_1,
                  'Create Users',
                  'Create users',
                  () => _navigate(context, const CreateUserScreen()),
                ),
                _buildMenuItem(
                  context,
                  Icons.folder_copy_outlined,
                  Icons.folder_copy_rounded,
                  'Create Departments',
                  'Create Departments',
                  () => _navigate(context, CreateDepartmentPage()),
                ),
                _buildMenuItem(
                  context,
                  Icons.calendar_month,
                  Icons.calendar_month_outlined,
                  'Create Years',
                  'Create Years',
                  () => _navigate(context, CreateYearPage()),
                ),
                _buildMenuItem(
                  context,
                  Icons.auto_awesome_motion_rounded,
                  Icons.auto_awesome_motion_outlined,
                  'All Years',
                  'All Years',
                      () => _navigate(context, YearsScreen()),
                ),
                _buildMenuItem(
                  context,
                  Icons.calendar_month,
                  Icons.calendar_month_outlined,
                  'Add Enrollment',
                  'Add Enrollment',
                  () => _navigate(context, EnrollmentPage()),
                ),
                _buildMenuItem(
                  context,
                  Icons.event_available,
                  Icons.event_note_outlined,
                  'Create New Course',
                  'Create New Course',
                  () => _navigate(context, CreateNewCoursePage()),
                ),
                _buildMenuItem(
                  context,
                  Icons.airplanemode_active,
                  Icons.airplanemode_active_rounded,
                  'Create Squadrons',
                  'Create Squadrons',
                  () => _navigate(context, CreateSquadronsPage()),
                ),
                _buildMenuItem(
                  context,
                  Icons.supervised_user_circle_rounded,
                  Icons.supervised_user_circle_outlined,
                  'All Squadrons',
                  'All Squadrons',
                      () => _navigate(context, GetSquadronPage()),
                ),

                _buildMenuItem(
                  context,
                  Icons.supervised_user_circle_rounded,
                  Icons.supervised_user_circle_outlined,
                  'All Users',
                  'All Users',
                  () => _navigate(context, GetUsersPage()),
                ),

                _buildMenuItem(
                  context,
                  Icons.school_outlined,
                  Icons.school,
                  'All Departments',
                  'All Departments',
                  () => _navigate(context, DepartmentsScreen()),
                ),

                _buildMenuItem(
                  context,
                  Icons.file_open_outlined,
                  Icons.file_open,
                  'Import users File',
                  'Import users File',
                  () => _navigate(context, ImportStudentsScreen()),
                ),
                _buildMenuItem(
                  context,
                  Icons.grade_outlined,
                  Icons.grade,
                  'Grades overview',
                  'Grades overview',
                  () {},
                ),
              ],
            ),
          ),

          // ✅ Logout ثابت في الأسفل
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildLogoutButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    final isSelected = widget.selectedMenuItem == value;
    final isHovered = _hoveredMenuItem == value;

    return MouseRegion(
      cursor: isSelected ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredMenuItem = value),
      onExit: (_) => setState(() => _hoveredMenuItem = null),
      child: GestureDetector(
        onTap: isSelected ? null : onTap,
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
              Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: isSelected
                    ? Colors.white
                    : isHovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
                size: 20,
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
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isLogoutHovered = true),
      onExit: (_) => setState(() => _isLogoutHovered = false),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async => await LogoutServer.logout(),
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isLogoutHovered
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isLogoutHovered
                  ? const Color(0xFFEF4444).withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: const [
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
}
