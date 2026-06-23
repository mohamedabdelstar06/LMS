// ============================================================
// quiz_take_screen.dart — full quiz taking experience
// ============================================================
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/quizes/quiz_cubit.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';
import 'package:lms/features/screens/quizes/quiz_state.dart';

import 'quiz_result_screen.dart';

class QuizTakeScreen extends StatefulWidget {
  const QuizTakeScreen({super.key});

  @override
  State<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends State<QuizTakeScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _timerStarted = false;

  void _startTimer(int totalSeconds) {
    if (_timerStarted || totalSeconds <= 0) return;
    _timerStarted = true;
    _remainingSeconds = totalSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        _submitQuiz(autoSubmit: true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    _countdownTimer?.cancel();
    if (!autoSubmit) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Submit Quiz?', style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text('Are you sure you want to submit? You cannot change your answers after submission.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Review', style: TextStyle(color: Color(0xFF6B7280)))),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) {
        // resume timer if user cancelled
        if (mounted && _remainingSeconds > 0) _startTimer(_remainingSeconds);
        return;
      }
    }
    if (mounted) context.read<QuizCubit>().submitQuiz();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _timerColor(int seconds, int total) {
    if (total <= 0) return const Color(0xFF10B981);
    final ratio = seconds / total;
    if (ratio > 0.5) return const Color(0xFF10B981);
    if (ratio > 0.25) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listener: (ctx, state) {
        if (state is QuizResultLoaded) {
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(value: ctx.read<QuizCubit>(), child: QuizResultScreen(result: state.result)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is QuizSessionLoading || state is QuizSubmitting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF0F7FF),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF6366F1)),
                  const SizedBox(height: 16),
                  Text(state is QuizSubmitting ? 'Submitting your answers...' : 'Loading quiz...', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          );
        }

        if (state is! QuizSessionLoaded) return const SizedBox.shrink();

        final session = state.session;
        final questions = session.questions;
        final totalSeconds = (session.timeLimitMinutes ?? 0) * 60;

        if (totalSeconds > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer(totalSeconds));
        }

        final timerColor = _timerColor(_remainingSeconds, totalSeconds);
        final answeredCount = state.answers.values.where((a) => a.selectedOptionId != null || (a.writtenAnswer?.isNotEmpty ?? false)).length;

        return Scaffold(
          backgroundColor: const Color(0xFFF0F7FF),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF374151)),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Exit Quiz?'),
                  content: const Text('Your progress is auto-saved, but you will need to resume later.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Stay')),
                    TextButton(
                      onPressed: () {
                        _countdownTimer?.cancel();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Exit', style: TextStyle(color: Color(0xFFEF4444))),
                    ),
                  ],
                ),
              ),
            ),
            title: Column(
              children: [
                Text(session.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Question ${_currentPage + 1} of ${questions.length} · $answeredCount answered', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            centerTitle: true,
            actions: [
              if (totalSeconds > 0)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: timerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: timerColor.withOpacity(0.3))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: timerColor),
                      const SizedBox(width: 4),
                      Text(_formatTime(_remainingSeconds), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: timerColor, fontFeatures: const [FontFeature.tabularFigures()])),
                    ],
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Container(
                height: 4,
                color: Colors.grey.shade100,
                child: FractionallySizedBox(
                  widthFactor: (_currentPage + 1) / questions.length,
                  alignment: Alignment.centerLeft,
                  child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]))),
                ),
              ),
              if (state.autoSaving)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: const Color(0xFFF0FDF4),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981))),
                      SizedBox(width: 6),
                      Text('Auto-saving...', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),

              // Question pills (jump nav)
              Container(
                height: 52,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (ctx, i) {
                    final answer = state.answers[questions[i].id];
                    final answered = answer != null && (answer.selectedOptionId != null || (answer.writtenAnswer?.isNotEmpty ?? false));
                    final flagged = answer?.isFlagged ?? false;
                    final isCurrent = i == _currentPage;
                    return GestureDetector(
                      onTap: () => _pageCtrl.jumpToPage(i),
                      child: Container(
                        width: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xFF6366F1) : answered ? const Color(0xFF10B981).withOpacity(0.12) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: flagged ? Border.all(color: const Color(0xFFF59E0B), width: 2) : null,
                        ),
                        child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isCurrent ? Colors.white : answered ? const Color(0xFF10B981) : Colors.grey.shade500)),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: questions.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (ctx, i) {
                    final q = questions[i];
                    final answer = state.answers[q.id];
                    return _QuestionPage(
                      question: q,
                      questionNumber: i + 1,
                      answer: answer,
                      onOptionSelect: (optId) => context.read<QuizCubit>().updateAnswer(questionId: q.id, selectedOptionId: optId),
                      onWrittenChange: (text) => context.read<QuizCubit>().updateAnswer(questionId: q.id, writtenAnswer: text),
                      onFlagToggle: () => context.read<QuizCubit>().toggleFlag(q.id),
                    );
                  },
                ),
              ),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.arrow_back_ios_rounded, size: 14), SizedBox(width: 4), Text('Previous')]),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < questions.length - 1) {
                            _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          } else {
                            _submitQuiz();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == questions.length - 1 ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_currentPage == questions.length - 1 ? 'Submit Quiz' : 'Next Question', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(width: 4),
                            Icon(_currentPage == questions.length - 1 ? Icons.check_circle_outline_rounded : Icons.arrow_forward_ios_rounded, size: 14),
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
      },
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.questionNumber,
    required this.answer,
    required this.onOptionSelect,
    required this.onWrittenChange,
    required this.onFlagToggle,
  });

  final QuestionDetailModel question;
  final int questionNumber;
  final QuizAnswer? answer;
  final ValueChanged<int> onOptionSelect;
  final ValueChanged<String> onWrittenChange;
  final VoidCallback onFlagToggle;

  @override
  Widget build(BuildContext context) {
    final isFlagged = answer?.isFlagged ?? false;
    final isShortAnswer = question.questionType == 'ShortAnswer';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('Q$questionNumber', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6366F1))),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                      child: Text('${question.marks} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706))),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(isFlagged ? Icons.flag_rounded : Icons.outlined_flag_rounded, color: isFlagged ? const Color(0xFFF59E0B) : Colors.grey.shade400, size: 22),
                      onPressed: onFlagToggle,
                      tooltip: isFlagged ? 'Unflag' : 'Flag for review',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(question.questionText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B), height: 1.5)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (isShortAnswer)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: TextField(
                maxLines: 5,
                onChanged: onWrittenChange,
                controller: TextEditingController(text: answer?.writtenAnswer ?? '')..selection = TextSelection.collapsed(offset: (answer?.writtenAnswer ?? '').length),
                decoration: InputDecoration(hintText: 'Type your answer here...', hintStyle: TextStyle(color: Colors.grey.shade400), border: InputBorder.none),
              ),
            )
          else
            ...question.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final opt = entry.value;
              final isSelected = answer?.selectedOptionId == opt.id;
              final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
              final letter = idx < letters.length ? letters[idx] : '${idx + 1}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => onOptionSelect(opt.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6366F1).withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200, width: isSelected ? 2 : 1),
                      boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.12), blurRadius: 12)] : null,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                          child: Center(child: Text(letter, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? Colors.white : Colors.grey.shade500))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(opt.optionText, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? const Color(0xFF1E1B4B) : const Color(0xFF374151)))),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
