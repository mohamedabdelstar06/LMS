import 'package:flutter/material.dart';

import 'package:lms/features/screens/Announcement/view.dart';
import 'package:lms/features/screens/admin/admin_profile/view.dart';
import 'package:lms/features/screens/grades_overview/grades_overview_screen.dart';
import 'package:lms/features/screens/admin/courses/Enrollment_course/view.dart';
import 'package:lms/features/screens/admin/courses/create_course/Adding_view.dart';
import 'package:lms/features/screens/admin/courses/home_courses/view.dart';
import 'package:lms/features/screens/admin/dashboard_screen.dart';
import 'package:lms/features/screens/admin/department/create_department/view.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/view.dart';
import 'package:lms/features/screens/admin/squadron/create_squadron/view.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/get_all squadrons/view.dart';
import 'package:lms/features/screens/admin/user_file/import_file/view.dart';
import 'package:lms/features/screens/admin/users/create_user/View.dart';
import 'package:lms/features/screens/admin/users/get_users/view.dart';
import 'package:lms/features/screens/admin/year/create_year/view.dart';
import 'package:lms/features/screens/admin/year/get_year/get_All_years/view.dart';
import 'package:lms/features/screens/instructor/create_course/Adding_view.dart';
import 'package:lms/features/screens/instructor/home_courses/view.dart';
import 'package:lms/features/screens/instructor/teacher_profile/view.dart';

enum ManagementRole { admin, instructor }

class ManagementMenuItem {
  final String id;
  final String label;
  final IconData outlinedIcon;
  final IconData filledIcon;
  final Widget Function() screenBuilder;

  const ManagementMenuItem({
    required this.id,
    required this.label,
    required this.outlinedIcon,
    required this.filledIcon,
    required this.screenBuilder,
  });
}

class ManagementMenuSection {
  final String title;
  final List<ManagementMenuItem> items;

  const ManagementMenuSection({required this.title, required this.items});
}

class ManagementMenuConfig {
  static List<ManagementMenuSection> sectionsFor(ManagementRole role) {
    switch (role) {
      case ManagementRole.admin:
        return _adminSections;
      case ManagementRole.instructor:
        return _instructorSections;
    }
  }

