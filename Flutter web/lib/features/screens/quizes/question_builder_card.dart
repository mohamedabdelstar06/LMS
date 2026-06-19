// ============================================================
// question_builder_card.dart — editable question + options card
// ============================================================
import 'package:flutter/material.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

class QuestionBuilderCard extends StatefulWidget {
  const QuestionBuilderCard({
    super.key,
    required this.question,
    required this.index,
    required this.onChanged,
    required this.onDelete,
    required this.onDuplicate,
  });

  final QuestionInput question;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  @override
  State<QuestionBuilderCard> createState() => _QuestionBuilderCardState();
}

class _QuestionBuilderCardState extends State<QuestionBuilderCard> {
  bool _expanded = true;
  late TextEditingController _textCtrl;
  late TextEditingController _marksCtrl;
  late TextEditingController _explanationCtrl;

  static const _types = [
    ('SingleChoice', 'Single Choice', Icons.radio_button_checked_rounded),
    ('MultipleChoice', 'Multiple Choice', Icons.check_box_rounded),
    ('TrueFalse', 'True / False', Icons.rule_rounded),
    ('ShortAnswer', 'Short Answer', Icons.short_text_rounded),
  ];

  static const _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.question.questionText);
    _marksCtrl = TextEditingController(text: widget.question.marks.toString());
    _explanationCtrl = TextEditingController(text: widget.question.explanation);

    _textCtrl.addListener(() {
      widget.question.questionText = _textCtrl.text;
      widget.onChanged();
    });
    _marksCtrl.addListener(() {
      widget.question.marks = int.tryParse(_marksCtrl.text) ?? 1;
      widget.onChanged();
    });
    _explanationCtrl.addListener(() {
      widget.question.explanation = _explanationCtrl.text;
      widget.onChanged();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _marksCtrl.dispose();
    _explanationCtrl.dispose();
    super.dispose();
  }

  void _setType(String type) {
    setState(() {
      widget.question.questionType = type;
      if (type == 'TrueFalse') {
        widget.question.options = [
          QuestionOptionInput(optionText: 'True'),
          QuestionOptionInput(optionText: 'False', sortOrder: 1),
        ];
      } else if (type == 'ShortAnswer') {
        widget.question.options = [];
      } else if (widget.question.options.length < 2) {
        widget.question.options = [
          QuestionOptionInput(),
          QuestionOptionInput(sortOrder: 1),
        ];
      }
    });
    widget.onChanged();
  }

  void _addOption() {
    setState(() {
      widget.question.options.add(
        QuestionOptionInput(sortOrder: widget.question.options.length),
      );
    });
    widget.onChanged();
  }

  void _removeOption(int idx) {
    if (widget.question.options.length <= 2) return;
    setState(() => widget.question.options.removeAt(idx));
    widget.onChanged();
  }

  void _setCorrectOption(int idx) {
    setState(() {
      final isMultiple = widget.question.questionType == 'MultipleChoice';
      if (isMultiple) {
        widget.question.options[idx].isCorrect =
            !widget.question.options[idx].isCorrect;
      } else {
        for (var i = 0; i < widget.question.options.length; i++) {
          widget.question.options[i].isCorrect = i == idx;
        }
      }
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.question.questionType;
    final typeInfo = _types.firstWhere(
      (t) => t.$1 == type,
      orElse: () => _types[0],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header bar
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: Radius.circular(_expanded ? 0 : 16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6366F1),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.question.questionText.isEmpty
                          ? 'Question ${widget.index + 1} (untitled)'
                          : widget.question.questionText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.question.questionText.isEmpty
                            ? Colors.grey.shade400
                            : const Color(0xFF1E1B4B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          typeInfo.$3,
                          size: 12,
                          color: const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          typeInfo.$2,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 17,
                      color: Colors.grey.shade400,
                    ),
                    tooltip: 'Duplicate',
                    onPressed: widget.onDuplicate,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                    tooltip: 'Remove question',
                    onPressed: widget.onDelete,
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Question text
                  TextField(
                    controller: _textCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Type your question here...',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.all(12),
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
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Type selector
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _types.map((t) {
                      final selected = type == t.$1;
                      return GestureDetector(
                        onTap: () => _setType(t.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF6366F1).withOpacity(0.1)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                t.$3,
                                size: 14,
                                color: selected
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.$2,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? const Color(0xFF6366F1)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Options (skip for ShortAnswer)
                  if (type != 'ShortAnswer') ...[
                    Text(
                      'Options ${type == "MultipleChoice" ? "(select all correct)" : "(select the correct one)"}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.question.options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final opt = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _OptionRow(
                          option: opt,
                          isMultiSelect: type == 'MultipleChoice',
                          locked: false,
                          onSelect: () => _setCorrectOption(idx),
                          onTextChanged: (v) {
                            if (type != 'TrueFalse') {
                              opt.optionText = v;
                              widget.onChanged();
                            }
                          },
                          onRemove:
                              widget.question.options.length > 2 &&
                                  type != 'TrueFalse'
                              ? () => _removeOption(idx)
                              : null,
                        ),
                      );
                    }),
                    if (type != 'TrueFalse')
                      TextButton.icon(
                        onPressed: _addOption,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text(
                          'Add option',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Short-answer questions are graded manually by the instructor.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 4),

                  // Marks + Difficulty row
                  Row(
                    children: [
                      Expanded(
                        child: _MiniField(
                          label: 'Marks',
                          child: TextField(
                            controller: _marksCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13),
                            decoration: _miniDecoration(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _MiniField(
                          label: 'Difficulty',
                          child: DropdownButtonFormField<String>(
                            initialValue: widget.question.difficultyLevel,
                            items: _difficulties
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(
                                      d,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(
                                  () => widget.question.difficultyLevel = v,
                                );
                                widget.onChanged();
                              }
                            },
                            decoration: _miniDecoration(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Explanation (optional)
                  TextField(
                    controller: _explanationCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText:
                          'Explanation (optional, shown after submission)',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _miniDecoration() => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
    ),
  );
}

class _MiniField extends StatelessWidget {
  const _MiniField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.isMultiSelect,
    required this.locked,
    required this.onSelect,
    required this.onTextChanged,
    this.onRemove,
  });

  final QuestionOptionInput option;
  final bool isMultiSelect;
  final bool locked;
  final VoidCallback onSelect;
  final ValueChanged<String> onTextChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: locked ? null : onSelect,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: isMultiSelect ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isMultiSelect ? BorderRadius.circular(6) : null,
              color: option.isCorrect ? const Color(0xFF10B981) : Colors.white,
              border: Border.all(
                color: option.isCorrect
                    ? const Color(0xFF10B981)
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: option.isCorrect
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: option.optionText)
              ..selection = TextSelection.collapsed(
                offset: option.optionText.length,
              ),
            enabled: !locked,
            onChanged: onTextChanged,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Option text',
              isDense: true,
              filled: true,
              fillColor: locked ? Colors.grey.shade50 : const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
            onPressed: onRemove,
          ),
      ],
    );
  }
}
