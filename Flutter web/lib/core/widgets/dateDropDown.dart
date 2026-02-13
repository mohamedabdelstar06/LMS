import 'package:flutter/material.dart';

class ProfileDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const ProfileDateField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.selectedDate,
    required this.onDateSelected,
  });

  String _formatDate(DateTime date) {
    return "${date.day.toString()}/"
        "${date.month.toString()}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE2E8F0),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused
                ? [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: true,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF94A3B8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              if (picked != null) {
                controller.text = _formatDate(picked);
                onDateSelected(picked);
              }
            },
          ),
        ),
      ],
    );
  }
}