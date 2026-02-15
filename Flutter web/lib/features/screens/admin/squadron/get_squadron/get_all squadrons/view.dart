import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/admin_profile/view.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/get_all%20squadrons/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/get_all%20squadrons/state_managment/states.dart';
import '../../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../../core/widgets/admin_action_button.dart';
import '../../../../../../core/widgets/admin_sidebar.dart';
import '../../../../Announcement/view.dart';
import '../../../courses/Enrollment_course/view.dart';
import '../../../courses/create_course/Adding_view.dart';
import '../../../courses/home_courses/view.dart';
import '../../../department/create_department/view.dart';
import '../../../department/get_department/get_All_departments/view.dart';
import '../../../user_file/import_file/view.dart';
import '../../../users/create_user/View.dart';
import '../../../users/get_users/view.dart';
import '../../../year/create_year/view.dart';
import '../../../year/get_year/get_All_years/view.dart';
import '../../create_squadron/view.dart';
import '../model/view.dart';
import '../update_squadrons/view.dart';

String selectedMenuItem = 'All Squadrons';

class GetSquadronPage extends StatefulWidget {
  const GetSquadronPage({super.key});

  @override
  State<GetSquadronPage> createState() => _SquadronsScreenState();
}

class _SquadronsScreenState extends State<GetSquadronPage> {
  int? hoveredRowIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AllSquadronCubit()..fetchSquadrons(),
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

          body: BlocConsumer<AllSquadronCubit, AllSquadronState>(
            listener: (context, state) {

              if (state is DeleteSquadronSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is DeleteSquadronError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is UpdateSquadronSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is UpdateSquadronError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },

            builder: (context, state) {
              if (state is AllSquadronLoading ||
                  state is DeleteSquadronLoading ||
                  state is UpdateSquadronLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                );
              }


              if (state is AllSquadronError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is AllSquadronLoaded) {
                return Row(
                  children: [
                    AdminSidebar(selectedMenuItem: selectedMenuItem),
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
                                            'All squadrons',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Manage all Squadrons',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    _buildStatsHeader(state.squadrons.length),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  child: SingleChildScrollView(
                                    child: _buildModernTable(
                                        context, state.squadrons),
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
                'Total Squadrons',
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

  Widget _buildModernTable(
      BuildContext context, List<SquadronModel> squadrons) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 340,
        ),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(260),
            1: FixedColumnWidth(180),
            3: FixedColumnWidth(300),
            4: FixedColumnWidth(70),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              children: [
                _buildTableHeader('Name', Icons.badge),

                _buildTableHeader('Students Count', Icons.person),

                _buildTableHeader('Description', Icons.description),

                _buildTableHeader('Actions', Icons.settings),
              ],
            ),

            ...squadrons.asMap().entries.map((entry) {
              final index = entry.key;
              final dep = entry.value;
              return _buildModernTableRow(context, dep, index);
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
          Icon(
            icon,
            size: 18,
            color:  Colors.blue ,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:  Colors.blue ,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildModernTableRow(
      BuildContext context, SquadronModel squadron, int index) {
    final isHovered = hoveredRowIndex == index;

    return TableRow(
      decoration: BoxDecoration(
        color: isHovered
            ? const Color(0xFF2563EB).withOpacity(0.05)
            : index.isEven
            ? Colors.white
            : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
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
                      Icons.school,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      squadron.name,
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 14,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      squadron.studentCount.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
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
              child: Text(
                squadron.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
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
                  AdminActionButton(
                    icon: Icons.edit,
                    color: const Color(0xFF2563EB),
                    tooltip: 'Edit',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AllSquadronCubit>(),
                            child: EditSquadronScreen(
                          squadronId: squadron.id),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  AdminActionButton(
                    icon: Icons.delete,
                    color: const Color(0xFFEF4444),
                    tooltip: 'Delete',
                    onPressed: () {
                      if (squadron.studentCount > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You cannot delete a year that has courses'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      _showDeleteDialog(context, squadron.id);
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

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Squadron"),
        content: const Text("Are you sure you want to delete this Squadron?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AllSquadronCubit>().deleteSquadron(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

