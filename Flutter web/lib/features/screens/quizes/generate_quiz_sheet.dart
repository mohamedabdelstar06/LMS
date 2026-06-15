// ============================================================
// generate_quiz_sheet.dart  — AI-powered quiz generator
// ============================================================
import 'package:flutter/material.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

class GenerateQuizSheet extends StatefulWidget {
  const GenerateQuizSheet({super.key, required this.courseId});
  final int courseId;

  @override
  State<GenerateQuizSheet> createState() => _GenerateQuizSheetState();
}

class _GenerateQuizSheetState extends State<GenerateQuizSheet> {
  final _topicCtrl = TextEditingController();
  int _questionsCount = 10;
  String _difficulty = 'medium';

  static const _difficulties = [
    ('easy', '😊 Easy', Color(0xFF10B981)),
    ('medium', '🎯 Medium', Color(0xFFF59E0B)),
    ('hard', '🔥 Hard', Color(0xFFEF4444)),
  ];

  @override
  void dispose() {
    _topicCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    if (_topicCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop(
      GenerateQuizRequest(
        courseId: widget.courseId,
        topic: _topicCtrl.text.trim(),
        questionsCount: _questionsCount,
        difficulty: _difficulty,
        
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // AI Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Quiz Generator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Generate smart questions instantly',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topic
                const Text(
                  'Topic / Subject',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _topicCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. "Photosynthesis in plants"',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.lightbulb_outline_rounded,
                        size: 18, color: Color(0xFF6366F1)),
                    filled: true,
                    fillColor: const Color(0xFFF5F3FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E7FF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E7FF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFF6366F1), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Questions count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Number of Questions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_questionsCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6366F1),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _questionsCount.toDouble(),
                  min: 5,
                  max: 30,
                  divisions: 5,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (v) =>
                      setState(() => _questionsCount = v.toInt()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['5', '10', '15', '20', '25', '30']
                      .map((e) => Text(e,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400)))
                      .toList(),
                ),

                const SizedBox(height: 20),

                // Difficulty
                const Text(
                  'Difficulty',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _difficulties.map((d) {
                    final selected = _difficulty == d.$1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: d.$1 != 'hard' ? 8 : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _difficulty = d.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? d.$3.withOpacity(0.12)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? d.$3
                                    : Colors.grey.shade200,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              d.$2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected ? d.$3 : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _generate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Generate with AI',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
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
}

Future<GenerateQuizRequest?> showGenerateQuizSheet(
  BuildContext context, {
  required int courseId,
}) {
  return showModalBottomSheet<GenerateQuizRequest>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GenerateQuizSheet(courseId: courseId),
  );
}
