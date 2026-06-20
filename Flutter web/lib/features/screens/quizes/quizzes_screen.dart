// ignore_for_file: directives_ordering

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart';
import 'package:lms/features/screens/quizes/delete_quiz_dialog.dart';
import 'package:lms/features/screens/quizes/generate_quiz_sheet.dart';
import 'package:lms/features/screens/quizes/quiz_card.dart';
import 'package:lms/features/screens/quizes/quiz_cubit.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';
import 'package:lms/features/screens/quizes/quiz_repository.dart';
import 'package:lms/core/helpers/json_list_parser.dart';
import 'package:lms/features/screens/quizes/quiz_state.dart';
import 'quiz_form_screen.dart';
import 'quiz_take_screen.dart';
import 'quiz_grading_screen.dart';

// ── Dio factory ───────────────────────────────────────────────
Dio _buildDio() =>
    Dio(
      BaseOptions(
        baseUrl: 'https://skylearn.runasp.net/api/',
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await TokenStorageHelper.getTokenSecure();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );

class QuizzesScreen extends StatelessWidget {
  const QuizzesScreen({
    super.key,
    required this.courseModel,
    required this.isAdmin,
  });

  final GetCoursesModel courseModel;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(
        repository: QuizRepository(_buildDio()),
        courseId: courseModel.id,
        role: isAdmin ? UserRole.admin : UserRole.student,
      )..loadQuizzes(),
      child: _QuizzesBody(courseModel: courseModel, isAdmin: isAdmin),
    );
  }
}

class _QuizzesBody extends StatelessWidget {
  const _QuizzesBody({required this.courseModel, required this.isAdmin});

  final GetCoursesModel courseModel;
  final bool isAdmin;

  void _showSuccess(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listener: (ctx, state) {
        if (state is QuizError) _showError(ctx, state.message);
        if (state is QuizActionSuccess) _showSuccess(ctx, state.message);
        if (state is QuizGenerated) {
          _showSuccess(ctx, '✨ AI quiz "${state.quiz.title}" created!');
        }
      },
      builder: (context, state) {
        final cubit = context.read<QuizCubit>();
        final quizzes = cubit.quizzes;

        final isLoading = state is QuizLoading && quizzes.isEmpty;
        final isActing = state is QuizActionInProgress || state is QuizGenerating;

        return Container(
          color: const Color(0xFFF0F7FF),
          child: Column(
            children: [
           
              _Header(
                count: quizzes.length,
                isAdmin: isAdmin,
                isActing: isActing,
                generatingProgress: state is QuizGenerating ? state.progress : null,
                onCreateTap: () => _openCreate(context),
                onGenerateTap: () => _openGenerate(context, cubit),
              ),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                    : quizzes.isEmpty
                        ? _EmptyState(isAdmin: isAdmin, onCreateTap: () => _openCreate(context), onGenerateTap: () => _openGenerate(context, cubit))
                        : Stack(
                            children: [
                              RefreshIndicator(
                                color: const Color(0xFF6366F1),
                                onRefresh: cubit.loadQuizzes,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: quizzes.length,
                                  itemBuilder: (ctx, i) {
                                    final quiz = quizzes[i];
                                    return QuizCard(
                                      quiz: quiz,
                                      isAdmin: isAdmin,
                                      onTap: () => _startQuiz(ctx, cubit, quiz),
                                      onEdit: () => _openEdit(ctx, quiz),
                                      onDelete: () => _deleteQuiz(ctx, cubit, quiz),
                                      onResults: () => _openResults(ctx, cubit, quiz),
                                      onToggleVisibility: () => cubit.toggleVisibility(quiz),
                                    );
                                  },
                                ),
                              ),
                              if (isActing && quizzes.isNotEmpty)
                                const Positioned(
                                  top: 0, left: 0, right: 0,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    color: Color(0xFF6366F1),
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


  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<QuizCubit>(),
          child: QuizFormScreen(courseId: courseModel.id),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, QuizModel quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<QuizCubit>(),
          child: QuizFormScreen(courseId: courseModel.id, existingQuizId: quiz.id),
        ),
      ),
    );
  }

  Future<void> _deleteQuiz(BuildContext context, QuizCubit cubit, QuizModel quiz) async {
    final confirmed = await showDeleteQuizDialog(context, quizTitle: quiz.title);
    if (confirmed && context.mounted) cubit.deleteQuiz(quiz.id);
  }

  Future<void> _openGenerate(BuildContext context, QuizCubit cubit) async {
    List<(int, String)> lectures = [];
    try {
      final dio = _buildDio();
      final res = await dio.get('courses/${courseModel.id}/lectures');
      lectures = parseJsonObjectList(res.data)
          .map((e) => (
                e['id'] as int? ?? 0,
                e['title'] as String? ?? 'Lecture ${e['id']}',
              ))
          .where((e) => e.$1 > 0)
          .toList();
    } catch (_) {}

    final req = await showGenerateQuizSheet(
      context,
      courseId: courseModel.id,
      availableLectures: lectures,
    );
    if (req != null && context.mounted) cubit.generateQuiz(req);
  }

  Future<void> _startQuiz(BuildContext context, QuizCubit cubit, QuizModel quiz) async {
    await cubit.startQuiz(quiz.id);
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: cubit, child: const QuizTakeScreen()),
      ),
    );
    cubit.loadQuizzes();
  }

