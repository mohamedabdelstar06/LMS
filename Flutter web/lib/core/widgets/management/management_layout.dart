import 'package:flutter/material.dart';
import 'package:lms/core/cons/Colors/app_colors.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';
import 'package:lms/core/widgets/management/management_sidebar.dart';

class ManagementScaffold extends StatefulWidget {

  const ManagementScaffold({
    super.key,
    required this.selectedMenuItem,
    required this.role,
    required this.child,
    this.pageTitle,
  });
  final String selectedMenuItem;
  final ManagementRole role;
  final Widget child;
  final String? pageTitle;

  static const double _mobileBreakpoint = 900;
  static const double _tabletBreakpoint = 1200;

  @override
  State<ManagementScaffold> createState() => _ManagementScaffoldState();
}

class _ManagementScaffoldState extends State<ManagementScaffold> {
  bool _isCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _resolvedTitle {
    if (widget.pageTitle != null) return widget.pageTitle!;
    for (final section in ManagementMenuConfig.sectionsFor(widget.role)) {
      for (final item in section.items) {
        if (item.id == widget.selectedMenuItem) return item.label;
      }
    }
    return widget.selectedMenuItem;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile =
            constraints.maxWidth < ManagementScaffold._mobileBreakpoint;
        final isTablet = constraints.maxWidth <
            ManagementScaffold._tabletBreakpoint;

        if (isMobile) {
          return _buildMobileLayout();
        }

        final autoCollapse = isTablet && !_isCollapsed;
        final collapsed = _isCollapsed || autoCollapse;

        return _buildDesktopLayout(collapsed: collapsed, showToggle: !isTablet);
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: Drawer(
        width: 280,
        backgroundColor: const Color(0xFF0F172A),
        child: ManagementSidebar(
          selectedMenuItem: widget.selectedMenuItem,
          role: widget.role,
          showCollapseToggle: false,
          onNavigate: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildTopBar(showMenuButton: true),
          Expanded(child: _buildContentArea()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout({
    required bool collapsed,
    required bool showToggle,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          ManagementSidebar(
            selectedMenuItem: widget.selectedMenuItem,
            role: widget.role,
            isCollapsed: collapsed,
            showCollapseToggle: showToggle,
            onToggleCollapse: showToggle
                ? () => setState(() => _isCollapsed = !_isCollapsed)
                : null,
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(showMenuButton: false),
                Expanded(child: _buildContentArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar({required bool showMenuButton}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showMenuButton)
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu_rounded),
              color: const Color(0xFF475569),
              tooltip: 'Open menu',
            ),
          Icon(
            widget.role == ManagementRole.admin
                ? Icons.manage_accounts_rounded
                : widget.role == ManagementRole.instructor
                    ? Icons.school_rounded
                    : Icons.person_rounded,
            size: 20,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          const Text(
            'Management',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              fontFamily: 'inter',
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Color(0xFFCBD5E1),
            ),
          ),
          Text(
            _resolvedTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              fontFamily: 'inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MYColors.gradientColor_3,
            MYColors.gradientColor_2.withValues(alpha: 0.15),
            const Color(0xFFF1F5F9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: widget.child,
    );
  }
}
