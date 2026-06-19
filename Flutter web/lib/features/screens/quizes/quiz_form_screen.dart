// ============================================================
// quiz_form_screen.dart — full-page Create/Edit Quiz with
// inline question + options builder
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/model/view.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/state_mangment/cubit.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/state_mangment/states.dart';
import 'package:lms/features/screens/quizes/question_builder_card.dart';
import 'package:lms/features/screens/quizes/quiz_cubit.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';
import 'package:lms/features/screens/quizes/quiz_state.dart';

class QuizFormScreen extends StatefulWidget {
  const QuizFormScreen({
    super.key,
    this.existingQuizId,
    required this.courseId,
  });

  /// Pass null to create a new quiz; pass an id to edit an existing one.
  final int? existingQuizId;
  final int courseId;

  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _timeLimitCtrl;
  late TextEditingController _maxAttemptsCtrl;
  late TextEditingController _passingScoreCtrl;

  int? _selectedSquadronId;

  bool _shuffleQuestions = false;
  bool _shuffleAnswers = false;
  bool _showCorrectAnswers = true;
  bool _showExplanations = true;
  bool _isVisible = true;
  String _gradingMode = 'Auto';
  String? _difficultyLevel;
  DateTime? _startDate;
  DateTime? _deadlineDate;

  List<QuestionInput> _questions = [QuestionInput()];
  bool _loadingExisting = false;

  bool get _isEditing => widget.existingQuizId != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _timeLimitCtrl = TextEditingController(text: '30');
    _maxAttemptsCtrl = TextEditingController(text: '1');
    _passingScoreCtrl = TextEditingController(text: '50');

