import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/functions/Functions_of_add_lecture/success_view.dart';

import '../../model/model.dart';
import '../../state_managment/lectures_cubit.dart';
import '../../state_managment/lectures_state.dart';
import 'file_config.dart';
import 'form_view.dart';

class AddEditDialog extends StatefulWidget {
  const AddEditDialog({super.key,
    required this.courseId,
    required this.cubit,
    required this.isEdit,
    this.lecture,
  });

  final int courseId;
  final LectureCubit cubit;
  final bool isEdit;
  final LectureModel? lecture;

  @override
  State<AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<AddEditDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _selectedType;

  PlatformFile? _mainFile;
  final List<PlatformFile> _additionalFiles = [];

  late AnimationController _successAnim;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.lecture?.title ?? '');
    _descCtrl = TextEditingController(text: widget.lecture?.description ?? '');
    _selectedType = widget.lecture?.contentType ?? 'Pdf';

    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _successAnim.dispose();
    super.dispose();
  }

  Future<void> _pickMainFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _mainFile = result.files.first);
    }
  }

  Future<void> _pickAdditionalFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null) return;
    setState(() => _additionalFiles.addAll(result.files));
  }

  void _removeAdditional(int i) => setState(() => _additionalFiles.removeAt(i));

  Future<void> _submit(BuildContext ctx) async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (title.isEmpty) {
      snack(ctx, 'Please enter a title', Colors.orange, Icons.warning_rounded);
      return;
    }

    if (widget.isEdit) {
      widget.cubit.updateLecture(
        lectureId: widget.lecture!.id,
        courseId: widget.lecture!.courseId,
        title: title,
        description: desc,
      );
      unawaited(widget.cubit.fetchLectures(widget.courseId));
      if (ctx.mounted) Navigator.pop(ctx);
      return;
    }

    if (_mainFile == null) {
      snack(ctx, 'Please select a lecture file', Colors.orange, Icons.warning_rounded);
      return;
    }

    widget.cubit.createLecture(
      courseId: widget.courseId,
      title: title,
      description: desc,
      file: _mainFile!,
      additionalFiles: _additionalFiles,
    );
  }

  Future<void> _onSuccess() async {
    setState(() => _showSuccess = true);
    await _successAnim.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LectureCubit, LectureState>(
      listener: (ctx, state) {
        if (state is LectureCreateSuccess || state is LectureUpdateSuccess) {
          _onSuccess();
        }
        if (state is LectureCreateError || state is LectureUpdateError) {
          snack(ctx, state is LectureCreateError
              ? state.message
              : (state as LectureUpdateError).message,
              Colors.red, Icons.error_rounded);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _showSuccess
              ? SuccessView(key: const ValueKey('success'), anim: _successAnim)
              : FormView(
            key: const ValueKey('form'),
            isEdit: widget.isEdit,
            lecture: widget.lecture,
            titleCtrl: _titleCtrl,
            descCtrl: _descCtrl,
            selectedType: _selectedType,
            onTypeChange: (t) => setState(() => _selectedType = t),
            mainFile: _mainFile,
            onPickMain: _pickMainFile,
            onClearMain: () => setState(() => _mainFile = null),
            additionalFiles: _additionalFiles,
            onPickAdditional: _pickAdditionalFiles,
            onRemoveAdditional: _removeAdditional,
            onSubmit: () => _submit(context),
          ),
        ),
      ),
    );
  }
}