  static const _adminSections = [
    ManagementMenuSection(
      title: 'Management',
      items: [
        ManagementMenuItem(
          id: 'Dashboard',
          label: 'Dashboard',
          outlinedIcon: Icons.space_dashboard_outlined,
          filledIcon: Icons.space_dashboard,
          screenBuilder: AdminDashboardScreen.new,
        ),
      ],
    ),
    ManagementMenuSection(
      title: 'Account',
      items: [
        ManagementMenuItem(
          id: 'Profile',
          label: 'Profile',
          outlinedIcon: Icons.person_outline_rounded,
          filledIcon: Icons.person_rounded,
          screenBuilder: AdminProfileScreen.new,
        ),
      ],
    ),
    ManagementMenuSection(
      title: 'Courses',
      items: [
        ManagementMenuItem(
          id: 'My Courses',
          label: 'My Courses',
          outlinedIcon: Icons.menu_book_outlined,
          filledIcon: Icons.menu_book_rounded,
          screenBuilder: AdminCourseScreen.new,
        ),
        ManagementMenuItem(
          id: 'Create New Course',
          label: 'Create New Course',
          outlinedIcon: Icons.add_circle_outline_rounded,
          filledIcon: Icons.add_circle_rounded,
          screenBuilder: CreateNewCoursePage.new,
        ),
        ManagementMenuItem(
          id: 'Add Enrollment',
          label: 'Add Enrollment',
          outlinedIcon: Icons.how_to_reg_outlined,
          filledIcon: Icons.how_to_reg_rounded,
          screenBuilder: EnrollmentPage.new,
        ),
      ],
    ),
    ManagementMenuSection(
      title: 'Users',
      items: [
        ManagementMenuItem(
          id: 'Create users',
          label: 'Create Users',
          outlinedIcon: Icons.person_add_alt_1_outlined,
          filledIcon: Icons.person_add_alt_1_rounded,
          screenBuilder: CreateUserScreen.new,
        ),
        ManagementMenuItem(
          id: 'All Users',
          label: 'All Users',
          outlinedIcon: Icons.groups_outlined,
          filledIcon: Icons.groups_rounded,
          screenBuilder: GetUserPage.new,
        ),
        ManagementMenuItem(
          id: 'Import users File',
          label: 'Import Users',
          outlinedIcon: Icons.upload_file_outlined,
          filledIcon: Icons.upload_file_rounded,
          screenBuilder: ImportStudentsScreen.new,
        ),
      ],
    ),
    ManagementMenuSection(
      title: 'Organization',
      items: [
        ManagementMenuItem(
          id: 'Create Departments',
          label: 'Create Departments',
          outlinedIcon: Icons.domain_add_outlined,
          filledIcon: Icons.domain_add_rounded,
          screenBuilder: CreateDepartmentPage.new,
        ),
        ManagementMenuItem(
          id: 'All Departments',
          label: 'All Departments',
          outlinedIcon: Icons.apartment_outlined,
          filledIcon: Icons.apartment_rounded,
          screenBuilder: DepartmentsScreen.new,
        ),
        ManagementMenuItem(
          id: 'Create Years',
          label: 'Create Years',
          outlinedIcon: Icons.calendar_month_outlined,
          filledIcon: Icons.calendar_month_rounded,
          screenBuilder: CreateYearPage.new,
        ),
        ManagementMenuItem(
          id: 'All Years',
          label: 'All Years',
          outlinedIcon: Icons.date_range_outlined,
          filledIcon: Icons.date_range_rounded,
          screenBuilder: YearsScreen.new,
        ),
        ManagementMenuItem(
          id: 'Create Squadrons',
          label: 'Create Squadrons',
          outlinedIcon: Icons.flight_takeoff_outlined,
          filledIcon: Icons.flight_rounded,
          screenBuilder: CreateSquadronsPage.new,
        ),
        ManagementMenuItem(
          id: 'All Squadrons',
          label: 'All Squadrons',
          outlinedIcon: Icons.airplanemode_active_outlined,
          filledIcon: Icons.airplanemode_active_rounded,
          screenBuilder: GetSquadronPage.new,
        ),
      ],
    ),
    ManagementMenuSection(
      title: 'Communication',
      items: [
        ManagementMenuItem(
          id: 'Add Announcement',
          label: 'Add Announcement',
          outlinedIcon: Icons.add_alert_outlined,
          filledIcon: Icons.add_alert_rounded,
          screenBuilder: AddAnnouncementScreen.new,
        ),
        ManagementMenuItem(
          id: 'All Announcements',
          label: 'All Announcements',
          outlinedIcon: Icons.campaign_outlined,
          filledIcon: Icons.campaign_rounded,
          screenBuilder: AllAnnouncementScreen.new,
        ),
        
      ],
    ),
    ManagementMenuSection(
      title: 'Analytics',
      items: [
        ManagementMenuItem(
          id: 'Grades overview',
          label: 'Grades Overview',
          outlinedIcon: Icons.assessment_outlined,
          filledIcon: Icons.assessment_rounded,
          screenBuilder: AdminGradesOverviewScreen.new,
        ),
      ],
    ),
  ];

  static const _instructorSections = [
    ManagementMenuSection(
      title: 'Management',
      items: [
        ManagementMenuItem(
          id: 'Dashboard',
          label: 'Dashboard',
          outlinedIcon: Icons.space_dashboard_outlined,
          filledIcon: Icons.space_dashboard,
          screenBuilder: TeacherCourseScreen.new,
        ),
      ],
    ),
    ManagementMenuSection(
      title: 'Account',
      items: [
        ManagementMenuItem(
          id: 'Profile',
          label: 'Profile',
          outlinedIcon: Icons.person_outline_rounded,
          filledIcon: Icons.person_rounded,
          screenBuilder: TeacherProfileScreen.new,
        ),
      ],
    ),
    ManagementMenuSection(
      title: 'Courses',
      items: [
        ManagementMenuItem(
          id: 'My Courses',
          label: 'My Courses',
          outlinedIcon: Icons.menu_book_outlined,
          filledIcon: Icons.menu_book_rounded,
          screenBuilder: TeacherCourseScreen.new,
        ),
        ManagementMenuItem(
          id: 'Create New Course',
          label: 'Create New Course',
          outlinedIcon: Icons.add_circle_outline_rounded,
          filledIcon: Icons.add_circle_rounded,
          screenBuilder: TeacherCreateNewCoursePage.new,
        ),
      ],
    ),
    /// TODO: Add Announcements section for instructors if needed
    ManagementMenuSection(
      title: 'Communication',
      items: [
        ManagementMenuItem(
          id: 'Announcements',
          label: 'Announcements',
          outlinedIcon: Icons.campaign_outlined,
          filledIcon: Icons.campaign_rounded,
          screenBuilder: AllAnnouncementScreen.new,
        ),
      ],
    ),
    ManagementMenuSection(
      title: 'Analytics',
      items: [
        ManagementMenuItem(
          id: 'Grades overview',
          label: 'Grades Overview',
          outlinedIcon: Icons.assessment_outlined,
          filledIcon: Icons.assessment_rounded,
          screenBuilder: InstructorGradesOverviewScreen.new,
        ),
      ],
    ),
  ];
}
