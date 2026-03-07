import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/functions/Functions_of_add_lecture/type_selector.dart';

import '../../model/model.dart';

import 'additional_file_section.dart';
import 'field.dart';
import 'file_config.dart';
import 'footer.dart';
import 'header.dart';
import 'main_file_picker.dart';

class EditFormView extends StatefulWidget {
  const EditFormView({
    super.key,
    required this.lecture,
    required this.titleCtrl,
    required this.descCtrl,
    required this.selectedType,
    required this.onTypeChange,
    required this.mainFile,
    required this.onPickMain,
    required this.onClearMain,
    required this.additionalFiles,
    required this.onPickAdditional,
    required this.onRemoveAdditional,
    required this.onSubmit,
  });

  final LectureModel lecture;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final String selectedType;
  final ValueChanged<String> onTypeChange;
  final PlatformFile? mainFile;
  final VoidCallback onPickMain;
  final VoidCallback onClearMain;
  final List<PlatformFile> additionalFiles;
  final VoidCallback onPickAdditional;
  final ValueChanged<int> onRemoveAdditional;
  final VoidCallback onSubmit;

  @override
  State<EditFormView> createState() => _EditFormViewState();
}

class _EditFormViewState extends State<EditFormView> {
  bool _replaceMain = false;
  final Set<int> _replacedAdditional = {};

  String _fileName(String url) => url.split('/').last;

  @override
  Widget build(BuildContext context) {
    final existingAdditionals = widget.lecture.additionalFileUrls ?? [];

    return Container(
      width: 560,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Header(isEdit: true, lecture: widget.lecture),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Field(
                    label: 'Title',
                    controller: widget.titleCtrl,
                    hint: 'Enter lecture title...',
                  ),
                  const SizedBox(height: 14),

                  Field(
                    label: 'Description',
                    controller: widget.descCtrl,
                    hint: 'Brief description...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),

                  labelField('Content Type'),
                  const SizedBox(height: 8),
                  TypeSelector(
                    selected: widget.selectedType,
                    onChange: widget.onTypeChange,
                  ),
                  const SizedBox(height: 14),

                  labelField('Lecture File'),
                  const SizedBox(height: 8),

                  if (!_replaceMain) ...[
                    _ExistingFileCard(
                      name: _fileName(widget.lecture.fileUrl),
                      onReplace: () => setState(() => _replaceMain = true),
                    ),
                  ] else ...[
                    MainFilePicker(
                      file: widget.mainFile,
                      onPick: widget.onPickMain,
                      onClear: () {
                        widget.onClearMain();
                        setState(() => _replaceMain = false);
                      },
                    ),
                  ],

                  const SizedBox(height: 14),

                  labelField(
                    'Additional Files  (${existingAdditionals.length - _replacedAdditional.length + widget.additionalFiles.length})',
                  ),
                  const SizedBox(height: 8),

                  ...List.generate(existingAdditionals.length, (i) {
                    if (_replacedAdditional.contains(i)) {
                      final newIndex = _replacedAdditional
                          .toList()
                          .indexOf(i);
                      final hasNewFile = newIndex < widget.additionalFiles.length;
                      return _ReplacingFileCard(
                        oldName: _fileName(existingAdditionals[i]),
                        newFile: hasNewFile ? widget.additionalFiles[newIndex] : null,
                        onPickNew: widget.onPickAdditional,
                        onCancel: () {
                          setState(() => _replacedAdditional.remove(i));
                          if (hasNewFile) widget.onRemoveAdditional(newIndex);
                        },
                      );
                    }
                    return _ExistingFileCard(
                      name: _fileName(existingAdditionals[i]),
                      onReplace: () => setState(() => _replacedAdditional.add(i)),
                      margin: const EdgeInsets.only(bottom: 8),
                    );
                  }),

                  if (widget.additionalFiles.length > _replacedAdditional.length) ...[
                    const SizedBox(height: 4),
                    AdditionalFilesSection(
                      files: widget.additionalFiles
                          .skip(_replacedAdditional.length)
                          .toList(),
                      onPick: widget.onPickAdditional,
                      onRemove: (i) => widget.onRemoveAdditional(
                        i + _replacedAdditional.length,
                      ),
                    ),
                  ] else ...[
                    AdditionalFilesSection(
                      files: const [],
                      onPick: widget.onPickAdditional,
                      onRemove: widget.onRemoveAdditional,
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Footer(isEdit: true, onSubmit: widget.onSubmit),
        ],
      ),
    );
  }
}

class _ExistingFileCard extends StatelessWidget {
  const _ExistingFileCard({
    required this.name,
    required this.onReplace,
    this.margin,
  });

  final String name;
  final VoidCallback onReplace;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4361EE).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_rounded,
              color: Color(0xFF4361EE), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onReplace,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Replace',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4361EE),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplacingFileCard extends StatelessWidget {
  const _ReplacingFileCard({
    required this.oldName,
    required this.newFile,
    required this.onPickNew,
    required this.onCancel,
  });

  final String oldName;
  final PlatformFile? newFile;
  final VoidCallback onPickNew;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded,
                  color: Colors.orange, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Replacing: $oldName',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onCancel,
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (newFile == null)
            GestureDetector(
              onTap: onPickNew,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_rounded, color: Colors.orange, size: 16),
                    SizedBox(width: 6),
                    Text('Select new file',
                        style: TextStyle(fontSize: 12, color: Colors.orange)),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    newFile!.name,
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}