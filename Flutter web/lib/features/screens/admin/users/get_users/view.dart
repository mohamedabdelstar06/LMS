import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/users/get_users/state_managment/get_users_cubit.dart';
import 'package:lms/features/screens/admin/users/get_users/state_managment/get_users_state.dart';
import 'package:lms/features/screens/admin/users/get_users/view_updating_user.dart';
import '../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../core/widgets/admin_action_button.dart';
import '../../../../../core/widgets/management/management_layout.dart';
import '../../../../../core/widgets/management/management_menu_config.dart';
import '../../../../../core/widgets/admin_table_header.dart';
import '../../../../../core/widgets/app_network_image.dart';
import 'get_user_model/view.dart';

class GetUsersPage extends StatefulWidget {
  const GetUsersPage({super.key});

  @override
  State<GetUsersPage> createState() => _GetUsersScreenState();
}

class _GetUsersScreenState extends State<GetUsersPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String selectedMenuItem = 'All Users';
  int? hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Trigger load when 200 px from the bottom
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<GetUsersCubit>().loadMoreUsers();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetUsersCubit()..fetchUsers(),
      child: ManagementScaffold(
        selectedMenuItem: selectedMenuItem,
        role: ManagementRole.admin,
        child: BlocConsumer<GetUsersCubit, GetUsersState>(
          listener: (context, state) {
            if (state is DeleteUserSuccess) {
              _showSnack(context, state.message, Colors.green);
              context.read<GetUsersCubit>().fetchUsers();
            }
            if (state is DeleteUserError) {
              _showSnack(context, state.message, Colors.red);
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
              context.read<GetUsersCubit>().fetchUsers();
            }
            if (state is DeactivateUserError) {
              _showSnack(context, state.message, Colors.red);
            }
            // UpdateUsersSuccess is handled in UpdateUserScreen itself.
            // When the user navigates back, the list is already refreshed
            // because updateUser() calls fetchUsers(silent:true) before emitting
            // success. No extra fetchUsers() call needed here.
          },
          builder: (context, state) {
            if (state is GetUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
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
                    // ── Header ────────────────────────────────────────────────
                    if (state is GetUsersLoaded)
                      AdminTableHeader(
                        icon: Icons.people,
                        title: 'All Users',
                        subtitle: 'Manage all users',
                        stats: [
                          AdminStatBadge(
                            title: 'Total',
                            count: state.usersResponse.totalCount,
                            icon: Icons.people,
                            color: Colors.blueAccent.shade200,
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
                      ),

                    // ── Table body ────────────────────────────────────────────
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          if (state is GetUsersLoading ||
                              state is DeleteUserLoading) {
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
                                      'No users found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: _buildModernUsersTable(
                                      context,
                                      users,
                                    ),
                                  ),

                                  // ── Infinite scroll footer ────────────────
                                  if (state.isLoadingMore)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: _LoadingMoreIndicator(),
                                    )
                                  else if (!state.usersResponse.hasNextPage &&
                                      users.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: Text(
                                        'All ${state.usersResponse.totalCount} users loaded',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  else
                                    // invisible trigger zone so scroll fires
                                    const SizedBox(height: 40),
                                ],
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSnack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────────
  Widget _buildModernUsersTable(
    BuildContext context,
    List<GetUserModel> users,
  ) {
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
            ...users.asMap().entries.map(
              (entry) =>
                  _buildModernUserTableRow(context, entry.value, entry.key),
            ),
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
    BuildContext context,
    GetUserModel user,
    int index,
  ) {
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
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      children: [
        // N_ID
        _cell(
          user,
          index,
          Padding(
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
        // Profile
        _cell(
          user,
          index,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: AppNetworkImage(
              imageUrl: user.profileImageUrl,
              fallbackText: user.fullName,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Full Name
        _cell(
          user,
          index,
          Padding(
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
        // Email
        _cell(
          user,
          index,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              user.email,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Role
        _cell(
          user,
          index,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _RoleBadge(role: user.role),
          ),
        ),
        // Department
        _cell(
          user,
          index,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _InfoBadge(
              icon: Icons.business,
              text: user.academicInfo?.department?.name ?? 'N/A',
              color: Colors.purple,
            ),
          ),
        ),
        // Year
        _cell(
          user,
          index,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _InfoBadge(
              icon: Icons.calendar_today,
              text: user.academicInfo?.year?.name ?? 'N/A',
              color: Colors.orange,
            ),
          ),
        ),
        // Squadron
        _cell(
          user,
          index,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _InfoBadge(
              icon: Icons.group,
              text: user.academicInfo?.squadron?.name ?? 'N/A',
              color: Colors.teal,
            ),
          ),
        ),
        // Status
        _cell(
          user,
          index,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusTextColor.withOpacity(0.3)),
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
        // Actions
        _cell(
          user,
          index,
          Padding(
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
                          child: UpdateUserScreen(userId: user.id, user: user),
                        ),
                      ),
                    );
                    // List was already refreshed silently inside updateUser().
                    // If the user just dismissed the screen without saving,
                    // we still want to make sure the list state is correct.
                    if (context.mounted && cubit.state is! GetUsersLoaded) {
                      cubit.fetchUsers(page: page, searchQuery: searchQuery);
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
                  onPressed: () => _showDangerDeleteDialog(context, user),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Wraps a cell in a MouseRegion that tracks hover per row
  Widget _cell(GetUserModel user, int index, Widget child) {
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRowIndex = index),
      onExit: (_) => setState(() => hoveredRowIndex = null),
      child: child,
    );
  }

  // ── Delete dialog ─────────────────────────────────────────────────────────
  void _showDangerDeleteDialog(BuildContext context, GetUserModel user) {
    final confirmController = TextEditingController();
    final confirmText = user.fullName.trim();
    bool isConfirmed = false;
    final cubit = context.read<GetUsersCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDs) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 480,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _dialogHeader(
                  icon: Icons.delete_forever,
                  iconColor: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEF2F2),
                  title: 'Delete User',
                  titleColor: const Color(0xFFEF4444),
                  subtitle: 'This action cannot be undone',
                  subtitleColor: const Color(0xFFB91C1C),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _warningBox(
                        'You are about to permanently delete user "${user.fullName}". This will remove all associated data.',
                      ),
                      const SizedBox(height: 20),
                      _confirmField(
                        confirmText: confirmText,
                        controller: confirmController,
                        isConfirmed: isConfirmed,
                        accentColor: const Color(0xFFEF4444),
                        confirmMessage: 'Name confirmed — you can now delete',
                        onChanged: (v) =>
                            setDs(() => isConfirmed = v.trim() == confirmText),
                      ),
                    ],
                  ),
                ),
                _dialogActions(
                  isConfirmed: isConfirmed,
                  cancelLabel: 'Cancel',
                  confirmLabel: 'Delete Forever',
                  confirmColor: const Color(0xFFEF4444),
                  confirmIcon: Icons.delete_forever,
                  onCancel: () {
                    confirmController.dispose();
                    Navigator.pop(dialogContext);
                  },
                  onConfirm: () {
                    Navigator.pop(dialogContext);
                    cubit.deleteUser(user.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Deactivate dialog ─────────────────────────────────────────────────────
  void _showDeactivateDialog(BuildContext context, GetUserModel user) {
    final confirmController = TextEditingController();
    final confirmText = user.fullName.trim();
    bool isConfirmed = false;
    final cubit = context.read<GetUsersCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDs) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 480,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogHeader(
                  icon: Icons.block,
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFEF2F2),
                  title: 'Deactivate User',
                  titleColor: const Color(0xFFD97706),
                  subtitle: 'User will lose system access',
                  subtitleColor: const Color(0xFFB45309),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _warningBox(
                        'You are about to deactivate user "${user.fullName}". This user will not be able to log in and access the system.',
                      ),
                      const SizedBox(height: 20),
                      _confirmField(
                        confirmText: confirmText,
                        controller: confirmController,
                        isConfirmed: isConfirmed,
                        accentColor: const Color(0xFFF59E0B),
                        confirmMessage:
                            'Name confirmed — you can now deactivate',
                        onChanged: (v) =>
                            setDs(() => isConfirmed = v.trim() == confirmText),
                      ),
                    ],
                  ),
                ),
                _dialogActions(
                  isConfirmed: isConfirmed,
                  cancelLabel: 'Cancel',
                  confirmLabel: 'Deactivate User',
                  confirmColor: const Color(0xFFF59E0B),
                  confirmIcon: Icons.block,
                  onCancel: () {
                    confirmController.dispose();
                    Navigator.pop(dialogContext);
                  },
                  onConfirm: () {
                    Navigator.pop(dialogContext);
                    cubit.deactivateUser(user.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared dialog widgets ─────────────────────────────────────────────────────

Widget _dialogHeader({
  required IconData icon,
  required Color iconColor,
  required Color bgColor,
  required String title,
  required Color titleColor,
  required String subtitle,
  required Color subtitleColor,
}) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: bgColor,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
  ),
  child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: subtitleColor),
            ),
          ],
        ),
      ),
    ],
  ),
);

