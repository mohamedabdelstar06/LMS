import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/student/student_courses/quiz_result_screen.dart';
import 'package:lms/features/screens/student/student_courses/student_quiz_cubit.dart';
import 'package:lms/features/screens/student/student_courses/student_quiz_states.dart';

import '../../../../core/cons/Colors/app_colors.dart';

import 'student_quiz_model.dart';

class QuizTakeScreen extends StatefulWidget {
  final String quizTitle;
  const QuizTakeScreen({super.key, required this.quizTitle});

  @override
  State<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends State<QuizTakeScreen> {
  int _currentIndex = 0;
  Timer? _countdownTimer;
  Duration? _remaining;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _ensureTimerStarted(QuizSessionActive state) {
    if (_countdownTimer != null) return;
    final minutes = state.session.timeLimitMinutes;
    if (minutes == null) return;
    _remaining = Duration(minutes: minutes);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remaining!.inSeconds <= 1) {
          _remaining = Duration.zero;
          timer.cancel();
          context.read<StudentQuizCubit>().submitQuiz();
        } else {
          _remaining = _remaining! - const Duration(seconds: 1);
        }
      });
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;
    final maxWidth = isLargeScreen ? 900.0 : (isMediumScreen ? 700.0 : double.infinity);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MYColors.gradientColor_3,
            MYColors.gradientColor_2.withValues(alpha: 0.25),
            MYColors.gradientColor_3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocConsumer<StudentQuizCubit, StudentQuizState>(
            listener: (context, state) {
              if (state is QuizResultLoaded) {
                _countdownTimer?.cancel();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => QuizResultScreen(result: state.result)),
                );
              }
              if (state is QuizSessionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is! QuizSessionActive) {
                return const Center(child: CircularProgressIndicator());
              }

              _ensureTimerStarted(state);

              final questions = state.session.questions;
              if (questions.isEmpty) {
                return const Center(child: Text('This quiz has no questions.'));
              }
              if (_currentIndex >= questions.length) _currentIndex = questions.length - 1;
              final question = questions[_currentIndex];
              final answer = state.answers[question.id];
              final answeredCount = state.answers.values
                  .where((a) => a.selectedOptionId != null || (a.writtenAnswer?.isNotEmpty ?? false))
                  .length;

              return Column(
                children: [
                  _TopBar(
                    title: widget.quizTitle,
                    isResumed: state.isResumed,
                    isAutoSaving: state.isAutoSaving,
                    remaining: _remaining,
                    formatDuration: _formatDuration,
                    maxWidth: maxWidth,
                    horizontalPadding: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
                        vertical: 16,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _QuestionNav(
                                total: questions.length,
                                currentIndex: _currentIndex,
                                answeredFlags: [
                                  for (final q in questions)
                                    state.answers[q.id]?.selectedOptionId != null ||
                                        (state.answers[q.id]?.writtenAnswer?.isNotEmpty ?? false)
                                ],
                                flaggedFlags: [for (final q in questions) state.answers[q.id]?.isFlagged ?? false],
                                onSelect: (i) => setState(() => _currentIndex = i),
                              ),
                              const SizedBox(height: 20),
                              _QuestionCard(
                                question: question,
                                index: _currentIndex,
                                total: questions.length,
                                answer: answer,
                                onSelectOption: (optionId) {
                                  context.read<StudentQuizCubit>().updateAnswer(
                                        questionId: question.id,
                                        selectedOptionId: optionId,
                                      );
                                },
                                onWrittenChanged: (text) {
                                  context.read<StudentQuizCubit>().updateAnswer(
                                        questionId: question.id,
                                        writtenAnswer: text,
                                      );
                                },
                                onToggleFlag: () {
                                  context.read<StudentQuizCubit>().toggleFlag(question.id);
                                },
                              ),
                              const SizedBox(height: 20),
                              _NavigationButtons(
                                isFirst: _currentIndex == 0,
                                isLast: _currentIndex == questions.length - 1,
                                answeredCount: answeredCount,
                                totalCount: questions.length,
                                isSubmitting: state.isSubmitting,
                                onPrevious: () => setState(() => _currentIndex--),
                                onNext: () => setState(() => _currentIndex++),
                                onSubmit: () => _confirmSubmit(context, answeredCount, questions.length),
                              ),
                              const SizedBox(height: 30),
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

  Future<void> _confirmSubmit(BuildContext context, int answered, int total) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Quiz?', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700)),
        content: Text(
          answered < total
              ? 'You\'ve answered $answered of $total questions. Unanswered questions will be marked as incorrect. Submit anyway?'
              : 'You\'ve answered all $total questions. Once submitted, you cannot change your answers.',
          style: const TextStyle(fontFamily: 'inter'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<StudentQuizCubit>().submitQuiz();
    }
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool isResumed;
  final bool isAutoSaving;
  final Duration? remaining;
  final String Function(Duration) formatDuration;
  final double maxWidth;
  final double horizontalPadding;

  const _TopBar({
    required this.title,
    required this.isResumed,
    required this.isAutoSaving,
    required this.remaining,
    required this.formatDuration,
    required this.maxWidth,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isLowTime = remaining != null && remaining!.inSeconds <= 60;
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'inter',
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (isResumed || isAutoSaving)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isResumed)
                                const Text(
                                  'Resumed attempt',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF7C3AED), fontFamily: 'inter'),
                                ),
                              if (isResumed && isAutoSaving) const Text(' · ', style: TextStyle(fontSize: 11)),
                              if (isAutoSaving)
                                const Text(
                                  'Saving...',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'inter'),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (remaining != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLowTime ? const Color(0xFFFEF2F2) : const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_rounded,
                            size: 16, color: isLowTime ? const Color(0xFFDC2626) : const Color(0xFF7C3AED)),
                        const SizedBox(width: 6),
                        Text(
                          formatDuration(remaining!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'inter',
                            color: isLowTime ? const Color(0xFFDC2626) : const Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionNav extends StatelessWidget {
  final int total;
  final int currentIndex;
  final List<bool> answeredFlags;
  final List<bool> flaggedFlags;
  final void Function(int) onSelect;

  const _QuestionNav({
    required this.total,
    required this.currentIndex,
    required this.answeredFlags,
    required this.flaggedFlags,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: total,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isCurrent = i == currentIndex;
          final isAnswered = answeredFlags[i];
          final isFlagged = flaggedFlags[i];
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF7C3AED)
                    : (isAnswered ? const Color(0xFFEDE9FE) : Colors.white),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent ? const Color(0xFF7C3AED) : const Color(0xffE2E8F0),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'inter',
                      color: isCurrent ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                  if (isFlagged)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Icon(Icons.flag_rounded, size: 12, color: Colors.orange.shade600),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuizTakeQuestion question;
  final int index;
  final int total;
  final QuizAnswerDraft? answer;
  final void Function(int optionId) onSelectOption;
  final void Function(String text) onWrittenChanged;
  final VoidCallback onToggleFlag;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.total,
    required this.answer,
    required this.onSelectOption,
    required this.onWrittenChanged,
    required this.onToggleFlag,
  });

  @override
  Widget build(BuildContext context) {
    final isFlagged = answer?.isFlagged ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Question ${index + 1} of $total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'inter',
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${question.marks} pt${question.marks > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'inter',
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onToggleFlag,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    isFlagged ? Icons.flag_rounded : Icons.flag_outlined,
                    size: 20,
                    color: isFlagged ? Colors.orange.shade600 : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'inter',
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          if (question.questionType == 'ShortAnswer')
            TextFormField(
              initialValue: answer?.writtenAnswer ?? '',
              maxLines: 4,
              onChanged: onWrittenChanged,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                filled: true,
                fillColor: const Color(0xffF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                ),
              ),
            )
          else
            Column(
              children: [
                for (final option in question.options)
                  _OptionTile(
                    option: option,
                    isSelected: answer?.selectedOptionId == option.id,
                    onTap: () => onSelectOption(option.id),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final QuizTakeOption option;
  final bool isSelected;
  final VoidCallback onTap;
  const _OptionTile({required this.option, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF3E8FF) : const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF7C3AED) : const Color(0xffE2E8F0),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF7C3AED) : const Color(0xffCBD5E1),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.optionText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'inter',
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final int answeredCount;
  final int totalCount;
  final bool isSubmitting;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _NavigationButtons({
    required this.isFirst,
    required this.isLast,
    required this.answeredCount,
    required this.totalCount,
    required this.isSubmitting,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isFirst)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPrevious,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7C3AED),
                side: const BorderSide(color: Color(0xFF7C3AED)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (!isFirst) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: isLast
              ? ElevatedButton.icon(
                  onPressed: isSubmitting ? null : onSubmit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(isSubmitting ? 'Submitting...' : 'Submit Quiz ($answeredCount/$totalCount)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Next Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
        ),
      ],
    );
  }
}