    if (_isEditing) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    setState(() => _loadingExisting = true);
    final detail = await context.read<QuizCubit>().loadQuizDetail(
      widget.existingQuizId!,
    );
    if (detail == null || !mounted) {
      setState(() => _loadingExisting = false);
      return;
    }
    final q = detail.quiz;
    setState(() {
      _titleCtrl.text = q.title;
      _descCtrl.text = q.description;
      _timeLimitCtrl.text = (q.timeLimitMinutes ?? 30).toString();
      _maxAttemptsCtrl.text = q.maxAttempts.toString();
      _passingScoreCtrl.text = q.passingScore.toInt().toString();
      _selectedSquadronId = q.targetSquadronId;
      _shuffleQuestions = q.shuffleQuestions;
      _shuffleAnswers = q.shuffleAnswers;
      _showCorrectAnswers = q.showCorrectAnswers;
      _showExplanations = q.showExplanations;
      _isVisible = q.isVisible;
      _gradingMode = q.gradingMode;
      _difficultyLevel = q.difficultyLevel;
      _startDate = q.startDate;
      _deadlineDate = q.deadLineDate;

      if (detail.questions.isNotEmpty) {
        _questions = detail.questions
            .map(
              (qd) => QuestionInput(
                questionText: qd.questionText,
                questionType: qd.questionType,
                marks: qd.marks,
                difficultyLevel: qd.difficultyLevel ?? 'Medium',
                explanation: qd.explanation ?? '',
                sourceReference: qd.sourceReference ?? '',
                sortOrder: qd.sortOrder,
                options: qd.options
                    .map(
                      (o) => QuestionOptionInput(
                        optionText: o.optionText,
                        isCorrect: o.isCorrect ?? false,
                        sortOrder: o.sortOrder,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList();
      }
      _loadingExisting = false;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _timeLimitCtrl.dispose();
    _maxAttemptsCtrl.dispose();
    _passingScoreCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionInput(sortOrder: _questions.length));
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _duplicateQuestion(int idx) {
    final src = _questions[idx];
    setState(() {
      _questions.insert(
        idx + 1,
        QuestionInput(
          questionText: src.questionText,
          questionType: src.questionType,
          marks: src.marks,
          difficultyLevel: src.difficultyLevel,
          explanation: src.explanation,
          sourceReference: src.sourceReference,
          sortOrder: idx + 1,
          options: src.options
              .map(
                (o) => QuestionOptionInput(
                  optionText: o.optionText,
                  isCorrect: o.isCorrect,
                  sortOrder: o.sortOrder,
                ),
              )
              .toList(),
        ),
      );
    });
  }

  void _removeQuestion(int idx) {
    if (_questions.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A quiz needs at least one question')),
      );
      return;
    }
    setState(() => _questions.removeAt(idx));
  }

  bool _validateQuestions() {
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.questionText.trim().isEmpty) {
        _showError('Question ${i + 1} is missing its text.');
        return false;
      }
      // ShortAnswer questions are optional - no options required
      // MultipleChoice and SingleChoice need at least 2 options with one marked correct
      if (q.questionType == 'MultipleChoice' ||
          q.questionType == 'SingleChoice') {
        if (q.options.length < 2) {
          _showError('Question ${i + 1} needs at least 2 options.');
          return false;
        }
        if (q.options.any((o) => o.optionText.trim().isEmpty)) {
          _showError('Question ${i + 1} has an empty option.');
          return false;
        }
        if (!q.options.any((o) => o.isCorrect)) {
          _showError('Question ${i + 1} needs a correct answer marked.');
          return false;
        }
      }
      // TrueFalse questions automatically have True/False options
      if (q.questionType == 'TrueFalse') {
        if (!q.options.any((o) => o.isCorrect)) {
          _showError('Question ${i + 1} needs a correct answer marked.');
          return false;
        }
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateQuestions()) return;

    final data = QuizFormData(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      timeLimitMinutes: int.tryParse(_timeLimitCtrl.text.trim()),
      maxAttempts: int.tryParse(_maxAttemptsCtrl.text.trim()) ?? 1,
      passingScore: double.tryParse(_passingScoreCtrl.text.trim()) ?? 50,
      shuffleQuestions: _shuffleQuestions,
      shuffleAnswers: _shuffleAnswers,
      startDate: _startDate,
      showCorrectAnswers: _showCorrectAnswers,
      showExplanations: _showExplanations,
      gradingMode: _gradingMode,
      deadLineDate: _deadlineDate,
      targetSquadronId: _selectedSquadronId,
      difficultyLevel: _difficultyLevel,
      isVisible: _isVisible,
      questions: _questions,
    );

    final cubit = context.read<QuizCubit>();
    final success = _isEditing
        ? await cubit.updateQuiz(quizId: widget.existingQuizId!, data: data)
        : await cubit.createQuiz(data);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate({required bool isDeadline}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isDeadline ? _deadlineDate : _startDate) ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    final combined = DateTime(
      picked.year,
      picked.month,
      picked.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    setState(() {
      if (isDeadline) {
        _deadlineDate = combined;
      } else {
        _startDate = combined;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SquadronsCubitDrop()..fetchSquadrons(),
      child: BlocListener<QuizCubit, QuizState>(
        listener: (ctx, state) {
          if (state is QuizError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF0F7FF),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: const Color(0xFF1E1B4B),
            title: Text(
              _isEditing ? 'Edit Quiz' : 'Create New Quiz',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
          body: _loadingExisting
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                )
              : BlocBuilder<QuizCubit, QuizState>(
                  builder: (context, state) {
                    final isSaving = state is QuizActionInProgress;
                    return Stack(
                      children: [
                        Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionCard(
                                  title: 'Basic Info',
                                  icon: Icons.info_outline_rounded,
                                  children: [
                                    const _Label('Quiz Title'),
                                    _TextInput(
                                      controller: _titleCtrl,
                                      hint: 'e.g. Midterm Exam – Chapters 1-5',
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    const SizedBox(height: 14),
                                    const _Label('Description (optional)'),
                                    _TextInput(
                                      controller: _descCtrl,
                                      hint: 'Brief description...',
                                      maxLines: 2,
                                    ),
                                  ],
                                ),

                                _SectionCard(
                                  title: 'Timing & Attempts',
                                  icon: Icons.timer_outlined,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const _Label('Time Limit (min)'),
                                              _TextInput(
                                                controller: _timeLimitCtrl,
                                                hint: '30',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const _Label('Max Attempts'),
                                              _TextInput(
                                                controller: _maxAttemptsCtrl,
                                                hint: '1',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const _Label('Passing %'),
                                              _TextInput(
                                                controller: _passingScoreCtrl,
                                                hint: '50',
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _DatePickerField(
                                            label: 'Start Date',
                                            value: _startDate,
                                            onTap: () =>
                                                _pickDate(isDeadline: false),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _DatePickerField(
                                            label: 'Deadline',
                                            value: _deadlineDate,
                                            onTap: () =>
                                                _pickDate(isDeadline: true),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                _SectionCard(
                                  title: 'Behavior',
                                  icon: Icons.tune_rounded,
                                  children: [
                                    _SwitchRow(
                                      label: 'Shuffle Questions',
                                      value: _shuffleQuestions,
                                      onChanged: (v) =>
                                          setState(() => _shuffleQuestions = v),
                                    ),
                                    _SwitchRow(
                                      label: 'Shuffle Answers',
                                      value: _shuffleAnswers,
                                      onChanged: (v) =>
                                          setState(() => _shuffleAnswers = v),
                                    ),
                                    _SwitchRow(
                                      label:
                                          'Show Correct Answers After Submit',
                                      value: _showCorrectAnswers,
                                      onChanged: (v) => setState(
                                        () => _showCorrectAnswers = v,
                                      ),
                                    ),
                                    _SwitchRow(
                                      label: 'Show Explanations',
                                      value: _showExplanations,
                                      onChanged: (v) =>
                                          setState(() => _showExplanations = v),
                                    ),
                                    _SwitchRow(
                                      label: 'Visible to Students',
                                      value: _isVisible,
                                      onChanged: (v) =>
                                          setState(() => _isVisible = v),
                                    ),
                                    const SizedBox(height: 6),
                                    const _Label('Grading Mode'),
                                    _SegmentedSelector(
                                      options: const [
                                        'Auto',
                                        'Manual',
                                        'Hybrid',
                                      ],
                                      value: _gradingMode,
                                      onChanged: (v) =>
                                          setState(() => _gradingMode = v),
                                    ),
                                  ],
                                ),

                                _SectionCard(
                                  title: 'Targeting (optional)',
                                  icon: Icons.groups_rounded,
                                  children: [
                                    const _Label('Target Squadron'),
                                    BlocBuilder<
                                      SquadronsCubitDrop,
                                      GetSquadronsState
                                    >(
                                      builder: (context, state) {
                                        if (state is GetSquadronsLoading) {
                                          return const LinearProgressIndicator(
                                            minHeight: 2,
                                          );
                                        }
                                        if (state is GetSquadronsError) {
                                          return Text(
                                            state.message,
                                            style: const TextStyle(
                                              color: Color(0xFFEF4444),
                                              fontSize: 12,
                                            ),
                                          );
                                        }
                                        final squadrons =
                                            state is GetSquadronsLoaded
                                            ? state.squadrons
                                            : <SquadronModel>[];
                                        return DropdownButtonFormField<int>(
                                          initialValue: _selectedSquadronId,
                                          decoration: InputDecoration(
                                            hintText: 'All course students',
                                            filled: true,
                                            fillColor: const Color(0xFFF9FAFB),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                          items: [
                                            const DropdownMenuItem<int>(
                                              child: Text('Whole course'),
                                            ),
                                            ...squadrons.map(
                                              (s) => DropdownMenuItem<int>(
                                                value: s.id,
                                                child: Text(s.name),
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) => setState(
                                            () => _selectedSquadronId = value,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    const _Label('Difficulty Level'),
                                    _SegmentedSelector(
                                      options: const ['Easy', 'Medium', 'Hard'],
                                      value: _difficultyLevel ?? 'Medium',
                                      onChanged: (v) =>
                                          setState(() => _difficultyLevel = v),
                                    ),
                                  ],
                                ),

                                // ── Questions builder ────────────────
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.quiz_rounded,
                                      size: 18,
                                      color: Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Questions (${_questions.length})',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E1B4B),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Total marks: ${_questions.fold<int>(0, (sum, q) => sum + q.marks)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ..._questions.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final q = entry.value;
                                  return QuestionBuilderCard(
                                    key: ValueKey(q.hashCode + idx),
                                    question: q,
                                    index: idx,
                                    onChanged: () => setState(() {}),
                                    onDelete: () => _removeQuestion(idx),
                                    onDuplicate: () => _duplicateQuestion(idx),
                                  );
                                }),

                                Center(
                                  child: OutlinedButton.icon(
                                    onPressed: _addQuestion,
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Add Question'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF6366F1),
                                      side: const BorderSide(
                                        color: Color(0xFF6366F1),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),

                        // Floating bottom action bar
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isEditing
                                                ? Icons.save_rounded
                                                : Icons
                                                      .add_circle_outline_rounded,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isEditing
                                                ? 'Save Changes'
                                                : 'Create Quiz',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

// ── Reusable form pieces ─────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1B4B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    ),
  );
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }
}

class _SegmentedSelector extends StatelessWidget {
  const _SegmentedSelector({
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((opt) {
        final selected = opt == value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: opt != options.last ? 8 : 0),
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6366F1).withOpacity(0.1)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(
                  opt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value == null
                        ? 'Not set'
                        : '${value!.day}/${value!.month}/${value!.year} ${value!.hour}:${value!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: value == null
                          ? Colors.grey.shade400
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
