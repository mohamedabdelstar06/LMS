import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/student/student_courses/assignment_student_cubit.dart';
import 'package:lms/features/screens/student/student_courses/assignment_student_states.dart';

import '../../../../core/cons/Colors/app_colors.dart';

import 'student_assignment_model.dart';
import 'assignment_detail_screen.dart';

class AssignmentsListScreen extends StatelessWidget {

  const AssignmentsListScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });
  final int courseId;
  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssignmentStudentCubit()..loadAssignments(courseId),
      child: _AssignmentsListView(courseId: courseId, courseTitle: courseTitle),
    );
  }
}

class _AssignmentsListView extends StatelessWidget {
  const _AssignmentsListView({required this.courseId, required this.courseTitle});
  final int courseId;
  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800;
    final maxWidth = isLargeScreen ? 1100.0 : (isMediumScreen ? 800.0 : double.infinity);

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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 16, color: Color(0xFF175CD3)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assignments',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'inter',
                                  color: Color(0xFF175CD3),
                                ),
                              ),
                              Text(
                                courseTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'inter',
                                  color: Color(0xFF64748B),
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
              Expanded(
                child: BlocBuilder<AssignmentStudentCubit, AssignmentStudentState>(
                  builder: (context, state) {
                    if (state is AssignmentListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AssignmentListError) {
                      return _ErrorView(
                        message: state.message,
                        onRetry: () => context.read<AssignmentStudentCubit>().loadAssignments(courseId),
                      );
                    }
                    if (state is AssignmentListSuccess) {
                      if (state.assignments.isEmpty) {
                        return const _EmptyView();
                      }
                      return RefreshIndicator(
                        onRefresh: () => context.read<AssignmentStudentCubit>().loadAssignments(courseId),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
                            vertical: 8,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxWidth),
                              child: Column(
                                children: [
                                  for (final assignment in state.assignments)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _AssignmentCard(
                                        assignment: assignment,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AssignmentDetailScreen(
                                                assignmentId: assignment.id,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatefulWidget {
  const _AssignmentCard({required this.assignment, required this.onTap});
  final StudentAssignmentModel assignment;
  final VoidCallback onTap;

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;
    final statusColor = a.isSubmitted
        ? const Color(0xFF059669)
        : a.hasDeadlinePassed
            ? const Color(0xFFDC2626)
            : const Color(0xFFF59E0B);
    final statusBg = a.isSubmitted
        ? const Color(0xFFECFDF5)
        : a.hasDeadlinePassed
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFFFFBEB);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: hovered ? 0.1 : 0.04),
                blurRadius: hovered ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffE3F6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_rounded, color: Color(0xFF175CD3)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'inter',
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (a.description.isNotEmpty)
                      Text(
                        a.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'inter',
                          color: Color(0xFF64748B),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            a.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'inter',
                              color: statusColor,
                            ),
                          ),
                        ),
                        if (a.deadlineDate != null)
                          _MetaTag(
                            icon: Icons.event_rounded,
                            label: DateFormat('MMM d, y').format(a.deadlineDate!),
                          ),
                        _MetaTag(
                          icon: Icons.star_rounded,
                          label: '${a.maxGrade} pts',
                        ),
                        if (a.fileUrls.isNotEmpty)
                          _MetaTag(
                            icon: Icons.attach_file_rounded,
                            label: '${a.fileUrls.length} file${a.fileUrls.length > 1 ? 's' : ''}',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: 'inter',
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No assignments yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'inter',
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check back later — your instructor hasn\'t posted any.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontFamily: 'inter'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontFamily: 'inter', color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF175CD3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
