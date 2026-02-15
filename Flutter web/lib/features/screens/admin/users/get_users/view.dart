import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/users/get_users/state_managment/get_users_cubit.dart';
import 'package:lms/features/screens/admin/users/get_users/state_managment/get_users_state.dart';
import 'package:lms/features/screens/admin/users/get_users/view_updating_user.dart';
import '../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../core/widgets/admin_action_button.dart';
import '../../../../../core/widgets/custome_sidebar.dart';
import '../../../../../core/widgets/admin_table_header.dart';
import '../../../../../core/widgets/app_network_image.dart';
import 'get_user_model/view.dart';

class GetUsersPage extends StatelessWidget {
  const GetUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetUsersCubit(dio: Dio()),
      child: const GetUsersScreen(),
    );
  }
}

class GetUsersScreen extends StatefulWidget {
  const GetUsersScreen({super.key});

  @override
  State<GetUsersScreen> createState() => _GetUsersScreenState();
}

class _GetUsersScreenState extends State<GetUsersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String selectedMenuItem = 'All Users';
  int? hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    context.read<GetUsersCubit>().fetchUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        body: BlocListener<GetUsersCubit, GetUsersState>(
          listener: (context, state) {
            if (state is DeleteUserSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            if (state is DeleteUserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            if (state is DeactivateUserSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(state.message),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            if (state is DeactivateUserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            if (state is UpdateUsersSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            if (state is UpdateUsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: Row(
            children: [
              CustomeSidebar(selectedMenuItem: selectedMenuItem),
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
                        BlocBuilder<GetUsersCubit, GetUsersState>(
                          buildWhen: (p, c) => c is GetUsersLoaded,
                          builder: (context, state) {
                            if (state is GetUsersLoaded) {
                              return AdminTableHeader(
                                icon: Icons.people,
                                title: 'All Users',
                                subtitle: 'Manage all users',
                                stats: [
                                  AdminStatBadge(
                                    title: 'Total',
                                    count: state.usersResponse.totalCount,
                                    icon: Icons.people,
                                    color:  Colors.blueAccent.shade200,
                                  ),
                                  AdminStatBadge(
                                    title: 'Admins',
                                    count: state.usersResponse.totalAdmins,
                                    icon: Icons.admin_panel_settings,
                                    color: Colors.purple.shade200,
                                  ),
                                  AdminStatBadge(
                                    title: 'Instructors',
                                    count: state.usersResponse.totalInstructors,
                                    icon: Icons.school,
                                    color: Colors.orange.shade200,
                                  ),
                                  AdminStatBadge(
                                    title: 'Students',
                                    count: state.usersResponse.totalStudents,
                                    icon: Icons.person,
                                    color: Colors.green.shade200,
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        Expanded(
                          child: BlocBuilder<GetUsersCubit, GetUsersState>(
                            buildWhen: (p, c) =>
                                c is! UpdateUsersSuccess && c is! UpdateUsersError,
                            builder: (context, state) {
                              if (state is GetUsersLoading ||
                                  state is DeleteUserLoading ||
                                  state is UpdateUsersLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state is GetUsersError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.message,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => context
                                          .read<GetUsersCubit>()
                                          .fetchUsers(),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (state is GetUsersLoaded) {
                              final users = state.usersResponse.users;

                              if (users.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No users found",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: () async =>
                                    context.read<GetUsersCubit>().fetchUsers(),
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    child: _buildModernUsersTable(
                                        context, users),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                      BlocBuilder<GetUsersCubit, GetUsersState>(
                        builder: (context, state) {
                          if (state is GetUsersLoaded) {
                            final int currentPage = state.currentPage;
                            final int totalPages =
                                state.usersResponse.totalPages;
                            final bool hasNext =
                                state.usersResponse.hasNextPage;
                            final bool hasPrevious =
                                state.usersResponse.hasPreviousPage;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    MYColors.gradientColor_3,
                                    MYColors.gradientColor_2.withValues(
                                      alpha: 0.2,
                                    ),
                                  ],
                                ),

                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: hasPrevious
                                        ? () => context
                                              .read<GetUsersCubit>()
                                              .goToPage(currentPage - 1)
                                        : null,
                                    icon: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('Previous'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasPrevious
                                          ? const Color(0xFF1849A9)
                                          : Colors.grey.shade300,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF1849A9),
                                          Color(0xFF53B1FD),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.library_books_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Page $currentPage',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'of $totalPages',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: hasNext
                                        ? () => context
                                              .read<GetUsersCubit>()
                                              .goToPage(currentPage + 1)
                                        : null,
                                    label: const Text('Next'),
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasNext
                                          ? const Color(0xFF1849A9)
                                          : Colors.grey.shade300,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          )],
          ),
        ),
      ),
    );
  }

  Widget _buildModernUsersTable(
      BuildContext context, List<GetUserModel> users, ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 340,
        ),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(200),
            1: FixedColumnWidth(120),
            2: FixedColumnWidth(180),
            3: FixedColumnWidth(230),
            4: FixedColumnWidth(115),
            5: FixedColumnWidth(200),
            6: FixedColumnWidth(180),
            7: FixedColumnWidth(180),
            8: FixedColumnWidth(110),
            9: FixedColumnWidth(190),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              children: [
                _buildUsersTableHeader('N_ID', Icons.badge),
                _buildUsersTableHeader('Profile', Icons.person),
                _buildUsersTableHeader('Full Name', Icons.person_outline),
                _buildUsersTableHeader('Email', Icons.email),
                _buildUsersTableHeader('Role', Icons.admin_panel_settings),
                _buildUsersTableHeader('Department', Icons.business),
                _buildUsersTableHeader('Year', Icons.calendar_today),
                _buildUsersTableHeader('Squadron', Icons.group),
                _buildUsersTableHeader('Status', Icons.info),
                _buildUsersTableHeader('Actions', Icons.settings),
              ],
            ),
            ...users.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              return _buildModernUserTableRow(context, user, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTableHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
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

  TableRow _buildModernUserTableRow(
      BuildContext context, GetUserModel user, int index) {
    final isHovered = hoveredRowIndex == index;

    Color statusColor;
    Color statusTextColor;
    String statusText;
    if (user.accountStatus.toLowerCase() == 'active') {
      statusColor = Colors.blue.shade100;
      statusTextColor = Colors.blue.shade800;
      statusText = 'Active';
    } else if (user.accountStatus.toLowerCase() == 'disabled') {
      statusColor = Colors.red.shade100;
      statusTextColor = Colors.red.shade800;
      statusText = 'Inactive';
    } else {
      statusColor = Colors.grey.shade300;
      statusTextColor = Colors.grey.shade800;
      statusText = 'Pending';
    }

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
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${user.nationalId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: AppNetworkImage(
                imageUrl: user.profileImageUrl,
                size: 48,
                fallbackText: user.fullName,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
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
                      Icons.person_outline,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      user.fullName,
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
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                user.email,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _RoleBadge(role: user.role),
            ),
          ),
        ),
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _InfoBadge(
                icon: Icons.business,
                text: user.academicInfo?.department?.name ?? 'N/A',
                color: Colors.purple,
              ),
            ),
          ),
        ),
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _InfoBadge(
                icon: Icons.calendar_today,
                text: user.academicInfo?.year?.name ?? 'N/A',
                color: Colors.orange,
              ),
            ),
          ),
        ),
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _InfoBadge(
                icon: Icons.group,
                text: user.academicInfo?.squadron?.name ?? 'N/A',
                color: Colors.teal,
              ),
            ),
          ),
        ),
        _buildUsersTableCell(
          MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusTextColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildUsersTableCell(
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
                    icon: Icons.visibility,
                    color: const Color(0xFF2563EB),
                    tooltip: 'View',
                    onPressed: () => _showUserDetailsDialog(user, context),
                  ),
                  const SizedBox(width: 4),
                  AdminActionButton(
                    icon: Icons.edit,
                    color: const Color(0xFF10B981),
                    tooltip: 'Edit',
                    onPressed: () async {
                      final cubit = context.read<GetUsersCubit>();
                      final currentState = cubit.state;
                      int page = 1;
                      String searchQuery = '';
                      if (currentState is GetUsersLoaded) {
                        page = currentState.currentPage;
                        searchQuery = currentState.searchQuery;
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: UpdateUserScreen(
                              userId: user.id,
                              user: user,
                            ),
                          ),
                        ),
                      );
                      if (context.mounted) {
                        cubit.fetchUsers(
                          page: page,
                          searchQuery: searchQuery,
                        );
                      }
                    },
                  ),
                  if (user.accountStatus.toLowerCase() == 'active') ...[
                    const SizedBox(width: 4),
                    AdminActionButton(
                      icon: Icons.block,
                      color: Colors.orange,
                      tooltip: 'Deactivate',
                      onPressed: () => _showDeactivateDialog(context, user),
                    ),
                  ],
                  const SizedBox(width: 4),
                  AdminActionButton(
                    icon: Icons.delete,
                    color: const Color(0xFFEF4444),
                    tooltip: 'Delete',
                    onPressed: () => _showDeleteDialog(context, user),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTableCell(Widget child) => child;

  void _showDeactivateDialog(BuildContext parentContext, GetUserModel user) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Deactivate User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to deactivate "${user.fullName}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This user will not be able to access the system.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              parentContext.read<GetUsersCubit>().deactivateUser(user.id);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.block, size: 18),
            label: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext parentContext, GetUserModel user) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              parentContext.read<GetUsersCubit>().deleteUser(user.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (role == 'Admin') {
      bgColor = Colors.purple.shade100;
      textColor = Colors.purple.shade800;
    } else if (role == 'Instructor') {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    } else {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isNA = text == 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isNA ? Colors.grey.shade200 : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isNA ? Colors.grey.shade400 : color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isNA ? Colors.grey.shade600 : color.withOpacity(0.8),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isNA ? Colors.grey.shade600 : color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

void _showUserDetailsDialog(GetUserModel user, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AppNetworkImage(
                    imageUrl: user.profileImageUrl,
                    size: 80,
                    fallbackText: user.fullName,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              _DetailRow(label: 'ID', value: '#${user.id}'),
              _DetailRow(label: 'Role', value: user.role),
              _DetailRow(label: 'National ID', value: user.nationalId ?? 'N/A'),
              _DetailRow(label: 'Gender', value: user.gender ?? 'N/A'),
              _DetailRow(label: 'City', value: user.city ?? 'N/A'),
              _DetailRow(label: 'Status', value: user.accountStatus),
              if (user.academicInfo != null) ...[
                const Divider(height: 32),
                Text(
                  'Academic Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Department',
                  value: user.academicInfo!.department?.name ?? 'N/A',
                ),
                _DetailRow(
                  label: 'Year',
                  value: user.academicInfo!.year?.name ?? 'N/A',
                ),
                _DetailRow(
                  label: 'Squadron',
                  value: user.academicInfo!.squadron?.name ?? 'N/A',
                ),
                _DetailRow(
                  label: 'Admission Year',
                  value: user.academicInfo!.admissionYear.toString(),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
