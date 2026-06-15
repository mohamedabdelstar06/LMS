// ============================================================
// quiz_form_sheet.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

class QuizFormSheet extends StatefulWidget {
  const QuizFormSheet({
    super.key,
    this.existingQuiz,
    required this.courseId,
  });

  final QuizModel? existingQuiz;
  final int courseId;

  @override
  State<QuizFormSheet> createState() => _QuizFormSheetState();
}

class _QuizFormSheetState extends State<QuizFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _passingCtrl;
  bool _isPublished = false;

  bool get _isEditing => widget.existingQuiz != null;

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuiz;
    _titleCtrl = TextEditingController(text: q?.title ?? '');
    _descCtrl = TextEditingController(text: q?.description ?? '');
    _durationCtrl =
        TextEditingController(text: (q?.durationMinutes ?? 30).toString());
    _passingCtrl =
        TextEditingController(text: (q?.passingScore ?? 50).toInt().toString());
    _isPublished = q?.isPublished ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _passingCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'courseId': widget.courseId,
      'durationMinutes': int.tryParse(_durationCtrl.text.trim()) ?? 30,
      'passingScore': double.tryParse(_passingCtrl.text.trim()) ?? 50.0,
      'isPublished': _isPublished,
    };
    Navigator.of(context).pop(data);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isEditing ? Icons.edit_rounded : Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    _isEditing ? 'Edit Quiz' : 'Create New Quiz',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // Form
            Expanded(
              child: SingleChildScrollView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Quiz Title'),
                      _FormField(
                        controller: _titleCtrl,
                        hint: 'e.g. Midterm Exam - Chapter 1-5',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        prefixIcon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel('Description (optional)'),
                      _FormField(
                        controller: _descCtrl,
                        hint: 'Brief description of this quiz...',
                        maxLines: 3,
                        prefixIcon: Icons.notes_rounded,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('Duration (minutes)'),
                                _FormField(
                                  controller: _durationCtrl,
                                  hint: '30',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.timer_outlined,
                                  validator: (v) {
                                    final n = int.tryParse(v ?? '');
                                    if (n == null || n < 1) {
                                      return 'Min 1 minute';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel('Passing Score (%)'),
                                _FormField(
                                  controller: _passingCtrl,
                                  hint: '50',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.verified_outlined,
                                  validator: (v) {
                                    final n = double.tryParse(v ?? '');
                                    if (n == null || n < 0 || n > 100) {
                                      return '0–100';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Publish toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isPublished
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isPublished
                                ? const Color(0xFF10B981).withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isPublished
                                  ? Icons.public_rounded
                                  : Icons.lock_outline_rounded,
                              color: _isPublished
                                  ? const Color(0xFF10B981)
                                  : Colors.grey.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isPublished ? 'Published' : 'Draft',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _isPublished
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                  Text(
                                    _isPublished
                                        ? 'Students can see and take this quiz'
                                        : 'Only visible to instructors',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isPublished,
                              onChanged: (v) =>
                                  setState(() => _isPublished = v),
                              activeColor: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isEditing
                                    ? Icons.save_rounded
                                    : Icons.add_circle_outline_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isEditing ? 'Save Changes' : 'Create Quiz',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: Colors.grey.shade400)
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }
}

// ── Helper function ──────────────────────────────────────────
Future<Map<String, dynamic>?> showQuizFormSheet(
  BuildContext context, {
  QuizModel? existingQuiz,
  required int courseId,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => QuizFormSheet(
      existingQuiz: existingQuiz,
      courseId: courseId,
    ),
  );
}