Widget _warningBox(String text) => Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFFFFF7ED),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFFED7AA)),
  ),
  child: Row(
    children: [
      const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
        ),
      ),
    ],
  ),
);

Widget _confirmField({
  required String confirmText,
  required TextEditingController controller,
  required bool isConfirmed,
  required Color accentColor,
  required String confirmMessage,
  required ValueChanged<String> onChanged,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'To confirm, type the user name below:',
      style: TextStyle(
        fontSize: 13,
        color: Color(0xFF475569),
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.keyboard, size: 14, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            confirmText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Type user name here...',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isConfirmed
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    ),
    if (!isConfirmed && controller.text.isNotEmpty)
      const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Icon(Icons.close, size: 14, color: Color(0xFFEF4444)),
            SizedBox(width: 4),
            Text(
              'User name does not match',
              style: TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
            ),
          ],
        ),
      ),
    if (isConfirmed)
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            const Icon(Icons.check, size: 14, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              confirmMessage,
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ],
        ),
      ),
  ],
);

Widget _dialogActions({
  required bool isConfirmed,
  required String cancelLabel,
  required String confirmLabel,
  required Color confirmColor,
  required IconData confirmIcon,
  required VoidCallback onCancel,
  required VoidCallback onConfirm,
}) => Padding(
  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
  child: Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            cancelLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: isConfirmed ? onConfirm : null,
          icon: Icon(confirmIcon, size: 18),
          label: Text(
            confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade200,
            disabledForegroundColor: Colors.grey.shade400,
            padding: const EdgeInsets.symmetric(vertical: 14),
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

// ── Loading more indicator ────────────────────────────────────────────────────
class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading more users...',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }
}

// ── Role / Info badges ────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    if (role == 'Admin') {
      bg = Colors.purple.shade100;
      text = Colors.purple.shade800;
    } else if (role == 'Instructor') {
      bg = Colors.orange.shade100;
      text = Colors.orange.shade800;
    } else {
      bg = Colors.green.shade100;
      text = Colors.green.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.color,
  });
  final IconData icon;
  final String text;
  final Color color;

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

// ── User details dialog ───────────────────────────────────────────────────────

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
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

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
