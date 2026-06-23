// ============================================================
// quiz_grading_screen.dart — manual grading for short answers
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/quizes/quiz_cubit.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';
import 'package:lms/features/screens/quizes/quiz_state.dart';


class QuizGradingScreen extends StatefulWidget {
  const QuizGradingScreen({super.key, required this.quizId, required this.quizTitle});
  final int quizId;
  final String quizTitle;

  @override
  State<QuizGradingScreen> createState() => _QuizGradingScreenState();
}

class _QuizGradingScreenState extends State<QuizGradingScreen> {
  final Map<int, TextEditingController> _marksCtrls = {};
  final Map<int, TextEditingController> _feedbackCtrls = {};

  @override
  void dispose() {
    for (final c in _marksCtrls.values) {
      c.dispose();
    }
    for (final c in _feedbackCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _marksFor(StudentAnswerForGrading a) =>
      _marksCtrls.putIfAbsent(a.studentAnswerId, () => TextEditingController(text: (a.marksAwarded ?? 0).toString()));

  TextEditingController _feedbackFor(StudentAnswerForGrading a) =>
      _feedbackCtrls.putIfAbsent(a.studentAnswerId, () => TextEditingController(text: a.feedback ?? ''));

  Future<void> _submitGrades(List<StudentAnswerForGrading> answers) async {
    for (final a in answers) {
      a.marksAwarded = int.tryParse(_marksFor(a).text) ?? 0;
      a.feedback = _feedbackFor(a).text;
    }
    final cubit = context.read<QuizCubit>();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))));
    try {
      await cubit.gradeQuiz(quizId: widget.quizId, grades: answers);
      if (mounted) {
        Navigator.pop(context); // close loading
        Navigator.pop(context); // close screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Grades submitted successfully'), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit grades: $e'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E1B4B),
        title: Text('Grade: ${widget.quizTitle}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }
          if (state is! QuizGradingLoaded) {
            return const Center(child: Text('No pending answers to grade'));
          }
          final answers = state.answers;
          if (answers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt_rounded, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Nothing to grade right now', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: answers.length,
                itemBuilder: (ctx, i) {
                  final a = answers[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(radius: 16, backgroundColor: const Color(0xFF6366F1).withOpacity(0.1), child: Text(a.studentName.isNotEmpty ? a.studentName[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w700, fontSize: 13))),
                            const SizedBox(width: 10),
                            Text(a.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E1B4B))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(a.questionText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
                          child: Text(a.writtenAnswer?.isNotEmpty == true ? a.writtenAnswer! : '(No answer submitted)', style: TextStyle(fontSize: 13, color: a.writtenAnswer?.isNotEmpty == true ? const Color(0xFF1F2937) : Colors.grey.shade400)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: TextField(
                                controller: _marksFor(a),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  labelText: 'Marks /${a.maxMarks}',
                                  labelStyle: const TextStyle(fontSize: 11),
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _feedbackFor(a),
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Feedback (optional)',
                                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))]),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _submitGrades(answers),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                      child: const Text('Submit Grades', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
