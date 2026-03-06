import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/functions/Functions_of_add_lecture/picker_button.dart';

import 'additonal_file_row.dart';

class AdditionalFilesSection extends StatelessWidget {
  const AdditionalFilesSection({super.key,
    required this.files,
    required this.onPick,
    required this.onRemove,
  });
  final List<PlatformFile> files;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PickerButton(
          hasFiles: files.isNotEmpty,
          count: files.length,
          onTap: onPick,
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...files.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AdditionalFileRow(
              file: e.value,
              onRemove: () => onRemove(e.key),
            ),
          )),
        ],
      ],
    );
  }
}
