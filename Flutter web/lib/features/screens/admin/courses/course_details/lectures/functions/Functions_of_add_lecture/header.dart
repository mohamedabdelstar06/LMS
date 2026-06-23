import 'package:flutter/material.dart';

import '../../model/model.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.isEdit, required this.lecture});
  final bool isEdit;
  final LectureModel? lecture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEdit
                    ? [const Color(0xFF7C3AED), const Color(0xFFA78BFA)]
                    : [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Lecture' : 'Add New Lecture',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (isEdit && lecture != null)
                  const Text(
                    'Update the lecture information and manage attached files',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Text(
                    'Fill in the details and attach files',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          // IconButton(
          //   onPressed: () => Navigator.pop(context),
          //   icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
          // ),
        ],
      ),
    );
  }
}