  void _openResults(BuildContext context, QuizCubit cubit, QuizModel quiz) {
    if (isAdmin) {
      _showResultsDialog(context, cubit, quiz);
    } else {
      cubit.loadMyResult(quiz.id);
    
      showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: _MyResultDialog(quizTitle: quiz.title),
        ),
      );
    }
  }

  void _showResultsDialog(BuildContext context, QuizCubit cubit, QuizModel quiz) {
    cubit.loadResults(quiz.id);
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _AllResultsDialog(
          quizTitle: quiz.title,
          quizId: quiz.id,
          gradingMode: quiz.gradingMode,
          onGradeTap: quiz.gradingMode != 'Auto'
              ? () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: QuizGradingScreen(quizId: quiz.id, quizTitle: quiz.title),
                      ),
                    ),
                  );
                }
              : null,
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.isAdmin,
    required this.isActing,
    required this.generatingProgress,
    required this.onCreateTap,
    required this.onGenerateTap,
  });

  final int count;
  final bool isAdmin;
  final bool isActing;
  final double? generatingProgress;
  final VoidCallback onCreateTap;
  final VoidCallback onGenerateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quizzes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B))),
                  Text('$count ${count == 1 ? 'quiz' : 'quizzes'} total', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (isAdmin) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _HeaderBtn(icon: Icons.add_rounded, label: 'New Quiz', color: const Color(0xFF6366F1), filled: true, onTap: onCreateTap)),
                const SizedBox(width: 10),
                Expanded(child: _HeaderBtn(icon: Icons.auto_awesome, label: 'Generate AI', color: const Color(0xFF8B5CF6), filled: false, onTap: onGenerateTap)),
              ],
            ),
          ],
          // AI generation upload progress
          if (generatingProgress != null) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Generating with AI...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6366F1))),
                    Text('${(generatingProgress! * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6366F1))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: generatingProgress! > 0 ? generatingProgress : null,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE0E7FF),
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({required this.icon, required this.label, required this.color, required this.filled, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: filled
              ? null
              : BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: color)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: filled ? Colors.white : color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: filled ? Colors.white : color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAdmin, required this.onCreateTap, required this.onGenerateTap});
  final bool isAdmin;
  final VoidCallback onCreateTap;
  final VoidCallback onGenerateTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFF6366F1).withOpacity(0.1), const Color(0xFF8B5CF6).withOpacity(0.05)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.quiz_rounded, size: 48, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 20),
            Text(isAdmin ? 'No quizzes yet' : 'No quizzes available', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
            const SizedBox(height: 8),
            Text(
              isAdmin ? 'Create your first quiz manually or let AI\ngenerate one for you instantly.' : 'Your instructor hasn\'t added any quizzes yet.\nCheck back later!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onCreateTap,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create Quiz'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onGenerateTap,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('AI Generate'),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6), side: const BorderSide(color: Color(0xFF8B5CF6)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AllResultsDialog extends StatelessWidget {
  const _AllResultsDialog({required this.quizTitle, required this.quizId, required this.gradingMode, this.onGradeTap});
  final String quizTitle;
  final int quizId;
  final String gradingMode;
  final VoidCallback? onGradeTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 560),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: Color(0xFF0EA5E9), size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Results: $quizTitle', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B)))),
                  if (onGradeTap != null)
                    TextButton.icon(
                      onPressed: onGradeTap,
                      icon: const Icon(Icons.grading_rounded, size: 16),
                      label: const Text('Grade', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                    ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: Colors.grey.shade400)),
                ],
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: BlocBuilder<QuizCubit, QuizState>(
                builder: (ctx, state) {
                  if (state is QuizLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
                  if (state is! QuizResultsLoaded) return const SizedBox.shrink();
                  if (state.results.isEmpty) return Center(child: Text('No submissions yet', style: TextStyle(color: Colors.grey.shade500)));

                  // summary stats
                  final results = state.results;
                  final avg = results.fold<double>(0, (s, r) => s + r.score) / results.length;
                  final passCount = results.where((r) => r.passed).length;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _MiniStat(label: 'Submissions', value: results.length.toString(), color: const Color(0xFF6366F1)),
                            const SizedBox(width: 10),
                            _MiniStat(label: 'Avg Score', value: '${avg.toStringAsFixed(1)}%', color: const Color(0xFF0EA5E9)),
                            const SizedBox(width: 10),
                            _MiniStat(label: 'Pass Rate', value: '${(passCount / results.length * 100).toInt()}%', color: const Color(0xFF10B981)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final r = results[i];
                            final color = r.passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.1),
                                child: Text('${r.score.toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                              ),
                              title: Text(
                                r.studentName?.isNotEmpty == true
                                    ? r.studentName!
                                    : '${r.quizTitle.isNotEmpty ? r.quizTitle : 'Attempt'} #${r.attemptId}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('${r.correctAnswers}/${r.totalQuestions} correct · ${r.earnedMarks}/${r.totalMarks} marks', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(r.passed ? 'Passed' : 'Failed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _MyResultDialog extends StatelessWidget {
  const _MyResultDialog({required this.quizTitle});
  final String quizTitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<QuizCubit, QuizState>(
          builder: (ctx, state) {
            if (state is QuizLoading) {
              return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))));
            }
            if (state is! QuizResultLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.quiz_outlined, size: 40, color: Color(0xFF6366F1)),
                    const SizedBox(height: 12),
                    const Text('No result yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text("You haven't taken this quiz yet.", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(height: 16),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                  ],
                ),
              );
            }
            final r = state.result;
            final passed = r.passed;
            final color = passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(quizTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E1B4B)))),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close_rounded, color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${r.score.toStringAsFixed(0)}%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
                      Text(passed ? '✅ Pass' : '❌ Fail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ResultRow('Correct Answers', '${r.correctAnswers} / ${r.totalQuestions}'),
                _ResultRow('Marks Earned', '${r.earnedMarks} / ${r.totalMarks}'),
                _ResultRow('Passing Score', '${r.passingScore.toInt()}%'),
                if (!r.isFullyGraded)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('⏳ Pending manual grading', style: TextStyle(fontSize: 12, color: Color(0xFFD97706))),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
        ],
      ),
    );
  }
}
