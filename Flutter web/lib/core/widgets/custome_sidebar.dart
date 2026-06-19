import 'package:flutter/material.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';
import 'package:lms/core/widgets/management/management_sidebar.dart';

/// Backward-compatible wrapper. Prefer [ManagementScaffold] for new screens.
class CustomeSidebar extends StatelessWidget {
  final String selectedMenuItem;

  const CustomeSidebar({super.key, required this.selectedMenuItem});

  @override
  Widget build(BuildContext context) {
    return ManagementSidebar(
      selectedMenuItem: selectedMenuItem,
      role: ManagementRole.admin,
    );
  }
}
