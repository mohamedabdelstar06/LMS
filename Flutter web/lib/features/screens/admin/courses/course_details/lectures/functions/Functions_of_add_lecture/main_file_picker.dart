import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'file_config.dart';

class MainFilePicker extends StatelessWidget {
  const MainFilePicker({super.key, 
    required this.file,
    required this.onPick,
    required this.onClear,
  });
  final PlatformFile? file;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final picked = file != null;
    return GestureDetector(
      onTap: onPick,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: picked ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: picked
                ? const Color(0xFF0284C7)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: picked
                    ? const Color(0xFF0284C7).withOpacity(0.12)
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                picked
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                color: picked
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF94A3B8),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    picked ? file!.name : 'Click to select lecture file',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      picked ? FontWeight.w600 : FontWeight.normal,
                      color: picked
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF94A3B8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (picked)
                    Text(
                      sizeLabel(file!.size),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
            if (picked)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: Color(0xFF94A3B8)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
