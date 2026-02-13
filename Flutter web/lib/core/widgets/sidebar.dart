import 'package:flutter/material.dart';
import 'package:lms/features/screens/Create_department/view.dart';

import '../../features/screens/Announcement/view.dart';
import '../../features/screens/Create_user/View.dart';
import '../../features/screens/add_course/Adding_view.dart';
import '../../features/screens/admin/Enrollment_course/view.dart';
import '../../features/screens/admin/create_years/view.dart';
import '../../features/screens/admin/get_department/get_All_departments/view.dart';
import '../../features/screens/admin/get_years/get_All_years/view.dart';
import '../../features/screens/admin/import_file/view.dart';
import '../../features/screens/courses/admin/view.dart';
import '../../features/screens/create_squadron/view.dart';
import '../../features/screens/get_users/view.dart';
import '../helpers/logout_server/logout.dart';


class ProfileSidebar extends StatelessWidget {
  final String selectedMenuItem;
  final String? hoveredMenuItem;
  final bool isLogoutHovered;
  final Function(String) onMenuItemSelected;
  final Function(String) onMenuItemHovered;
  final VoidCallback onLogoutHovered;
  final VoidCallback onLogoutExited;

  const ProfileSidebar({
    super.key,
    required this.selectedMenuItem,
    this.hoveredMenuItem,
    required this.isLogoutHovered,
    required this.onMenuItemSelected,
    required this.onMenuItemHovered,
    required this.onLogoutHovered,
    required this.onLogoutExited,
  });

  static const List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.person_outline,
      'selectedIcon': Icons.person,
      'title': 'Profile',
      'value': 'Profile',
      'route': null,
    },
    {
      'icon': Icons.book_outlined,
      'selectedIcon': Icons.book,
      'title': 'My Courses',
      'value': 'My Courses',
      'route': AdminCourseScreen,
    },
    {
      'icon': Icons.notifications_active_outlined,
      'selectedIcon': Icons.notifications_active_rounded,
      'title': 'Announcements',
      'value': 'Announcements',
      'route': AnnouncementScreen,
    },
    {
      'icon': Icons.person_add_alt_1_outlined,
      'selectedIcon': Icons.person_add_alt_1,
      'title': 'Create Users',
      'value': 'Create users',
      'route': CreateUserScreen,
    },
    {
      'icon': Icons.folder_copy_outlined,
      'selectedIcon': Icons.folder_copy_rounded,
      'title': 'Create Departments',
      'value': 'Create Departments',
      'route': CreateDepartmentPage,
    },
    {
      'icon': Icons.calendar_month,
      'selectedIcon': Icons.calendar_month_outlined,
      'title': 'Create Years',
      'value': 'Create Years',
      'route': CreateYearPage,
    },
    {
      'icon': Icons.calendar_month,
      'selectedIcon': Icons.calendar_month_outlined,
      'title': 'Add Enrollment',
      'value': 'Add Enrollment',
      'route': EnrollmentPage,
    },
    {
      'icon': Icons.event_available,
      'selectedIcon': Icons.event_note_outlined,
      'title': 'Create New Course',
      'value': 'Create New Course',
      'route': CreateNewCoursePage,
    },
    {
      'icon': Icons.airplanemode_active,
      'selectedIcon': Icons.airplanemode_active_rounded,
      'title': 'Create Squadrons',
      'value': 'Create Squadrons',
      'route': CreateSquadronsPage,
    },
    {
      'icon': Icons.supervised_user_circle_rounded,
      'selectedIcon': Icons.supervised_user_circle_outlined,
      'title': 'All Users',
      'value': 'All Users',
      'route': GetUsersPage,
    },
    {
      'icon': Icons.school_outlined,
      'selectedIcon': Icons.school,
      'title': 'All Departments',
      'value': 'All Departments',
      'route': DepartmentsScreen,
    },
    {
      'icon': Icons.auto_awesome_motion_rounded,
      'selectedIcon': Icons.auto_awesome_motion_outlined,
      'title': 'All Years',
      'value': 'All Years',
      'route': YearsScreen,
    },
    {
      'icon': Icons.file_open_outlined,
      'selectedIcon': Icons.file_open,
      'title': 'Import users File',
      'value': 'Import users File',
      'route': ImportStudentsScreen,
    },
    {
      'icon': Icons.grade_outlined,
      'selectedIcon': Icons.grade,
      'title': 'Grades overview',
      'value': 'Grades overview',
      'route': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsetsGeometry.directional(
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
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _SidebarMenuItem(
                  icon: item['icon'],
                  selectedIcon: item['selectedIcon'],
                  title: item['title'],
                  value: item['value'],
                  isSelected: selectedMenuItem == item['value'],
                  isHovered: hoveredMenuItem == item['value'],
                  onTap: () {
                    onMenuItemSelected(item['value']);
                    if (item['route'] != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => item['route']()),
                      );
                    }
                  },
                  onHover: (isHovered) {
                    onMenuItemHovered(isHovered ? item['value'] : null);
                  },
                );
              },
            ),
          ),
          _LogoutButton(
            isHovered: isLogoutHovered,
            onHover: onLogoutHovered,
            onExit: onLogoutExited,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final String value;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final Function(bool) onHover;

  const _SidebarMenuItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.value,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
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
                  isSelected ? selectedIcon : icon,
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
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isHovered;
  final VoidCallback onHover;
  final VoidCallback onExit;

  const _LogoutButton({
    required this.isHovered,
    required this.onHover,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(),
      onExit: (_) => onExit(),
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
            color: isHovered
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered
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
}