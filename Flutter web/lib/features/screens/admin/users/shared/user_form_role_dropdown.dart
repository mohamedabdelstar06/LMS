import 'package:flutter/material.dart';

final List<Map<String, dynamic>> kUserRoles = [
  {
    "name": "Admin",
    "icon": Icons.admin_panel_settings,
    "color": Colors.redAccent,
  },
  {"name": "Instructor", "icon": Icons.school, "color": Colors.orangeAccent},
  {"name": "Student", "icon": Icons.person, "color": Colors.blueAccent},
];

/// Role dropdown that notifies parent immediately on change (no global state).
/// Use value + onChanged for controlled, reactive updates.
class UserFormRoleDropdown extends StatefulWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const UserFormRoleDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<UserFormRoleDropdown> createState() => _UserFormRoleDropdownState();
}

class _UserFormRoleDropdownState extends State<UserFormRoleDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Role',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isExpanded ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isExpanded
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                  width: _isExpanded ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForRole(widget.value),
                        color: const Color(0xFF2563EB),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: kUserRoles.length,
              itemBuilder: (context, index) {
                final option = kUserRoles[index];
                final roleName = option["name"] as String;
                final isSelected = roleName == widget.value;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isExpanded = false);
                      widget.onChanged(roleName);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: isSelected
                          ? (option["color"] as Color).withOpacity(0.1)
                          : Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: option["color"] as Color,
                                child: Icon(
                                  option["icon"] as IconData,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                roleName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? option["color"] as Color
                                      : const Color(0xFF1E293B),
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: option["color"] as Color,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  IconData _getIconForRole(String role) {
    final found = kUserRoles.cast<Map<String, dynamic>>().firstWhere(
          (r) => r["name"] == role,
          orElse: () => {"icon": Icons.person, "color": Colors.grey},
        );
    return found["icon"] as IconData;
  }
}
