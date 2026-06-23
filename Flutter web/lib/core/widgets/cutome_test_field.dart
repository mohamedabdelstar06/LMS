import 'package:flutter/material.dart';

Widget buildTextField(
  bool isEnabled,
  String label,
  TextEditingController controller,
  IconData icon,
  String hint,
  bool isReadOnly,
) {
  return StatefulBuilder(
    builder: (context, setFieldState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
            child: Text(label),
          ),
          const SizedBox(height: 8),
          TextField(
            enabled: false,
            readOnly: true,
            controller: controller,
            enableInteractiveSelection: false,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.3),
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
    },
  );
}
