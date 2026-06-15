import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/file_progress.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/state_mangmnet/assignments_cubit.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/state_mangmnet/assignments_state.dart';


class AssignmentFormSheet extends StatefulWidget {
  final AssignmentModel? existing; // null = create mode

  const AssignmentFormSheet({super.key, this.existing});

  @override
  State<AssignmentFormSheet> createState() => _AssignmentFormSheetState();
}

class _AssignmentFormSheetState extends State<AssignmentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _instructionCtrl;
  late final TextEditingController _maxGradeCtrl;
  bool _allowLate = false;
  bool _isVisible = true;
  List<File> _pickedFiles = [];

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _instructionCtrl = TextEditingController(text: e?.instructions ?? '');
    _maxGradeCtrl = TextEditingController(
      text: e?.maxGrade.toString() ?? '100',
    );
    _allowLate = e?.allowLateSubmission ?? false;
    _isVisible = e?.isVisible ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _instructionCtrl.dispose();
    _maxGradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        _pickedFiles.addAll(
          result.paths.whereType<String>().map((p) => File(p)),
        );
      });
    }
  }

  void _removeFile(int index) {
    setState(() => _pickedFiles.removeAt(index));
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AssignmentCubit>();
    if (isEditing) {
      cubit.updateAssignment(
        assignmentId: widget.existing!.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        instructions: _instructionCtrl.text.trim(),
        maxGrade: int.tryParse(_maxGradeCtrl.text) ?? 100,
        allowLateSubmission: _allowLate,
        isVisible: _isVisible,
        newFiles: _pickedFiles,
      );
    } else {
      cubit.createAssignment(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        instructions: _instructionCtrl.text.trim(),
        maxGrade: int.tryParse(_maxGradeCtrl.text) ?? 100,
        allowLateSubmission: _allowLate,
        isVisible: _isVisible,
        files: _pickedFiles,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignmentCubit, AssignmentState>(
      listener: (context, state) {
        if (state.actionStatus == AssignmentActionStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit_rounded : Icons.assignment_add,
                        color: const Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Assignment' : 'New Assignment',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    children: [
                      _buildField(
                        controller: _titleCtrl,
                        label: 'Title',
                        hint: 'e.g. Module 4 Assignment',
                        icon: Icons.title_rounded,
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _descCtrl,
                        label: 'Description',
                        hint: 'Brief description of the assignment',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _instructionCtrl,
                        label: 'Instructions',
                        hint: 'Detailed instructions for students',
                        icon: Icons.format_list_bulleted_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _maxGradeCtrl,
                        label: 'Max Grade',
                        hint: '100',
                        icon: Icons.grade_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Enter a valid grade';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Toggles
                      _buildToggleTile(
                        title: 'Allow Late Submission',
                        subtitle: 'Students can submit after the deadline',
                        icon: Icons.schedule_rounded,
                        value: _allowLate,
                        onChanged: (v) => setState(() => _allowLate = v),
                      ),
                      const SizedBox(height: 8),
                      _buildToggleTile(
                        title: 'Visible to Students',
                        subtitle: 'Students can see this assignment',
                        icon: Icons.visibility_rounded,
                        value: _isVisible,
                        onChanged: (v) => setState(() => _isVisible = v),
                      ),
                      const SizedBox(height: 20),

                      // File picker
                      _buildFilePicker(),

                      // Upload progress
                      BlocBuilder<AssignmentCubit, AssignmentState>(
                        builder: (context, state) => FileUploadProgressList(
                          progresses: state.uploadProgresses,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom submit button
              _buildSubmitBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: value ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? const Color(0xFFBFDBFE) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: value
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF374151),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFiles,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF93C5FD),
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF3B82F6),
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to upload files',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'PDF, DOCX, PPTX, images, ZIP supported',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        if (_pickedFiles.isNotEmpty) ...[
          const SizedBox(height: 10),
          ..._pickedFiles.asMap().entries.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0ECFF)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.value.path.split('/').last,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF374151),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeFile(e.key),
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitBar(BuildContext context) {
    return BlocBuilder<AssignmentCubit, AssignmentState>(
      builder: (context, state) {
        final loading = state.actionStatus == AssignmentActionStatus.loading;
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: loading ? null : () => _submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                disabledBackgroundColor: const Color(
                  0xFF3B82F6,
                ).withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isEditing ? 'Save Changes' : 'Create Assignment',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
