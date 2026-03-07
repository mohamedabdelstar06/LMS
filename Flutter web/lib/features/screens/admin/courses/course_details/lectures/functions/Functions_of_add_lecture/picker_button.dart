import 'package:flutter/material.dart';

class PickerButton extends StatefulWidget {
  const PickerButton({super.key,
    required this.hasFiles,
    required this.count,
    required this.onTap,
  });
  final bool hasFiles;
  final int count;
  final VoidCallback onTap;

  @override
  State<PickerButton> createState() => _PickerButtonState();
}

class _PickerButtonState extends State<PickerButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFE0F2FE)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? const Color(0xFF0EA5E9)
                  : const Color(0xFFCBD5E1),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 18,
                color: active
                    ? const Color(0xFF0369A1)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 8),
              Text(
                widget.hasFiles
                    ? 'Add more files  (${widget.count} added)'
                    : 'Browse additional files',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? const Color(0xFF0369A1)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}