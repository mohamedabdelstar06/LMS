import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool isReadOnly;
  final bool isEnabled;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.isReadOnly = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
            fontSize: 14,
          ),
          child: Text(label),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: isEnabled,
          readOnly: isReadOnly,
          controller: controller,
          enableInteractiveSelection: !isReadOnly,
          style: TextStyle(
            fontSize: 14,
            color: isReadOnly ? Colors.black.withOpacity(0.3) : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF94A3B8).withOpacity(0.5),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}