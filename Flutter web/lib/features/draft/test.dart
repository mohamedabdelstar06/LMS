// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../course_details_cubit.dart';
// import '../course_details_state.dart';
// import 'content_tap_bar.dart';
// import 'content_tap_view.dart';
// import 'course_appbar.dart';
// import 'course_meta_row.dart';
// import 'expandable_discription.dart';
// import 'instructor_card.dart';
// import 'package:lms/features/screens/admin/courses/course_details/courseDetailsState_managment/functions/progress.dart';
// import 'package:lms/features/screens/admin/courses/course_details/courseDetailsState_managment/functions/section_label.dart';
// import 'package:lms/features/screens/admin/courses/course_details/courseDetailsState_managment/functions/state_row.dart';
//
// class LoadedScreen extends StatelessWidget {
//   const LoadedScreen({super.key, required this.state});
//   final CourseDetailsLoaded state;
//
//   @override
//   Widget build(BuildContext context) {
//     final course = state.course;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isWide = screenWidth > 900;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           CourseHeroAppBar(course: course),
//
//           SliverToBoxAdapter(
//             child: isWide
//                 ? _WideLayout(state: state)
//                 : _NarrowLayout(state: state),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _WideLayout extends StatelessWidget {
//   const _WideLayout({required this.state});
//   final CourseDetailsLoaded state;
//
//   @override
//   Widget build(BuildContext context) {
//     final course = state.course;
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 6,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CourseMetaRow(course: course),
//                 const SizedBox(height: 20),
//                 if (course.progressPercentage != null) ...[
//                   ProgressCard(progress: course.progressPercentage!),
//                   const SizedBox(height: 20),
//                 ],
//                 _SectionHeader(label: 'About this course', icon: Icons.info_outline_rounded),
//                 const SizedBox(height: 12),
//                 ExpandableDescription(text: course.description),
//                 const SizedBox(height: 28),
//                 _SectionHeader(label: 'Course Content', icon: Icons.library_books_outlined),
//                 const SizedBox(height: 14),
//                 ContentTabBar(
//                   activeIndex: state.activeTab,
//                   onTap: (i) => context.read<CourseDetailsCubit>().setTab(i),
//                 ),
//                 const SizedBox(height: 16),
//                 ContentTabView(course: course, activeIndex: state.activeTab),
//               ],
//             ),
//           ),
//
//           const SizedBox(width: 24),
//
//           SizedBox(
//             width: 300,
//             child: _Stickysidebar(state: state),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _NarrowLayout extends StatelessWidget {
//   const _NarrowLayout({required this.state});
//   final CourseDetailsLoaded state;
//
//   @override
//   Widget build(BuildContext context) {
//     final course = state.course;
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(18, 22, 18, 40),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CourseMetaRow(course: course),
//           const SizedBox(height: 18),
//           if (course.progressPercentage != null) ...[
//             ProgressCard(progress: course.progressPercentage!),
//             const SizedBox(height: 18),
//           ],
//           StatsRow(course: course),
//           const SizedBox(height: 24),
//           _SectionHeader(label: 'About this course', icon: Icons.info_outline_rounded),
//           const SizedBox(height: 10),
//           ExpandableDescription(text: course.description),
//           const SizedBox(height: 24),
//           _SectionHeader(label: 'Course Content', icon: Icons.library_books_outlined),
//           const SizedBox(height: 12),
//           ContentTabBar(
//             activeIndex: state.activeTab,
//             onTap: (i) => context.read<CourseDetailsCubit>().setTab(i),
//           ),
//           const SizedBox(height: 14),
//           ContentTabView(course: course, activeIndex: state.activeTab),
//           const SizedBox(height: 24),
//           _SectionHeader(label: 'Instructor', icon: Icons.person_outline_rounded),
//           const SizedBox(height: 12),
//           InstructorCard(course: course),
//         ],
//       ),
//     );
//   }
// }
//
// class _Stickysidebar extends StatelessWidget {
//   const _Stickysidebar({required this.state});
//   final CourseDetailsLoaded state;
//
//   @override
//   Widget build(BuildContext context) {
//     final course = state.course;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _CourseQuickCard(course: course),
//         const SizedBox(height: 20),
//         StatsRow(course: course),
//         const SizedBox(height: 20),
//         _SectionHeader(label: 'Instructor', icon: Icons.person_outline_rounded),
//         const SizedBox(height: 12),
//         InstructorCard(course: course),
//       ],
//     );
//   }
// }
//
// class _CourseQuickCard extends StatelessWidget {
//   const _CourseQuickCard({required this.course});
//   final course;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFE2EAF4)),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF4361EE).withOpacity(0.07),
//             blurRadius: 20,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(18),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF0C4A6E), Color(0xFF0369A1)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     course.departmentName ?? '',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   course.title ?? '',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     height: 1.3,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _QuickRow(Icons.calendar_today_outlined, course.yearName ?? '', const Color(0xFF0369A1)),
//                 const SizedBox(height: 10),
//                 _QuickRow(Icons.timer_outlined, '${course.creditHours} Credit Hours', const Color(0xFF7C3AED)),
//                 const SizedBox(height: 10),
//                 _QuickRow(Icons.people_outline, '${course.enrolledStudentsCount} Students', const Color(0xFF059669)),
//                 const SizedBox(height: 10),
//                 _QuickRow(Icons.person_outline, course.instructorName ?? '', const Color(0xFFF97316)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _QuickRow extends StatelessWidget {
//   const _QuickRow(this.icon, this.label, this.color);
//   final IconData icon;
//   final String label;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(7),
//           ),
//           child: Icon(icon, size: 13, color: color),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF334155),
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _SectionHeader extends StatelessWidget {
//   const _SectionHeader({required this.label, required this.icon});
//   final String label;
//   final IconData icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(7),
//           decoration: BoxDecoration(
//             color: const Color(0xFF0369A1).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, size: 15, color: const Color(0xFF0369A1)),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Color(0xFF0F172A),
//             fontSize: 17,
//             fontWeight: FontWeight.w800,
//             letterSpacing: -0.3,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Container(
//             height: 1,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF0369A1).withOpacity(0.2),
//                   Colors.transparent,
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }