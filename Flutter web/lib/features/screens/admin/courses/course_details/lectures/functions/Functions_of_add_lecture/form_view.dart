import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/functions/Functions_of_add_lecture/file_config.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/functions/Functions_of_add_lecture/type_selector.dart';

import '../../model/model.dart';
import 'additional_file_section.dart';
import 'field.dart';
import 'footer.dart';
import 'header.dart';
import 'main_file_picker.dart';

class FormView extends StatelessWidget {
  const FormView({
    super.key,
    required this.isEdit,
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

  final bool isEdit;
  final LectureModel? lecture;
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
  Widget build(BuildContext context) {
    return Container(
      width: 560,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Header(isEdit: isEdit, lecture: lecture),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Field(
                    label: 'Title',
                    controller: titleCtrl,
                    hint: 'Enter lecture title...',
                  ),
                  const SizedBox(height: 14),

                  Field(
                    label: 'Description',
                    controller: descCtrl,
                    hint: 'Brief description...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),

                  labelField('Content Type'),
                  const SizedBox(height: 8),
                  TypeSelector(
                    selected: selectedType,
                    onChange: onTypeChange,
                  ),

                  if (!isEdit) ...[
                    const SizedBox(height: 14),
                    labelField('Lecture File'),
                    const SizedBox(height: 8),
                    MainFilePicker(
                      file: mainFile,
                      onPick: onPickMain,
                      onClear: onClearMain,
                    ),
                    const SizedBox(height: 14),
                    labelField('Additional Files  '
                        '(${additionalFiles.length})'),
                    const SizedBox(height: 8),
                    AdditionalFilesSection(
                      files: additionalFiles,
                      onPick: onPickAdditional,
                      onRemove: onRemoveAdditional,
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Footer(isEdit: isEdit, onSubmit: onSubmit),
        ],
      ),
    );
  }
}
