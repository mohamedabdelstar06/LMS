import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/model.dart';
import '../state_managment/lectures_cubit.dart';
import '../state_managment/lectures_state.dart';
import 'DiaogFieldFunctions.dart';

void showAddEditDialog(
  BuildContext context,
  int courseId,
  LectureCubit cubit, {
  LectureModel? lecture,
}) {
  final isEdit = lecture != null;
  final titleCtrl = TextEditingController(text: lecture?.title ?? '');
  final descCtrl = TextEditingController(text: lecture?.description ?? '');
  String selectedType = lecture?.contentType ?? 'Pdf';
  PlatformFile? selectedFile;
  String? selectedFileName;

  showDialog(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: StatefulBuilder(
        builder: (ctx, setS) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 540,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF175CD3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEdit ? Icons.edit_rounded : Icons.add_rounded,
                          color: const Color(0xFF175CD3),
                          size: 22,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (isEdit)
                              Text(
                                'Lecture ID: ${lecture!.id}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF175CD3),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  DialogField(
                    label: 'Title',
                    controller: titleCtrl,
                    hint: 'Lecture title...',
                  ),
                  const SizedBox(height: 16),

                  DialogField(
                    label: 'Description',
                    controller: descCtrl,
                    hint: 'Brief description...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Content Type',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Pdf', 'Video', 'Audio'].map((type) {
                      final selected = selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setS(() => selectedType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF175CD3)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF175CD3)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  typeIcon(type),
                                  size: 15,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (!isEdit) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Lecture File',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.any,
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          setS(() {
                            selectedFile = result.files.first;
                            selectedFileName = result.files.first.name;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selectedFile != null
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedFile != null
                                ? const Color(0xFF175CD3)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedFile != null
                                  ? Icons.check_circle_rounded
                                  : Icons.upload_file_rounded,
                              color: selectedFile != null
                                  ? const Color(0xFF175CD3)
                                  : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedFileName ?? 'Click to select a file...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: selectedFile != null
                                      ? const Color(0xFF175CD3)
                                      : const Color(0xFF94A3B8),
                                  fontWeight: selectedFile != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (selectedFile != null)
                              GestureDetector(
                                onTap: () => setS(() {
                                  selectedFile = null;
                                  selectedFileName = null;
                                }),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  BlocBuilder<LectureCubit, LectureState>(
                    builder: (ctx2, state) {
                      final isCreateLoading = state is LectureCreateLoading;
                      final isUpdateLoading = state is LectureUpdateLoading;
                      final isLoading = isCreateLoading || isUpdateLoading;

                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final title = titleCtrl.text.trim();
                                      final desc = descCtrl.text.trim();

                                      if (title.isEmpty) {
                                        showSnack(
                                          ctx,
                                          'Please enter a title',
                                          Colors.orange,
                                          Icons.warning_rounded,
                                        );
                                        return;
                                      }

                                      //! editing

                                      if (isEdit)  {
                                        cubit.updateLecture(
                                          lectureId: lecture!.id,
                                          courseId: lecture.courseId,
                                          title: title,
                                          description: desc,
                                        );
                                        unawaited(
                                          context
                                              .read<LectureCubit>()
                                              .fetchLectures(courseId),
                                        );

                                        Navigator.pop(ctx);
                                      } else {
                                        if (selectedFile == null) {
                                          showSnack(
                                            ctx,
                                            'Please select a file',
                                            Colors.orange,
                                            Icons.warning_rounded,
                                          );
                                          return;
                                        }
                                        //! creating
                                        cubit.createLecture(
                                          courseId: courseId,
                                          title: title,
                                          description: desc,
                                          file: selectedFile!,
                                        );
                                        // Navigator.pop(ctx);
                                      }
                                    },
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      isEdit
                                          ? Icons.save_rounded
                                          : Icons.add_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                isLoading
                                    ? (isEdit ? 'Saving...' : 'Creating...')
                                    : (isEdit ? 'Save Changes' : 'Add Lecture'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF175CD3),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade200,
                                disabledForegroundColor: Colors.grey.shade400,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

IconData typeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'video':
      return Icons.videocam_rounded;
    case 'audio':
      return Icons.headphones_rounded;
    default:
      return Icons.picture_as_pdf_rounded;
  }
}

void showSnack(BuildContext ctx, String msg, Color color, IconData icon) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}
