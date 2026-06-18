import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignmnet_repo.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/file_progress.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/state_mangmnet/assignments_cubit.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/state_mangmnet/assignments_state.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/model/view.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/state_mangment/cubit.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/state_mangment/states.dart';



// ─────────────────────────────────────────────────────────────

class AssignmentFormSheet extends StatefulWidget {
  final AssignmentModel? existing;
  const AssignmentFormSheet({super.key, this.existing});

  @override
  State<AssignmentFormSheet> createState() => _AssignmentFormSheetState();
}

class _AssignmentFormSheetState extends State<AssignmentFormSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _instructionCtrl;
  late final TextEditingController _maxGradeCtrl;

  // Date pickers
  DateTime? _startDate;
  DateTime? _deadlineDate;

  // Toggles
  bool _allowLate = false;
  bool _isVisible = true;

  // Squadron
  SquadronModel? _selectedSquadron;

  // Files
  List<PickedFileData> _pickedFiles = [];

  bool get isEditing => widget.existing != null;

  // Section expand state for cleaner UX
  bool _basicExpanded = true;
  bool _scheduleExpanded = true;
  bool _settingsExpanded = true;
  bool _filesExpanded = true;

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
    _startDate = e?.startDate;
    _deadlineDate = e?.deadlineDate;

    // Fetch squadrons when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SquadronsCubitDrop>().fetchSquadrons();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _instructionCtrl.dispose();
    _maxGradeCtrl.dispose();
    super.dispose();
  }

  // ── File picker ─────────────────────────────────────────────

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final loaded = result.files
          .map(PickedFileData.fromPlatformFile)
          .whereType<PickedFileData>()
          .toList();

      if (loaded.isEmpty) {
        _snack(
          'Could not read selected files. Please try again.',
          isError: true,
        );
        return;
      }
      setState(() {
        final existing = _pickedFiles.map((f) => f.name).toSet();
        _pickedFiles.addAll(loaded.where((f) => !existing.contains(f.name)));
      });
    } catch (e) {
      _snack('File picker error: $e', isError: true);
    }
  }

  void _removeFile(int i) => setState(() => _pickedFiles.removeAt(i));

  // ── Date picker ─────────────────────────────────────────────

  Future<DateTime?> _pickDate({DateTime? initial}) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2563EB),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
  }

  // ── Submit ──────────────────────────────────────────────────

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;

    // Date cross-validation
    if (_startDate != null &&
        _deadlineDate != null &&
        _deadlineDate!.isBefore(_startDate!)) {
      _snack('Deadline must be after start date', isError: true);
      return;
    }

    final cubit = ctx.read<AssignmentCubit>();

    if (isEditing) {
      cubit.updateAssignment(
        assignmentId: widget.existing!.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        instructions: _instructionCtrl.text.trim(),
        maxGrade: int.tryParse(_maxGradeCtrl.text) ?? 100,
        allowLateSubmission: _allowLate,
        isVisible: _isVisible,
        targetSquadronId: _selectedSquadron?.id,
        startDate: _startDate,
        deadlineDate: _deadlineDate,
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
        targetSquadronId: _selectedSquadron?.id,
        startDate: _startDate,
        deadlineDate: _deadlineDate,
        files: _pickedFiles,
      );
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 13)),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SquadronsCubitDrop>(
      create: (_) => SquadronsCubitDrop()..fetchSquadrons(),
      child: BlocListener<AssignmentCubit, AssignmentState>(
        listener: (ctx, state) {
          if (state.actionStatus == AssignmentActionStatus.success) {
            Navigator.of(ctx).pop();
          }
          if (state.actionStatus == AssignmentActionStatus.failure &&
              state.actionError != null) {
            _snack(state.actionError!, isError: true);
          }
        },
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.97,
          builder: (_, sc) => _SheetScaffold(
            scrollController: sc,
            header: _buildHeader(),
            submitBar: _buildSubmitBar(context),
            child: _buildBody(sc),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEF2F8), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEditing
                    ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]
                    : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.assignment_add,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Assignment' : 'New Assignment',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  isEditing
                      ? 'Update assignment details'
                      : 'Fill in the details below',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────

  Widget _buildBody(ScrollController sc) {
    return BlocBuilder<AssignmentCubit, AssignmentState>(
      builder: (ctx, state) {
        final uploading = state.isUploadingFiles;
        return Form(
          key: _formKey,
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // ── Section 1: Basic Info ──────────────────────
              _Section(
                icon: Icons.info_outline_rounded,
                title: 'Basic Information',
                color: const Color(0xFF2563EB),
                expanded: _basicExpanded,
                onToggle: () =>
                    setState(() => _basicExpanded = !_basicExpanded),
                children: [
                  _field(
                    controller: _titleCtrl,
                    label: 'Title *',
                    hint: 'e.g. Module 4 Assignment',
                    icon: Icons.title_rounded,
                    enabled: !uploading,
                    validator: (v) =>
                        v?.trim().isEmpty == true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _descCtrl,
                    label: 'Description',
                    hint: 'Brief description shown to students',
                    icon: Icons.subject_rounded,
                    maxLines: 3,
                    enabled: !uploading,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _instructionCtrl,
                    label: 'Instructions',
                    hint: 'Detailed step-by-step instructions',
                    icon: Icons.format_list_bulleted_rounded,
                    maxLines: 4,
                    enabled: !uploading,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _maxGradeCtrl,
                    label: 'Max Grade *',
                    hint: '100',
                    icon: Icons.grade_rounded,
                    keyboardType: TextInputType.number,
                    enabled: !uploading,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0)
                        return 'Enter a valid number > 0';
                      if (n > 1000) return 'Max grade cannot exceed 1000';
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 2: Schedule ────────────────────────
              _Section(
                icon: Icons.calendar_month_rounded,
                title: 'Schedule',
                color: const Color(0xFF059669),
                expanded: _scheduleExpanded,
                onToggle: () =>
                    setState(() => _scheduleExpanded = !_scheduleExpanded),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Start Date *',
                          icon: Icons.play_circle_outline_rounded,
                          value: _startDate,
                          enabled: !uploading,
                          onTap: () async {
                            final d = await _pickDate(initial: _startDate);
                            if (d != null) setState(() => _startDate = d);
                          },
                          validator: (_) =>
                              _startDate == null ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'Deadline *',
                          icon: Icons.flag_rounded,
                          value: _deadlineDate,
                          enabled: !uploading,
                          isDeadline: true,
                          onTap: () async {
                            final d = await _pickDate(initial: _deadlineDate);
                            if (d != null) setState(() => _deadlineDate = d);
                          },
                          validator: (_) {
                            if (_deadlineDate == null) return 'Required';
                            if (_startDate != null &&
                                _deadlineDate!.isBefore(_startDate!)) {
                              return 'Must be after start';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  // Visual duration indicator
                  if (_startDate != null &&
                      _deadlineDate != null &&
                      !_deadlineDate!.isBefore(_startDate!)) ...[
                    const SizedBox(height: 10),
                    _DurationChip(start: _startDate!, end: _deadlineDate!),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 3: Settings ────────────────────────
              _Section(
                icon: Icons.tune_rounded,
                title: 'Settings',
                color: const Color(0xFF7C3AED),
                expanded: _settingsExpanded,
                onToggle: () =>
                    setState(() => _settingsExpanded = !_settingsExpanded),
                children: [
                  // Squadron dropdown
                  _SquadronDropdown(
                    selected: _selectedSquadron,
                    enabled: !uploading,
                    onChanged: (s) => setState(() => _selectedSquadron = s),
                  ),

                  const SizedBox(height: 14),

                  // Visibility toggle — redesigned as segmented-style
                  _VisibilityToggle(
                    isVisible: _isVisible,
                    enabled: !uploading,
                    onChanged: (v) => setState(() => _isVisible = v),
                  ),

                  const SizedBox(height: 14),

                  // Late submission toggle
                  _ToggleTile(
                    title: 'Allow Late Submission',
                    subtitle: 'Students can submit after the deadline',
                    icon: Icons.schedule_rounded,
                    value: _allowLate,
                    enabled: !uploading,
                    activeColor: const Color(0xFFF59E0B),
                    activeBg: const Color(0xFFFEF3C7),
                    activeBorder: const Color(0xFFFCD34D),
                    onChanged: (v) => setState(() => _allowLate = v),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 4: Files ───────────────────────────
              _Section(
                icon: Icons.attach_file_rounded,
                title: 'Attachments',
                color: const Color(0xFFEA580C),
                badge: _pickedFiles.isNotEmpty
                    ? '${_pickedFiles.length}'
                    : null,
                expanded: _filesExpanded,
                onToggle: () =>
                    setState(() => _filesExpanded = !_filesExpanded),
                children: [
                  if (!uploading) ...[
                    _FileDropZone(onTap: _pickFiles),
                    if (_pickedFiles.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ..._pickedFiles.asMap().entries.map(
                        (e) => _PickedFileTile(
                          file: e.value,
                          onRemove: () => _removeFile(e.key),
                        ),
                      ),
                    ],
                  ],

                  // Upload progress
                  if (state.uploadProgresses.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    FileUploadProgressList(progresses: state.uploadProgresses),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Submit bar ──────────────────────────────────────────────

  Widget _buildSubmitBar(BuildContext ctx) {
    return BlocBuilder<AssignmentCubit, AssignmentState>(
      builder: (ctx, state) {
        final loading = state.actionStatus == AssignmentActionStatus.loading;
        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.of(ctx).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: Color(0xFFEEF2F8))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Cancel
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Submit
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: loading ? null : () => _submit(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditing
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF2563EB),
                    disabledBackgroundColor: const Color(
                      0xFF2563EB,
                    ).withOpacity(0.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEditing
                                  ? Icons.save_rounded
                                  : Icons.add_circle_outline_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Save Changes' : 'Create Assignment',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Field builder ────────────────────────────────────────────

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          decoration: _inputDeco(hint, icon, enabled),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon, bool enabled) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      );
}

// ════════════════════════════════════════════════════════════
// Sub-widgets
// ════════════════════════════════════════════════════════════

class _SheetScaffold extends StatelessWidget {
  final ScrollController scrollController;
  final Widget header;
  final Widget child;
  final Widget submitBar;

  const _SheetScaffold({
    required this.scrollController,
    required this.header,
    required this.child,
    required this.submitBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 2),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          header,
          Expanded(child: child),
          submitBar,
        ],
      ),
    );
  }
}

// ── Collapsible section card ─────────────────────────────────

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;
  final String? badge;

  const _Section({
    required this.icon,
    required this.title,
    required this.color,
    required this.expanded,
    required this.onToggle,
    required this.children,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: expanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Field label ──────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF475569),
        letterSpacing: 0.1,
      ),
    );
  }
}

// ── Date field ───────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final bool enabled;
  final bool isDeadline;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const _DateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.enabled,
    required this.onTap,
    this.isDeadline = false,
    this.validator,
  });

  String get _display {
    if (value == null) return 'Select date';
    return '${value!.day}/${value!.month}/${value!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = isDeadline
        ? const Color(0xFFEF4444)
        : const Color(0xFF059669);
    final hasValue = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        FormField<String>(
          validator: validator,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: enabled ? onTap : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: hasValue
                        ? color.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: field.hasError
                          ? const Color(0xFFEF4444)
                          : hasValue
                          ? color.withOpacity(0.4)
                          : const Color(0xFFE2E8F0),
                      width: field.hasError || hasValue ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: hasValue ? color : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _display,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasValue
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFCBD5E1),
                            fontWeight: hasValue
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasValue)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: color,
                        ),
                    ],
                  ),
                ),
              ),
              if (field.hasError) ...[
                const SizedBox(height: 4),
                Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Duration chip ────────────────────────────────────────────

class _DurationChip extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  const _DurationChip({required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final days = end.difference(start).inDays;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timelapse_rounded,
            size: 14,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 6),
          Text(
            'Duration: $days day${days == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Squadron dropdown ────────────────────────────────────────

class _SquadronDropdown extends StatelessWidget {
  final SquadronModel? selected;
  final bool enabled;
  final ValueChanged<SquadronModel?> onChanged;

  const _SquadronDropdown({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Target Squadron'),
        const SizedBox(height: 6),
        BlocBuilder<SquadronsCubitDrop, GetSquadronsState>(
          builder: (ctx, state) {
            if (state is GetSquadronsLoading) {
              return _DropShimmer();
            }
            if (state is GetSquadronsError) {
              return _DropError(message: state.message);
            }

            final squadrons = state is GetSquadronsLoaded
                ? state.squadrons
                : <SquadronModel>[];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected != null
                      ? const Color(0xFF7C3AED).withOpacity(0.4)
                      : const Color(0xFFE2E8F0),
                  width: selected != null ? 1.5 : 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SquadronModel?>(
                  value: selected,
                  isExpanded: true,
                  hint: const Text(
                    'All squadrons (optional)',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: selected != null
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onChanged: enabled ? onChanged : null,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    // "All squadrons" option
                    DropdownMenuItem<SquadronModel?>(
                      value: null,
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'All Squadrons',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...squadrons.map(
                      (s) => DropdownMenuItem<SquadronModel?>(
                        value: s,
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE9FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  s.name.isNotEmpty
                                      ? s.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${s.studentCount} students',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Selected squadron info chip
        if (selected != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Color(0xFF7C3AED),
                ),
                const SizedBox(width: 6),
                Text(
                  'ID ${selected!.id} · ${selected!.studentCount} students',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DropShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF7C3AED),
          ),
        ),
      ),
    );
  }
}

class _DropError extends StatelessWidget {
  final String message;
  const _DropError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: Color(0xFFEF4444)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load squadrons: $message',
              style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Visibility toggle (segmented style) ─────────────────────

class _VisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _VisibilityToggle({
    required this.isVisible,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Visibility'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              _VisOption(
                icon: Icons.visibility_rounded,
                label: 'Visible',
                sublabel: 'Students can see it',
                selected: isVisible,
                color: const Color(0xFF059669),
                onTap: enabled ? () => onChanged(true) : null,
                isFirst: true,
              ),
              _VisOption(
                icon: Icons.visibility_off_rounded,
                label: 'Hidden',
                sublabel: 'Draft — not shown',
                selected: !isVisible,
                color: const Color(0xFF64748B),
                onTap: enabled ? () => onChanged(false) : null,
                isFirst: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VisOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;
  final bool isFirst;

  const _VisOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.color,
    required this.onTap,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.all(selected ? 3 : 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: color.withOpacity(0.3)) : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? color : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? color : const Color(0xFF94A3B8),
                      ),
                    ),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Generic toggle tile ──────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final bool enabled;
  final Color activeColor;
  final Color activeBg;
  final Color activeBorder;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.enabled,
    required this.activeColor,
    required this.activeBg,
    required this.activeBorder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? activeBg : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? activeBorder : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: value ? activeColor : const Color(0xFF94A3B8),
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
                      color: value ? activeColor : const Color(0xFF374151),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: activeColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── File drop zone ───────────────────────────────────────────

class _FileDropZone extends StatelessWidget {
  final VoidCallback onTap;
  const _FileDropZone({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFED7AA),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEA580C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFFEA580C),
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap to attach files',
              style: TextStyle(
                color: Color(0xFFEA580C),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PDF · DOCX · PPTX · Images · ZIP',
              style: TextStyle(color: Color(0xFFD97706), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Picked file tile ─────────────────────────────────────────

class _PickedFileTile extends StatelessWidget {
  final PickedFileData file;
  final VoidCallback onRemove;
  const _PickedFileTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0ECFF)),
      ),
      child: Row(
        children: [
          Text(file.icon, style: const TextStyle(fontSize: 20)),
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
                    color: Color(0xFF374151),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  file.sizeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
