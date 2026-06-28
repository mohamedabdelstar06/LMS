import 'package:lms/features/screens/Announcement/model.dart';
import 'package:lms/features/screens/admin/courses/get_all_courses/model/model.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/all_model/model.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/model/view.dart';
import 'package:lms/features/screens/admin/year/get_year/get_All_years/all_model/model.dart';        // GetAllYearModel

abstract class AnnouncementState {}

// ── Add Announcement ──────────────────────────────────────────────────────────
class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementSuccess extends AnnouncementState {
  AnnouncementSuccess({this.message = 'Announcement created successfully!'});
  final String message;
}

class AnnouncementError extends AnnouncementState {
  AnnouncementError(this.message);
  final String message;
}

// ── Get All Announcements ─────────────────────────────────────────────────────
class GetAllAnnouncementsLoading extends AnnouncementState {}

class GetAllAnnouncementsSuccess extends AnnouncementState {
  GetAllAnnouncementsSuccess({
    required this.announcements,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
  });
  final List<AnnouncementModel> announcements;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final int totalCount;
  final int totalPages;
  final int currentPage;
}

class GetAllAnnouncementsError extends AnnouncementState {
  GetAllAnnouncementsError(this.message);
  final String message;
}

// ── Delete Announcement ───────────────────────────────────────────────────────
class DeleteAnnouncementLoading extends AnnouncementState {}

class DeleteAnnouncementSuccess extends AnnouncementState {}

class DeleteAnnouncementError extends AnnouncementState {
  DeleteAnnouncementError(this.message);
  final String message;
}

// ── Dropdown Data — Departments ───────────────────────────────────────────────
class DepartmentsLoading extends AnnouncementState {}

class DepartmentsLoaded extends AnnouncementState {
  DepartmentsLoaded(this.departments);
  final List<GetAllDepartmentModel> departments;
}

class DepartmentsError extends AnnouncementState {
  DepartmentsError(this.message);
  final String message;
}

// ── Dropdown Data — Years ─────────────────────────────────────────────────────
class YearsLoading extends AnnouncementState {}

class YearsLoaded extends AnnouncementState {
  YearsLoaded(this.years);
  final List<GetAllYearModel> years;
}

class YearsError extends AnnouncementState {
  YearsError(this.message);
  final String message;
}

// ── Dropdown Data — Squadrons ─────────────────────────────────────────────────
class SquadronsLoading extends AnnouncementState {}

class SquadronsLoaded extends AnnouncementState {
  SquadronsLoaded(this.squadrons);
  final List<SquadronModel> squadrons;
}

class SquadronsError extends AnnouncementState {
  SquadronsError(this.message);
  final String message;
}

// ── Dropdown Data — Courses ───────────────────────────────────────────────────
class CoursesLoading extends AnnouncementState {}

class CoursesLoaded extends AnnouncementState {
  CoursesLoaded(this.courses);
  final List<GetCourseModel> courses;
}

class CoursesError extends AnnouncementState {
  CoursesError(this.message);
  final String message;
}

// ── All dropdown data loaded together (used in AddAnnouncementScreen init) ────
class DropdownDataLoaded extends AnnouncementState {
  DropdownDataLoaded({
    required this.departments,
    required this.years,
    required this.squadrons,
    required this.courses,
  });
  final List<GetAllDepartmentModel> departments;
  final List<GetAllYearModel> years;
  final List<SquadronModel> squadrons;
  final List<GetCourseModel> courses;
}

class DropdownDataLoading extends AnnouncementState {}

class DropdownDataError extends AnnouncementState {
  DropdownDataError(this.message);
  final String message;
}