// import 'dart:ui_web' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'dart:html' as html;
// import 'package:flutter/widgets.dart';
// import 'package:lms/features/screens/admin/get_years/get_All_years/state_mangement/cubit.dart';
// import 'package:lms/features/screens/admin/get_years/get_All_years/state_mangement/states.dart';
//
//
// import '../../../../../core/cons/Colors/app_colors.dart';
// import '../../../../../core/helpers/logout_server/logout.dart';
// import '../../../Announcement/view.dart';
// import '../../../Create_department/view.dart';
// import '../../../Create_user/View.dart';
// import '../../../add_course/Adding_view.dart';
// import '../../../courses/admin/view.dart';
// import '../../../create_squadron/view.dart';
// import '../../../get_department/get_All_courses/view.dart';
// import '../../../get_users/view.dart';
// import '../../create_years/view.dart';
// import 'all_model/model.dart';
//
//
// String selectedMenuItem = 'All Years';
// String? hoveredMenuItem;
// bool isLogoutHovered = false;
//
//
// class YearsScreen extends StatefulWidget {
//   const YearsScreen({super.key});
//
//   @override
//   State<YearsScreen> createState() => _DepartmentsScreenState();
// }
//
//
// class _DepartmentsScreenState extends State<YearsScreen> {
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
//           appBar: AppBar(title: const Text("Years")),
//           body: BlocBuilder<AllYearsCubit, AllYearsState>(
//             builder: (context, state) {
//               if (state is YearsLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state is YearsError) {
//                 return Center(child: Text(state.message));
//               }
//
//               if (state is YearsLoaded) {
//                 return  Row(
//                   children: [
//                     _buildSidebar(),
//
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.vertical,
//
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//
//                             child: DataTable(
//                               columnSpacing: 20,
//                               columns: const [
//                                 DataColumn(label: Text("Name")),
//                                 DataColumn(label: Text("Description")),
//                                 DataColumn(label: Text("Start Date")),
//                                 DataColumn(label: Text("End Date")),
//                                 DataColumn(label: Text("Total Courses")),
//                                 DataColumn(label: Text("Total Years")),
//                                 DataColumn(label: Text("ID")),
//                                 DataColumn(label: Text("Dep Name")),
//                                 DataColumn(label: Text("Actions")),
//                               ],
//                               rows: state.years
//                                   .map((year) => _buildRow(context, year))
//                                   .toList(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//
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
//   DataRow _buildRow(BuildContext context, GetAllYearModel year) {
//     return DataRow(
//       cells: [
//         DataCell(Text(year.name)),
//         DataCell(
//           SizedBox(
//             width: 200,
//             child: Text(
//               year.description,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//
//
//         DataCell(Text(formatDate(year.startDate))),
//         DataCell(Text(formatDate(year.endDate))),
//         DataCell(Text(year.totalCourses.toString())),
//         DataCell(Text(year.totalHours.toString())),
//         DataCell(Text(year.id.toString())),
//         DataCell(Text(year.departmentName)),
//
//
//         DataCell(
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.edit, color: Colors.blue),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => BlocProvider.value(
//                         value: context.read<AllYearsCubit>(),
//                         // child: UpdateDepartmentScreen(department: dep),
//                       ),
//                     ),
//                   );                },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.delete, color: Colors.red),
//                 onPressed: () {
//                   _showDeleteDialog(context, year.id);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//   String formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//   }
//
//
//
//   void _showDeleteDialog(BuildContext context, int id) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete Year"),
//         content: const Text("Are you sure you want to delete this year?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               context.read<AllYearsCubit>().deleteYear(id);
//               Navigator.pop(context);
//             },
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//
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
//       child: ListView(
//         children: [
//           const SizedBox(height: 40),
//           _buildMenuItem(
//             Icons.person_outline,
//             Icons.person,
//             'Profile',
//             'Profile',
//                 () {},
//           ),
//           _buildMenuItem(
//             Icons.book_outlined,
//             Icons.book,
//             'My Courses',
//             'My Courses',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AdminCourseScreen(),
//                 ),
//               );
//             },
//           ),
//           _buildMenuItem(
//             Icons.notifications_active_outlined,
//             Icons.notifications_active_rounded,
//             'Announcements',
//             'Announcements',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AnnouncementScreen(),
//                 ),
//               );
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.person_add_alt_1_outlined,
//             Icons.person_add_alt_1,
//             'Create Users',
//             'Create users',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const CreateUserScreen(),
//                 ),
//               );
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.folder_copy_outlined,
//             Icons.folder_copy_rounded,
//             'Create Departments',
//             'Create Departments',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>  CreateDepartmentPage(),
//                 ),
//               );
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.calendar_month,
//             Icons.calendar_month_outlined,
//             'Create Years',
//             'Create Years',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>  CreateYearPage(),
//                 ),
//               );
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.event_available,
//             Icons.event_note_outlined,
//             'Create New Course',
//             'Create New Course',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>  CreateNewCoursePage(),
//                 ),
//               );
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.airplanemode_active,
//             Icons.airplanemode_active_rounded,
//             'Create Squadrons',
//             'Create Squadrons',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>  CreateSquadronsPage(),
//                 ),
//               );
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.supervised_user_circle_rounded,
//             Icons.supervised_user_circle_outlined,
//             'All Users',
//             'All Users',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>  GetUsersPage(),
//                 ),
//               );
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.school_outlined,
//             Icons.school,
//             'All Departments',
//             'All Departments',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>  DepartmentsScreen(),
//                 ),
//               );
//
//             },
//           ),
//           _buildMenuItem(
//             Icons.auto_awesome_motion_rounded,
//             Icons.auto_awesome_motion_outlined,
//             'All Years',
//             'All Years',
//                 () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>  YearsScreen(),
//                 ),
//               );
//
//             },
//           ),
//
//           _buildMenuItem(
//             Icons.grade_outlined,
//             Icons.grade,
//             'Grades overview',
//             'Grades overview',
//                 () {},
//           ),
//           const Spacer(),
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lms/features/screens/admin/get_years/get_All_years/state_mangement/cubit.dart';
import 'package:lms/features/screens/admin/get_years/get_All_years/state_mangement/states.dart';

import '../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../core/helpers/logout_server/logout.dart';
import '../../../../../core/widgets/profile_view.dart';
import '../../../Announcement/view.dart';
import '../../../Create_department/view.dart';
import '../../../Create_user/View.dart';
import '../../../add_course/Adding_view.dart';
import '../../../courses/admin/view.dart';
import '../../../create_squadron/view.dart';
import '../../../get_users/view.dart';
import '../../admin_profile/view.dart';
import '../../create_years/view.dart';
import '../../edit_year/view.dart';
import '../../get_department/get_All_departments/view.dart';
import 'all_model/model.dart';

String selectedMenuItem = 'All Years';
String? hoveredMenuItem;
bool isLogoutHovered = false;

class YearsScreen extends StatefulWidget {
  const YearsScreen({super.key});

  @override
  State<YearsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<YearsScreen> {
  int? hoveredRowIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AllYearsCubit()..fetchYearss(),
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
          body: BlocConsumer<AllYearsCubit, AllYearsState>(
            listener: (context, state) {
              if (state is DeleteYearSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is DeleteYearError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is UpdateYearSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is UpdateYearError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },

            builder: (BuildContext context, AllYearsState state) {
              if (state is YearsLoading ||
                  state is DeleteYearLoading ||
                  state is UpdateYearLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                );
              }

              if (state is YearsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is YearsLoaded) {
                return Row(
                  children: [
                    _buildSidebar(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.school,
                                        color: Color(0xFF2563EB),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'All Years',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Manage all academic years',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    _buildStatsHeader(state.years.length),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  child: SingleChildScrollView(
                                    child: _buildModernTable(
                                        context, state.years),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();

            },
          ),
        ),
      ),
    );
  }


  Widget _buildModernTable(BuildContext context, List<GetAllYearModel> years) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 340,
        ),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(180),
            1: FixedColumnWidth(280),
            2: FixedColumnWidth(140),
            3: FixedColumnWidth(140),
            4: FixedColumnWidth(150),
            5: FixedColumnWidth(150),
            6: FixedColumnWidth(300),
            7: FixedColumnWidth(120),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              children: [
                _buildTableHeader('Name', Icons.badge),
                _buildTableHeader('Department', Icons.school),
                _buildTableHeader('Courses', Icons.book),
                _buildTableHeader('Hours', Icons.access_time),
                _buildTableHeader('Start Date', Icons.calendar_today),
                _buildTableHeader('End Date', Icons.event),
                _buildTableHeader('Description', Icons.description),
                _buildTableHeader('Actions', Icons.settings),
              ],
            ),

            ...years.asMap().entries.map((entry) {
              final index = entry.key;
              final year = entry.value;
              return _buildModernTableRow(context, year, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color:  Colors.blue),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2563EB),
            const Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Years',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildModernTableRow(
    BuildContext context,
    GetAllYearModel year,
    int index,
  ) {
    final isHovered = hoveredRowIndex == index;

    return TableRow(
      decoration: BoxDecoration(
        color: isHovered
            ? const Color(0xFF2563EB).withOpacity(0.05)
            : index.isEven
            ? Colors.white
            : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      children: [
        _buildTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      year.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.school, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      year.departmentName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    year.totalCourses.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    year.totalHours.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        _buildTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formatDate(year.startDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formatDate(year.endDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
          ),
        ),

        _buildTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                year.description,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        _buildTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.edit,
                    color: const Color(0xFF2563EB),
                    tooltip: 'Edit',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AllYearsCubit>(),
                            child: EditYearScreen(year: year),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _buildActionButton(
                    icon: Icons.delete,
                    color: const Color(0xFFEF4444),
                    tooltip: 'Delete',
                    onPressed: () {
                      if (year.totalCourses > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You cannot delete a year that has courses'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      _showDeleteDialog(context, year.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(Widget child) {
    return child;
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Year"),
        content: const Text("Are you sure you want to delete this year?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AllYearsCubit>().deleteYear(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.person_outline,
                    Icons.person,
                    'Profile',
                    'Profile',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.book_outlined,
                    Icons.book,
                    'My Courses',
                    'My Courses',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminCourseScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.notifications_active_outlined,
                    Icons.notifications_active_rounded,
                    'Announcements',
                    'Announcements',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnnouncementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.person_add_alt_1_outlined,
                    Icons.person_add_alt_1,
                    'Create Users',
                    'Create users',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateUserScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.folder_copy_outlined,
                    Icons.folder_copy_rounded,
                    'Create Departments',
                    'Create Departments',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateDepartmentPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.calendar_month,
                    Icons.calendar_month_outlined,
                    'Create Years',
                    'Create Years',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateYearPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.event_available,
                    Icons.event_note_outlined,
                    'Create New Course',
                    'Create New Course',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateNewCoursePage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.airplanemode_active,
                    Icons.airplanemode_active_rounded,
                    'Create Squadrons',
                    'Create Squadrons',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateSquadronsPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.supervised_user_circle_rounded,
                    Icons.supervised_user_circle_outlined,
                    'All Users',
                    'All Users',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => GetUsersPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.school_outlined,
                    Icons.school,
                    'All Departments',
                    'All Departments',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DepartmentsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.auto_awesome_motion_rounded,
                    Icons.auto_awesome_motion_outlined,
                    'All Years',
                    'All Years',
                    () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => YearsScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.grade_outlined,
                    Icons.grade,
                    'Grades overview',
                    'Grades overview',
                    () {},
                  ),
                ],
              ),
            ),
          ),
          _buildLogoutButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String title,
    String value,
    onTap,
  ) {
    final isSelected = selectedMenuItem == value;
    final isHovered = hoveredMenuItem == value;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hoveredMenuItem = value),
      onExit: (_) => setState(() => hoveredMenuItem = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMenuItem = value;
          });
        },
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
                    isSelected ? filledIcon : outlinedIcon,
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
      ),
    );
  }

  Widget _buildLogoutButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isLogoutHovered = true),
      onExit: (_) => setState(() => isLogoutHovered = false),
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
            color: isLogoutHovered
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLogoutHovered
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
