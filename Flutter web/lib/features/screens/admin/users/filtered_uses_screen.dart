
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_network_image.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_model/view.dart';
import 'package:lms/features/screens/admin/users/get_users/state_managment/get_users_cubit.dart';
import 'package:lms/features/screens/admin/users/get_users/state_managment/get_users_state.dart';


enum FilteredRole { students, instructors, admins }

extension FilteredRoleX on FilteredRole {
  String get label {
    switch (this) {
      case FilteredRole.students:
        return 'Students';
      case FilteredRole.instructors:
        return 'Instructors';
      case FilteredRole.admins:
        return 'Admins';
    }
  }

  String get apiRole {
    switch (this) {
      case FilteredRole.students:
        return 'Student';
      case FilteredRole.instructors:
        return 'Instructor';
      case FilteredRole.admins:
        return 'Admin';
    }
  }

  IconData get icon {
    switch (this) {
      case FilteredRole.students:
        return Icons.school_rounded;
      case FilteredRole.instructors:
        return Icons.person_pin_rounded;
      case FilteredRole.admins:
        return Icons.admin_panel_settings_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FilteredRole.students:
        return const Color(0xFF12B76A);
      case FilteredRole.instructors:
        return const Color(0xFFF79009);
      case FilteredRole.admins:
        return const Color(0xFF2563EB);
    }
  }
}


class FilteredUsersScreen extends StatelessWidget {
  const FilteredUsersScreen({super.key, required this.role});
  final FilteredRole role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetUsersCubit()
        ..loadUsers(
          roleFilter: role.apiRole,
          sortBy: 'createdAt',
          order: 'desc',
        ),
      child: _FilteredUsersView(role: role),
    );
  }
}


class _FilteredUsersView extends StatefulWidget {
  const _FilteredUsersView({required this.role});
  final FilteredRole role;

  @override
  State<_FilteredUsersView> createState() => _FilteredUsersViewState();
}

class _FilteredUsersViewState extends State<_FilteredUsersView> {
  static const double _expandedHeight = 200;
  static const double _collapsedHeight = kToolbarHeight;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  double _collapseProgress = 0; 

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final cubit = context.read<GetUsersCubit>();
      if (cubit.state is GetUsersLoaded) cubit.loadMore();
    }

    
    
    
    final scrollRange = _expandedHeight - _collapsedHeight;
    final progress = (_scrollCtrl.offset / scrollRange).clamp(0.0, 1.0);
    if (progress != _collapseProgress) {
      setState(() => _collapseProgress = progress);
    }
  }

  void _search(String query) {
    context.read<GetUsersCubit>().loadUsers(
      searchQuery: query,
      roleFilter: widget.role.apiRole,
      sortBy: 'createdAt',
      order: 'desc',
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.role.color;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          
          SliverAppBar(
            expandedHeight: _expandedHeight,
            toolbarHeight: _collapsedHeight,
            pinned: true,
            elevation: 0,
            backgroundColor: color,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            
            
            title: Opacity(
              opacity: _collapseProgress,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.role.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.role.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding: EdgeInsets.zero,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    
                    Positioned(
                      right: -18,
                      bottom: -18,
                      child: Icon(
                        widget.role.icon,
                        size: 120,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Opacity(
                            
                            
                            opacity: 1 - _collapseProgress,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                  ),
                                  child: Icon(
                                    widget.role.icon,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.role.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    BlocBuilder<GetUsersCubit, GetUsersState>(
                                      builder: (_, state) {
                                        final count = state is GetUsersLoaded
                                            ? state.totalCount
                                            : 0;
                                        return Text(
                                          '$count registered',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _SearchBar(
                ctrl: _searchCtrl,
                color: color,
                onChanged: _search,
                onClear: () {
                  _searchCtrl.clear();
                  _search('');
                },
              ),
            ),
          ),

          
          BlocBuilder<GetUsersCubit, GetUsersState>(
            builder: (_, state) {
              if (state is GetUsersLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is GetUsersError) {
                return SliverFillRemaining(
                  child: _ErrorView(
                    message: state.message,
                    onRetry: () => context.read<GetUsersCubit>().loadUsers(
                      roleFilter: widget.role.apiRole,
                    ),
                  ),
                );
              }

              List<GetUserModel> users = [];
              bool loadingMore = false;

              if (state is GetUsersLoaded) {
                users = state.users;
              } else if (state is GetUsersLoadingMore) {
                users = state.currentUsers;
                loadingMore = true;
              }

              if (users.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyView(role: widget.role),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((_, i) {
                    if (i == users.length) {
                      return loadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                    return _UserCard(user: users[i], color: color, index: i);
                  }, childCount: users.length + 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.ctrl,
    required this.color,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController ctrl;
  final Color color;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search by name or email…',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(Icons.search_rounded, color: color, size: 20),
        suffixIcon: ctrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }
}


class _UserCard extends StatefulWidget {
  const _UserCard({
    required this.user,
    required this.color,
    required this.index,
  });
  final GetUserModel user;
  final Color color;
  final int index;

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 40 * (widget.index % 15)), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final color = widget.color;

    
    final isActive = user.accountStatus.toLowerCase() == 'active';

    
    final deptName = user.academicInfo?.department?.name;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              
              Stack(
                children: [
                  AppNetworkImage(
                    imageUrl: user.profileImageUrl,
                    width: 52,
                    height: 52,
                    fallbackText: user.fullName,
                    shape: BoxShape.circle,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF12B76A)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isNotEmpty ? user.fullName : 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MiniChip(label: user.role, color: color),
                        if (deptName != null && deptName.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _MiniChip(
                            label: deptName,
                            color: const Color(0xFF4F46E5),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF12B76A).withOpacity(0.10)
                          : const Color(0xFF94A3B8).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFF12B76A)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: color.withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}


class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.role});
  final FilteredRole role;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: role.color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(role.icon, size: 44, color: role.color),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${role.label} found',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search',
            style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}


class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 52,
              color: Color(0xFFF04438),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
