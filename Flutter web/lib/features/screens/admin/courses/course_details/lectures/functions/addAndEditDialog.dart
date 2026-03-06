import 'dart:async';
import 'package:file_picker/file_picker.dart';
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

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _AddEditDialog(
        courseId: courseId,
        cubit: cubit,
        lecture: lecture,
        isEdit: isEdit,
      ),
    ),
  );
}

class _AddEditDialog extends StatefulWidget {
  const _AddEditDialog({
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
  State<_AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<_AddEditDialog>
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
      type: FileType.any,
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
      allowedExtensions: _allowedExtensions,
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
      _snack(ctx, 'Please enter a title', Colors.orange, Icons.warning_rounded);
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
      _snack(ctx, 'Please select a lecture file', Colors.orange, Icons.warning_rounded);
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
          _snack(ctx, state is LectureCreateError
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
              ? _SuccessView(key: const ValueKey('success'), anim: _successAnim)
              : _FormView(
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

class _FormView extends StatelessWidget {
  const _FormView({
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
          _Header(isEdit: isEdit, lecture: lecture),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Field(
                    label: 'Title',
                    controller: titleCtrl,
                    hint: 'Enter lecture title...',
                  ),
                  const SizedBox(height: 14),

                  _Field(
                    label: 'Description',
                    controller: descCtrl,
                    hint: 'Brief description...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),

                  _label('Content Type'),
                  const SizedBox(height: 8),
                  _TypeSelector(
                    selected: selectedType,
                    onChange: onTypeChange,
                  ),

                  if (!isEdit) ...[
                    const SizedBox(height: 14),
                    _label('Lecture File'),
                    const SizedBox(height: 8),
                    _MainFilePicker(
                      file: mainFile,
                      onPick: onPickMain,
                      onClear: onClearMain,
                    ),
                    const SizedBox(height: 14),
                    _label('Additional Files  '
                        '(${additionalFiles.length})'),
                    const SizedBox(height: 8),
                    _AdditionalFilesSection(
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

          _Footer(isEdit: isEdit, onSubmit: onSubmit),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isEdit, required this.lecture});
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
                  Text(
                    'ID: ${lecture!.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7C3AED),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.isEdit, required this.onSubmit});
  final bool isEdit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LectureCubit, LectureState>(
      builder: (ctx, state) {
        final isLoading =
            state is LectureCreateLoading || state is LectureUpdateLoading;
        final pct = state is LectureCreateLoading
            ? (state.progress * 100).toInt()
            : null;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading && pct != null) ...[
                _UploadProgressBar(progress: state is LectureCreateLoading
                    ? state.progress : 0),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onSubmit,
                      icon: isLoading
                          ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Icon(
                        isEdit ? Icons.save_rounded : Icons.rocket_launch_rounded,
                        size: 17,
                      ),
                      label: Text(
                        isLoading
                            ? (isEdit ? 'Saving...' : 'Creating...')
                            : (isEdit ? 'Save Changes' : 'Create Lecture'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFCBD5E1),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UploadProgressBar extends StatelessWidget {
  const _UploadProgressBar({required this.progress});
  final double progress;

  String get _label {
    if (progress < 0.3) return 'Preparing...';
    if (progress < 0.7) return 'Uploading files...';
    if (progress < 0.95) return 'Finalizing...';
    return 'Almost done...';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: const Color(0xFF0284C7).withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF0284C7)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({super.key, required this.anim});
  final AnimationController anim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF34D399)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: anim,
              curve: const Interval(0.4, 1.0),
            ),
            child: const Column(
              children: [
                Text(
                  'Lecture Created!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your lecture and files have been\nuploaded successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChange});
  final String selected;
  final ValueChanged<String> onChange;

  static const _types = ['Pdf', 'Video', 'Audio', 'Image'];

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
                  _typeIconFor(t),
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

class _MainFilePicker extends StatelessWidget {
  const _MainFilePicker({
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
                      _sizeLabel(file!.size),
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

class _AdditionalFilesSection extends StatelessWidget {
  const _AdditionalFilesSection({
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
        _PickerButton(
          hasFiles: files.isNotEmpty,
          count: files.length,
          onTap: onPick,
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...files.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _AdditionalFileRow(
              file: e.value,
              onRemove: () => onRemove(e.key),
            ),
          )),
        ],
      ],
    );
  }
}

class _PickerButton extends StatefulWidget {
  const _PickerButton({
    required this.hasFiles,
    required this.count,
    required this.onTap,
  });
  final bool hasFiles;
  final int count;
  final VoidCallback onTap;

  @override
  State<_PickerButton> createState() => _PickerButtonState();
}

class _PickerButtonState extends State<_PickerButton> {
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

class _AdditionalFileRow extends StatelessWidget {
  const _AdditionalFileRow({required this.file, required this.onRemove});
  final PlatformFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ext = (file.extension ?? '').toLowerCase();
    final cat = _categoryFromExt(ext);
    final cfg = _catMap[cat]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cfg.bg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(cfg.icon, color: cfg.color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${cfg.label}  ·  ${_sizeLabel(file.size)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: cfg.color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 13,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _label(String text) => Text(
  text,
  style: TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.blue.shade900,
  ),
);

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF0284C7), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

String _sizeLabel(int size) {
  if (size < 1024) return '$size B';
  if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
  return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
}

IconData _typeIconFor(String type) {
  switch (type.toLowerCase()) {
    case 'video':
      return Icons.videocam_rounded;
    case 'audio':
      return Icons.headphones_rounded;
    case 'image':
      return Icons.image_rounded;
    default:
      return Icons.picture_as_pdf_rounded;
  }
}

void _snack(BuildContext ctx, String msg, Color color, IconData icon) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(fontWeight: FontWeight.w600)),
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

enum FileCategory {
  video, audio, pdf, excel, word, powerpoint, image, text, archive, other,
}

class _CatConfig {
  const _CatConfig(this.icon, this.color, this.bg, this.label);
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
}

const _catMap = <FileCategory, _CatConfig>{
  FileCategory.video:      _CatConfig(Icons.videocam_rounded,         Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Video'),
  FileCategory.audio:      _CatConfig(Icons.audiotrack_rounded,       Color(0xFFDB2777), Color(0xFFFCE7F3), 'Audio'),
  FileCategory.pdf:        _CatConfig(Icons.picture_as_pdf_rounded,   Color(0xFFDC2626), Color(0xFFFEE2E2), 'PDF'),
  FileCategory.excel:      _CatConfig(Icons.table_chart_rounded,      Color(0xFF059669), Color(0xFFD1FAE5), 'Excel'),
  FileCategory.word:       _CatConfig(Icons.description_rounded,      Color(0xFF1D4ED8), Color(0xFFDBEAFE), 'Word'),
  FileCategory.powerpoint: _CatConfig(Icons.slideshow_rounded,        Color(0xFFEA580C), Color(0xFFFFEDD5), 'PowerPoint'),
  FileCategory.image:      _CatConfig(Icons.image_rounded,            Color(0xFF0891B2), Color(0xFFCFFAFE), 'Image'),
  FileCategory.text:       _CatConfig(Icons.text_snippet_rounded,     Color(0xFF64748B), Color(0xFFF1F5F9), 'Text'),
  FileCategory.archive:    _CatConfig(Icons.folder_zip_rounded,       Color(0xFFD97706), Color(0xFFFEF3C7), 'Archive'),
  FileCategory.other:      _CatConfig(Icons.insert_drive_file_rounded, Color(0xFF64748B), Color(0xFFF1F5F9), 'File'),
};

FileCategory _categoryFromExt(String ext) {
  const map = {
    'mp4': FileCategory.video, 'mov': FileCategory.video,
    'avi': FileCategory.video, 'mkv': FileCategory.video,
    'webm': FileCategory.video,
    'mp3': FileCategory.audio, 'wav': FileCategory.audio,
    'aac': FileCategory.audio, 'm4a': FileCategory.audio,
    'pdf': FileCategory.pdf,
    'xls': FileCategory.excel, 'xlsx': FileCategory.excel,
    'csv': FileCategory.excel,
    'doc': FileCategory.word, 'docx': FileCategory.word,
    'ppt': FileCategory.powerpoint, 'pptx': FileCategory.powerpoint,
    'jpg': FileCategory.image, 'jpeg': FileCategory.image,
    'png': FileCategory.image, 'gif': FileCategory.image,
    'webp': FileCategory.image, 'svg': FileCategory.image,
    'txt': FileCategory.text, 'md': FileCategory.text,
    'zip': FileCategory.archive, 'rar': FileCategory.archive,
    '7z': FileCategory.archive, 'tar': FileCategory.archive,
    'gz': FileCategory.archive,
  };
  return map[ext] ?? FileCategory.other;
}

const _allowedExtensions = [
  'mp4', 'mov', 'avi', 'mkv', 'webm',
  'mp3', 'wav', 'aac', 'm4a',
  'pdf', 'xls', 'xlsx', 'csv',
  'doc', 'docx', 'ppt', 'pptx',
  'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg',
  'txt', 'md', 'zip', 'rar', '7z', 'tar', 'gz',
];