// ============================================================
// quizzes_screen.dart  — main quizzes listing screen
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart';
import 'package:lms/features/screens/quizes/delete_quiz_dialog.dart';
import 'package:lms/features/screens/quizes/generate_quiz_sheet.dart';
import 'package:lms/features/screens/quizes/quiz_card.dart';
import 'package:lms/features/screens/quizes/quiz_cubit.dart';
import 'package:lms/features/screens/quizes/quiz_form_sheet.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';
import 'package:lms/features/screens/quizes/quiz_repository.dart';
import 'package:lms/features/screens/quizes/quiz_state.dart';


import 'quiz_take_screen.dart';

// ── Dio factory (reuse your app singleton if available) ───────
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

// ── Entry widget (wraps BlocProvider) ─────────────────────────
class QuizzesScreen extends StatelessWidget {
  const QuizzesScreen({super.key, required this.courseModel});
  final GetCoursesModel courseModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(
        repository: QuizRepository(_buildDio()),
        courseId: courseModel.id,
      )..loadQuizzes(),
      child: _QuizzesBody(courseModel: courseModel),
    );
  }
}

// ── Internal body ─────────────────────────────────────────────
class _QuizzesBody extends StatelessWidget {
  const _QuizzesBody({required this.courseModel});
  final GetCoursesModel courseModel;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizCubit, QuizState>(
      listener: (ctx, state) {
        if (state is QuizError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        if (state is QuizCreated || state is QuizUpdated) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(state is QuizCreated
                      ? 'Quiz created successfully!'
                      : 'Quiz updated!'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        if (state is QuizGenerated) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Quiz generated with AI!'),
                ],
              ),
              backgroundColor: const Color(0xFF6366F1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        if (state is QuizDeleted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Quiz deleted permanently'),
                ],
              ),
              backgroundColor: const Color(0xFF6B7280),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<QuizCubit>();
        final quizzes = cubit.quizzes;
        final isLoading = state is QuizLoading ||
            state is QuizCreating ||
            state is QuizUpdating ||
            state is QuizDeleting ||
            state is QuizGenerating;

        return Container(
          color: const Color(0xFFF0F7FF),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              _QuizzesHeader(
                count: quizzes.length,
                onCreateTap: () => _openCreateForm(context, cubit),
                onGenerateTap: () => _openGenerateForm(context, cubit),
              ),

              // ── Body ────────────────────────────────────────
              Expanded(
                child: isLoading && quizzes.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      )
                    : quizzes.isEmpty
                        ? _EmptyState(
                            onCreateTap: () =>
                                _openCreateForm(context, cubit),
                            onGenerateTap: () =>
                                _openGenerateForm(context, cubit),
                          )
                        : Stack(
                            children: [
                              ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: quizzes.length,
                                itemBuilder: (ctx, i) {
                                  final quiz = quizzes[i];
                                  return QuizCard(
                                    quiz: quiz,
                                    onTap: () =>
                                        _startQuiz(ctx, cubit, quiz),
                                    onEdit: () =>
                                        _openEditForm(ctx, cubit, quiz),
                                    onDelete: () =>
                                        _deleteQuiz(ctx, cubit, quiz),
                                    onResults: () =>
                                        _showResults(ctx, cubit, quiz),
                                  );
                                },
                              ),
                              if (isLoading)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: const LinearProgressIndicator(
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

  // ── Action handlers ────────────────────────────────────────
  Future<void> _openCreateForm(
      BuildContext context, QuizCubit cubit) async {
    final data = await showQuizFormSheet(
      context,
      courseId: courseModel.id,
    );
    if (data != null) cubit.createQuiz(data);
  }

  Future<void> _openEditForm(
    BuildContext context,
    QuizCubit cubit,
    QuizModel quiz,
  ) async {
    final data = await showQuizFormSheet(
      context,
      existingQuiz: quiz,
      courseId: courseModel.id,
    );
    if (data != null) cubit.updateQuiz(quizId: quiz.id, data: data);
  }

  Future<void> _deleteQuiz(
    BuildContext context,
    QuizCubit cubit,
    QuizModel quiz,
  ) async {
    final confirmed = await showDeleteQuizDialog(
      context,
      quizTitle: quiz.title,
    );
    if (confirmed) cubit.deleteQuiz(quiz.id);
  }

  Future<void> _openGenerateForm(
      BuildContext context, QuizCubit cubit) async {
    final req = await showGenerateQuizSheet(
      context,
      courseId: courseModel.id,
    );
    if (req != null) cubit.generateQuiz(req);
  }

  Future<void> _startQuiz(
    BuildContext context,
    QuizCubit cubit,
    QuizModel quiz,
  ) async {
    await cubit.startQuiz(quiz.id);
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const QuizTakeScreen(),
        ),
      ),
    );
    // Reload after completing
    cubit.loadQuizzes();
  }

  void _showResults(
    BuildContext context,
    QuizCubit cubit,
    QuizModel quiz,
  ) {
    cubit.loadResults(quiz.id);
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _ResultsDialog(quizTitle: quiz.title),
      ),
    );
  }
}

// ── Header widget ─────────────────────────────────────────────
class _QuizzesHeader extends StatelessWidget {
  const _QuizzesHeader({
    required this.count,
    required this.onCreateTap,
    required this.onGenerateTap,
  });

  final int count;
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.quiz_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quizzes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  Text(
                    '$count ${count == 1 ? 'quiz' : 'quizzes'} total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeaderButton(
                  icon: Icons.add_rounded,
                  label: 'New Quiz',
                  color: const Color(0xFF6366F1),
                  onTap: onCreateTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderButton(
                  icon: Icons.auto_awesome,
                  label: 'Generate AI',
                  color: const Color(0xFF8B5CF6),
                  onTap: onGenerateTap,
                  outlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.transparent : color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color),
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: outlined ? color : Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: outlined ? color : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onCreateTap,
    required this.onGenerateTap,
  });

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
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.1),
                    const Color(0xFF8B5CF6).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_rounded,
                size: 48,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No quizzes yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first quiz manually or let AI\ngenerate one for you instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onCreateTap,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onGenerateTap,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('AI Generate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results dialog ────────────────────────────────────────────
class _ResultsDialog extends StatelessWidget {
  const _ResultsDialog({required this.quizTitle});
  final String quizTitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: Color(0xFF0EA5E9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Results: $quizTitle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade400),
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: BlocBuilder<QuizCubit, QuizState>(
                builder: (ctx, state) {
                  if (state is QuizLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF6366F1)),
                    );
                  }
                  if (state is QuizResultsLoaded) {
                    if (state.results.isEmpty) {
                      return const Center(
                        child: Text(
                          'No submissions yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: state.results.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = state.results[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                (r.passed ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                    .withOpacity(0.1),
                            child: Text(
                              '${r.score.toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: r.passed
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                          title: Text(
                            'Attempt #${r.attemptId}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${r.correctAnswers}/${r.totalQuestions} correct · ${r.timeTakenSeconds ~/ 60}m',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: r.passed
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              r.passed ? 'Passed' : 'Failed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: r.passed
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
