import 'package:flutter/material.dart';

import 'file_config.dart';

class TypeSelector extends StatelessWidget {
  const TypeSelector({super.key, required this.selected, required this.onChange});
  final String selected;
  final ValueChanged<String> onChange;

  static const _types = ['Pdf', 'Video', 'Audio',];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _types.map((t) {
        final active = selected == t;
        return GestureDetector(
          onTap: () => onChange(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
              )
                  : null,
              color: active ? null : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active
                    ? Colors.transparent
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  typeIconFor(t),
                  size: 14,
                  color: active ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  t,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
