// import 'dart:ui_web' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'dart:html' as html;
// import 'package:flutter/widgets.dart';
//
// import 'package:lms/features/screens/get_years/get_All_years/state_mangement/cubit.dart';
// import 'package:lms/features/screens/get_years/get_All_years/state_mangement/states.dart';
//
// import '../../../../core/cons/Colors/app_colors.dart';
// import '../../../../core/helpers/logout_server/logout.dart';
// import '../../Announcement/view.dart';
// import '../../Create_department/view.dart';
// import '../../Create_user/View.dart';
// import '../../add_course/Adding_view.dart';
// import '../../admin/admin_profile/view.dart';
// import '../../admin/create_years/view.dart';
// import '../../courses/admin/view.dart';
// import '../../create_squadron/view.dart';
// import '../../get_department/get_All_departments/view.dart';
// import '../../get_users/view.dart';
// import 'all_model/model.dart';
//
// String selectedMenuItem = 'All Years';
// String? hoveredMenuItem;
// bool isLogoutHovered = false;
//
// class YearsScreen extends StatefulWidget {
//   const YearsScreen({super.key});
//
//   @override
//   State<YearsScreen> createState() => _DepartmentsScreenState();
// }
//
// class _DepartmentsScreenState extends State<YearsScreen> {
//   int? hoveredRowIndex;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => AllYearsCubit()..fetchYearss(),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               MYColors.gradientColor_3,
//               MYColors.gradientColor_2.withValues(alpha: 0.25),
//               MYColors.gradientColor_3,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           body: BlocBuilder<AllYearsCubit, AllYearsState>(
//             builder: (context, state) {
//               if (state is YearsLoading) {
//                 return const Center(
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF2563EB),
//                   ),
//                 );
//               }
//
//               if (state is YearsError) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 64,
//                         color: Colors.red.shade400,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         state.message,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               if (state is YearsLoaded) {
//                 return Row(
//                   children: [
//                     _buildSidebar(),
//                     Expanded(
//                       child: Column(
//                         children: [
//                           // ✅ عداد السنين
//                           _buildStatsHeader(state.years.length),
//
//                           // ✅ الجدول
//                           Expanded(
//                             child: Container(
//                               margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.08),
//                                     blurRadius: 20,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 children: [
//                                   // Header
//                                   Container(
//                                     padding: const EdgeInsets.all(24),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFFF8FAFC),
//                                       borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(16),
//                                         topRight: Radius.circular(16),
//                                       ),
//                                       border: Border(
//                                         bottom: BorderSide(
//                                           color: const Color(0xFFE2E8F0),
//                                           width: 1,
//                                         ),
//                                       ),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.all(12),
//                                           decoration: BoxDecoration(
//                                             color: const Color(0xFF2563EB)
//                                                 .withOpacity(0.1),
//                                             borderRadius:
//                                             BorderRadius.circular(12),
//                                           ),
//                                           child: const Icon(
//                                             Icons.calendar_today,
//                                             color: Color(0xFF2563EB),
//                                             size: 24,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         const Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Academic Years',
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Color(0xFF1E293B),
//                                               ),
//                                             ),
//                                             SizedBox(height: 4),
//                                             Text(
//                                               'Manage all academic years',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Color(0xFF64748B),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//
//                                   // الجدول
//                                   Expanded(
//                                     child: SingleChildScrollView(
//                                       padding: const EdgeInsets.all(24),
//                                       child: _buildModernTable(
//                                           context, state.years),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }
//
//               return const SizedBox.shrink();
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatsHeader(int totalYears) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF2563EB).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.auto_awesome_motion_rounded,
//               color: Colors.white,
//               size: 32,
//             ),
//           ),
//           const SizedBox(width: 20),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Total Academic Years',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '$totalYears Years',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.trending_up,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Active',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildModernTable(BuildContext context, List<GetAllYearModel> years) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           minWidth: MediaQuery.of(context).size.width - 340,
//         ),
//         child: Table(
//           columnWidths: const {
//             0: FixedColumnWidth(180),
//             1: FixedColumnWidth(300),
//             2: FixedColumnWidth(140),
//             3: FixedColumnWidth(140),
//             4: FixedColumnWidth(100),
//             5: FixedColumnWidth(100),
//             6: FixedColumnWidth(180),
//             7: FixedColumnWidth(120),
//           },
//           children: [
//             TableRow(
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8FAFC),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               children: [
//                 _buildTableHeader('Name', Icons.badge),
//                 _buildTableHeader('Department', Icons.school),
//                 _buildTableHeader('Courses', Icons.book),
//                 _buildTableHeader('Hours', Icons.access_time),
//                 _buildTableHeader('Start Date', Icons.calendar_today),
//                 _buildTableHeader('End Date', Icons.event),
//                 _buildTableHeader('Description', Icons.description),
//                 _buildTableHeader('Actions', Icons.settings),
//               ],
//             ),
//
//             ...years.asMap().entries.map((entry) {
//               final index = entry.key;
//               final year = entry.value;
//               return _buildModernTableRow(context, year, index);
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTableHeader(String title, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 18,
//             color: const Color(0xFF64748B),
//           ),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF475569),
//                 letterSpacing: 0.5,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   TableRow _buildModernTableRow(
//       BuildContext context, GetAllYearModel year, int index) {
//     final isHovered = hoveredRowIndex == index;
//
//     return TableRow(
//       decoration: BoxDecoration(
//         color: isHovered
//             ? const Color(0xFF2563EB).withOpacity(0.05)
//             : index.isEven
//             ? Colors.white
//             : const Color(0xFFF8FAFC),
//         border: Border(
//           bottom: BorderSide(
//             color: const Color(0xFFE2E8F0),
//             width: 1,
//           ),
//         ),
//       ),
//       children: [
//         _buildTableCell(
//           MouseRegion(
//             onEnter: (_) => setState(() => hoveredRowIndex = index),
//             onExit: (_) => setState(() => hoveredRowIndex = null),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF2563EB).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.calendar_month,
//                       size: 16,
//                       color: Color(0xFF2563EB),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Flexible(
//                     child: Text(
//                       year.name,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1E293B),
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         _buildTableCell(
//           MouseRegion(
//             onEnter: (_) => setState(() => hoveredRowIndex = index),
//             onExit: (_) => setState(() => hoveredRowIndex = null),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.school,
//                     size: 16,
//                     color: Color(0xFF64748B),
//                   ),
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: Text(
//                       year.departmentName,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF475569),
//                         fontWeight: FontWeight.w500,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         _buildTableCell(
//           MouseRegion(
//             onEnter: (_) => setState(() => hoveredRowIndex = index),
//             onExit: (_) => setState(() => hoveredRowIndex = null),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF8B5CF6).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Center(
//                   child: Text(
//                     year.totalCourses.toString(),
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF8B5CF6),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         _buildTableCell(
//           MouseRegion(
//             onEnter: (_) => setState(() => hoveredRowIndex = index),
//             onExit: (_) => setState(() => hoveredRowIndex = null),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF59E0B).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Center(
//                   child: Text(
//                     year.totalHours.toString(),
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFFF59E0B),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         _buildTableCell(
//           MouseRegion(
//             onEnter: (_) => setState(() => hoveredRowIndex = index),
//             onExit: (_) => setState(() => hoveredRowIndex = null),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF10B981).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   formatDate(year.startDate),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF10B981),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         _buildTableCell(
//           MouseRegion(
//             onEnter: (_) => setState(() => hoveredRowIndex = index),
//             onExit: (_) => setState(() => hoveredRowIndex = null),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEF4444).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   formatDate(year.endDate),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFFEF4444),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//
//
//         _buildTableCell(
//           MouseRegion(
//             onEnter: (_) => setState(() => hoveredRowIndex = index),
//             onExit: (_) => setState(() => hoveredRowIndex = null),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Text(
//                 year.description,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Color(0xFF64748B),
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//         ),
//         _buildTableCell(
//           MouseRegion(
//             onEnter: (_) => setState(() => hoveredRowIndex = index),
//             onExit: (_) => setState(() => hoveredRowIndex = null),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildActionButton(
//                     icon: Icons.edit,
//                     color: const Color(0xFF2563EB),
//                     tooltip: 'Edit',
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => BlocProvider.value(
//                             value: context.read<AllYearsCubit>(),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(width: 4),
//                   _buildActionButton(
//                     icon: Icons.delete,
//                     color: const Color(0xFFEF4444),
//                     tooltip: 'Delete',
//                     onPressed: () {
//                       _showDeleteDialog(context, year.id);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTableCell(Widget child) {
//     return child;
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required String tooltip,
//     required VoidCallback onPressed,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: GestureDetector(
//           onTap: onPressed,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(
//                 color: color.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Icon(
//               icon,
//               size: 16,
//               color: color,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//   }
//
//   void _showDeleteDialog(BuildContext context, int id) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (dialogContext) => BlocConsumer<AllYearsCubit, AllYearsState>(
//         listener: (context, state) {
//           if (state is YearsLoaded) {
//             Navigator.of(dialogContext).pop();
//
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Row(
//                   children: [
//                     const Icon(Icons.check_circle, color: Colors.white),
//                     const SizedBox(width: 12),
//                     const Text('Year deleted successfully!'),
//                   ],
//                 ),
//                 backgroundColor: const Color(0xFF10B981),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//           } else if (state is YearsError) {
//             Navigator.of(dialogContext).pop();
//
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Row(
//                   children: [
//                     const Icon(Icons.error_outline, color: Colors.white),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         state.message,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 backgroundColor: const Color(0xFFEF4444),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           final isDeleting = state is YearsLoading;
//
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFEF4444).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.warning_amber_rounded,
//                     color: Color(0xFFEF4444),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text("Delete Year"),
//               ],
//             ),
//             content: const Text(
//               "Are you sure you want to delete this year? This action cannot be undone.",
//             ),
//             actions: [
//               TextButton(
//                 onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFEF4444),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: isDeleting
//                     ? null
//                     : () {
//                   context.read<AllYearsCubit>().deleteYear(id);
//                 },
//                 child: isDeleting
//                     ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//                     : const Text("Delete"),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSidebar() {
//     return Container(
//       width: 250,
//       margin: const EdgeInsetsGeometry.directional(
//         start: 40,
//         end: 0,
//         top: 50,
//         bottom: 50,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 40),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _buildMenuItem(
//                     Icons.person_outline,
//                     Icons.person,
//                     'Profile',
//                     'Profile',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const AdminProfileScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.book_outlined,
//                     Icons.book,
//                     'My Courses',
//                     'My Courses',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const AdminCourseScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.notifications_active_outlined,
//                     Icons.notifications_active_rounded,
//                     'Announcements',
//                     'Announcements',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const AnnouncementScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.person_add_alt_1_outlined,
//                     Icons.person_add_alt_1,
//                     'Create Users',
//                     'Create users',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const CreateUserScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.folder_copy_outlined,
//                     Icons.folder_copy_rounded,
//                     'Create Departments',
//                     'Create Departments',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => CreateDepartmentPage(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.calendar_month,
//                     Icons.calendar_month_outlined,
//                     'Create Years',
//                     'Create Years',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => CreateYearPage(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.event_available,
//                     Icons.event_note_outlined,
//                     'Create New Course',
//                     'Create New Course',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => CreateNewCoursePage(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.airplanemode_active,
//                     Icons.airplanemode_active_rounded,
//                     'Create Squadrons',
//                     'Create Squadrons',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => CreateSquadronsPage(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.supervised_user_circle_rounded,
//                     Icons.supervised_user_circle_outlined,
//                     'All Users',
//                     'All Users',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => GetUsersPage(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.school_outlined,
//                     Icons.school,
//                     'All Departments',
//                     'All Departments',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DepartmentsScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.auto_awesome_motion_rounded,
//                     Icons.auto_awesome_motion_outlined,
//                     'All Years',
//                     'All Years',
//                         () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => YearsScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildMenuItem(
//                     Icons.grade_outlined,
//                     Icons.grade,
//                     'Grades overview',
//                     'Grades overview',
//                         () {},
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           _buildLogoutButton(),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMenuItem(
//       IconData outlinedIcon,
//       IconData filledIcon,
//       String title,
//       String value,
//       onTap,
//       ) {
//     final isSelected = selectedMenuItem == value;
//     final isHovered = hoveredMenuItem == value;
//
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => hoveredMenuItem = value),
//       onExit: (_) => setState(() => hoveredMenuItem = null),
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedMenuItem = value;
//           });
//         },
//         child: GestureDetector(
//           onTap: onTap,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? const Color(0xFF2563EB)
//                   : isHovered
//                   ? const Color(0xFF2563EB).withOpacity(0.1)
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: isHovered && !isSelected
//                     ? const Color(0xFF2563EB).withOpacity(0.3)
//                     : Colors.transparent,
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: Icon(
//                     isSelected ? filledIcon : outlinedIcon,
//                     key: ValueKey(isSelected),
//                     color: isSelected
//                         ? Colors.white
//                         : isHovered
//                         ? const Color(0xFF2563EB)
//                         : const Color(0xFF64748B),
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: isSelected
//                         ? Colors.white
//                         : isHovered
//                         ? const Color(0xFF2563EB)
//                         : Colors.black87,
//                     fontSize: 14,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogoutButton() {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => isLogoutHovered = true),
//       onExit: (_) => setState(() => isLogoutHovered = false),
//       child: GestureDetector(
//         onTap: () {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Logout'),
//               content: const Text('Are you sure you want to logout?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     await LogoutServer.logout();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFEF4444),
//                   ),
//                   child: const Text('Logout'),
//                 ),
//               ],
//             ),
//           );
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           margin: const EdgeInsets.symmetric(horizontal: 12),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: isLogoutHovered
//                 ? const Color(0xFFEF4444).withOpacity(0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: isLogoutHovered
//                   ? const Color(0xFFEF4444).withOpacity(0.3)
//                   : Colors.transparent,
//               width: 1,
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.logout, color: const Color(0xFFEF4444), size: 20),
//               const SizedBox(width: 12),
//               const Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: Color(0xFFEF4444),
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }