import 'package:flutter/material.dart';
import 'package:lms/core/helpers/logout_server/logout.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';
import 'package:lms/generated/assets.dart';

class ManagementSidebar extends StatefulWidget {

  const ManagementSidebar({
    super.key,
    required this.selectedMenuItem,
    required this.role,
    this.isCollapsed = false,
    this.showCollapseToggle = true,
    this.onToggleCollapse,
    this.onNavigate,
  });
  final String selectedMenuItem;
  final ManagementRole role;
  final bool isCollapsed;
  final bool showCollapseToggle;
  final VoidCallback? onToggleCollapse;
  final VoidCallback? onNavigate;

  @override
  State<ManagementSidebar> createState() => _ManagementSidebarState();
}

class _ManagementSidebarState extends State<ManagementSidebar> {
  String? _hoveredItemId;
  bool _isLogoutHovered = false;

  static const _expandedWidth = 260.0;
  static const _collapsedWidth = 72.0;

  double get _width =>
      widget.isCollapsed ? _collapsedWidth : _expandedWidth;

  void _navigate(ManagementMenuItem item) {
    if (widget.selectedMenuItem == item.id) return;
    widget.onNavigate?.call();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => item.screenBuilder(),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = ManagementMenuConfig.sectionsFor(widget.role);
    final portalLabel = widget.role == ManagementRole.admin
        ? 'Admin Portal'
        : 'Instructor Portal';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: _width,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B)),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(portalLabel),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final section in sections) ...[
                  if (!widget.isCollapsed) _buildSectionTitle(section.title),
                  if (widget.isCollapsed) const SizedBox(height: 4),
                  for (final item in section.items)
                    _buildMenuItem(item),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),
          _buildLogoutButton(),
          if (widget.showCollapseToggle) _buildCollapseToggle(),
        ],
      ),
    );
  }

  Widget _buildHeader(String portalLabel) {
    return Container(
      height: 68,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 12 : 20,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const CircleAvatar(
              radius: 17,
              backgroundImage: AssetImage(Assets.logo),
            ),
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اّفــــــاق',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      fontFamily: 'inter',
                    ),
                  ),
                  Text(
                    portalLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.35),
          letterSpacing: 1.2,
          fontFamily: 'inter',
        ),
      ),
    );
  }

  Widget _buildMenuItem(ManagementMenuItem item) {
    final isSelected = widget.selectedMenuItem == item.id;
    final isHovered = _hoveredItemId == item.id;

    final content = MouseRegion(
      onEnter: (_) => setState(() => _hoveredItemId = item.id),
      onExit: (_) => setState(() => _hoveredItemId = null),
      cursor: isSelected ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isSelected ? null : () => _navigate(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 8 : 12,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : isHovered
                    ? Colors.white.withOpacity(0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isHovered && !isSelected
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
          ),
          child: widget.isCollapsed
              ? Center(
                  child: Icon(
                    isSelected ? item.filledIcon : item.outlinedIcon,
                    size: 22,
                    color: isSelected
                        ? Colors.white
                        : isHovered
                            ? Colors.white
                            : Colors.white.withOpacity(0.55),
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      isSelected ? item.filledIcon : item.outlinedIcon,
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : isHovered
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isHovered
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.75),
                          fontFamily: 'inter',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: item.label,
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 400),
        child: content,
      );
    }

    return content;
  }

  Widget _buildLogoutButton() {
    final content = MouseRegion(
      onEnter: (_) => setState(() => _isLogoutHovered = true),
      onExit: (_) => setState(() => _isLogoutHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 8 : 12,
            vertical: 8,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _isLogoutHovered
                ? const Color(0xFFEF4444).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: _isLogoutHovered
                ? Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                  )
                : null,
          ),
          child: widget.isCollapsed
              ? const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                )
              : const Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: 'Logout',
        preferBelow: false,
        child: content,
      );
    }

    return content;
  }

  Widget _buildCollapseToggle() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggleCollapse,
        child: Container(
          height: 44,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF1E293B)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                turns: widget.isCollapsed ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: 22,
                ),
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 6),
                Text(
                  'Collapse',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.45),
                    fontFamily: 'inter',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async => await LogoutServer.logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
