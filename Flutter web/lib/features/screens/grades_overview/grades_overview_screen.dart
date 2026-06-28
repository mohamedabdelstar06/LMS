import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/management/management_layout.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';

import 'course_grades_model.dart';
import 'grades_overview_cubit.dart';
import 'grades_overview_states.dart';

const _kBg = Color(0xFFF0F6FF);
const _kCard = Colors.white;
const _kBlue = Color(0xFF2563EB);
const _kGreen = Color(0xFF10B981);
const _kOrange = Color(0xFFF59E0B);
const _kPurple = Color(0xFF7C3AED);
const _kRed = Color(0xFFEF4444);
const _kText = Color(0xFF0F172A);
const _kSub = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

class GradesOverviewScreen extends StatelessWidget {
  const GradesOverviewScreen({
    super.key,
    this.role,
    this.isStudent = false,
  });

  final ManagementRole? role;
  final bool isStudent;

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider(
      create: (_) => GradesOverviewCubit(isStudent: isStudent)..loadCourses(),
      child: const _GradesOverviewBody(),
    );

    if (role == null) {
      return Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kCard,
          elevation: 0,
          foregroundColor: _kText,
          title: const Text(
            'Grades Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        body: body,
      );
    }

    return ManagementScaffold(
      selectedMenuItem: 'Grades overview',
      role: role!,
      child: body,
    );
  }
}

class _GradesOverviewBody extends StatelessWidget {
  const _GradesOverviewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GradesOverviewCubit, GradesOverviewState>(
      builder: (context, state) {
        if (state is GradesOverviewLoading || state is GradesOverviewInitial) {
          return const Center(
            child: CircularProgressIndicator(color: _kBlue),
          );
        }

        if (state is GradesOverviewError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context.read<GradesOverviewCubit>().loadCourses(),
          );
        }

        if (state is GradesOverviewCoursesLoaded) {
          return _CourseSelectionView(courses: state.courses);
        }

        if (state is GradesOverviewGradesLoaded) {
          return _GradesDashboard(
            courses: state.courses,
            selectedCourse: state.selectedCourse,
            grades: state.grades,
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _CourseSelectionView extends StatelessWidget {
  const _CourseSelectionView({required this.courses});
  final List<CourseOption> courses;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assessment_rounded,
                color: _kBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Grades Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _kText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              courses.isEmpty
                  ? 'No courses available.'
                  : 'Select a course to view student grades dashboard.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _kSub),
            ),
            const SizedBox(height: 28),
            if (courses.isNotEmpty) _CourseDropdown(courses: courses),
          ],
        ),
      ),
    );
  }
}

class _CourseDropdown extends StatefulWidget {
  const _CourseDropdown({required this.courses});
  final List<CourseOption> courses;

  @override
  State<_CourseDropdown> createState() => _CourseDropdownState();
}

class _CourseDropdownState extends State<_CourseDropdown> {
  CourseOption? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CourseOption>(
              value: _selected,
              isExpanded: true,
              hint: const Text(
                'Choose a course',
                style: TextStyle(color: _kSub, fontSize: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kSub),
              items: widget.courses.map((course) {
                return DropdownMenuItem<CourseOption>(
                  value: course,
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (course) {
                if (course == null) return;
                setState(() => _selected = course);
                context.read<GradesOverviewCubit>().selectCourse(course);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _selected == null
              ? null
              : () => context.read<GradesOverviewCubit>().selectCourse(_selected!),
          icon: const Icon(Icons.dashboard_rounded, size: 18),
          label: const Text('Open Dashboard'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradesDashboard extends StatelessWidget {
  const _GradesDashboard({
    required this.courses,
    required this.selectedCourse,
    required this.grades,
  });

  final List<CourseOption> courses;
  final CourseOption selectedCourse;
  final CourseGradesOverviewModel grades;

  @override
  Widget build(BuildContext context) {
    final students = grades.students;
    final avgLectureProgress = students.isEmpty
        ? 0.0
        : students.map((s) => s.lectureProgressPercent).reduce((a, b) => a + b) /
            students.length;

    final allQuizzes = students.expand((s) => s.quizGrades).toList();
    final avgQuiz = allQuizzes.isEmpty
        ? 0.0
        : allQuizzes.map((q) => q.scorePercent).reduce((a, b) => a + b) /
            allQuizzes.length;

    final allAssignments = students.expand((s) => s.assignmentGrades).toList();
    final gradedAssignments =
        allAssignments.where((a) => a.grade != null).toList();
    final avgAssignment = gradedAssignments.isEmpty
        ? null
        : gradedAssignments.map((a) => a.gradePercent).reduce((a, b) => a + b) /
            gradedAssignments.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(
            courses: courses,
            selectedCourse: selectedCourse,
          ),
          const SizedBox(height: 24),
          _SummaryCards(
            totalStudents: grades.totalStudents,
            avgLectureProgress: avgLectureProgress,
            avgQuiz: avgQuiz,
            avgAssignment: avgAssignment,
            totalQuizzes: allQuizzes.length,
            totalAssignments: allAssignments.length,
          ),
          const SizedBox(height: 24),
          _StudentsTable(students: students),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.courses,
    required this.selectedCourse,
  });
  final List<CourseOption> courses;
  final CourseOption selectedCourse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Grades',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kSub,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedCourse.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 240,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CourseOption>(
                  value: selectedCourse,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kSub),
                  items: courses.map((course) {
                    return DropdownMenuItem<CourseOption>(
                      value: course,
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (course) {
                    if (course == null) return;
                    context.read<GradesOverviewCubit>().selectCourse(course);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => context.read<GradesOverviewCubit>().refreshSelectedCourse(),
            icon: const Icon(Icons.refresh_rounded, color: _kSub),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.totalStudents,
    required this.avgLectureProgress,
    required this.avgQuiz,
    required this.avgAssignment,
    required this.totalQuizzes,
    required this.totalAssignments,
  });

  final int totalStudents;
  final double avgLectureProgress;
  final double avgQuiz;
  final double? avgAssignment;
  final int totalQuizzes;
  final int totalAssignments;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryData(
        label: 'Total Students',
        value: totalStudents.toString(),
        sub: 'enrolled',
        color: _kBlue,
        icon: Icons.groups_rounded,
      ),
      _SummaryData(
        label: 'Lecture Progress',
        value: '${avgLectureProgress.toStringAsFixed(1)}%',
        sub: 'average',
        color: _kGreen,
        icon: Icons.play_circle_filled_rounded,
      ),
      _SummaryData(
        label: 'Quiz Score',
        value: '${avgQuiz.toStringAsFixed(1)}%',
        sub: '$totalQuizzes attempts',
        color: _kPurple,
        icon: Icons.quiz_rounded,
      ),
      _SummaryData(
        label: 'Assignment Score',
        value: avgAssignment == null ? '-' : '${avgAssignment!.toStringAsFixed(1)}%',
        sub: '$totalAssignments submitted',
        color: _kOrange,
        icon: Icons.assignment_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((card) {
            return SizedBox(
              width: isWide
                  ? (constraints.maxWidth - 48) / 4
                  : (constraints.maxWidth - 16) / 2,
              child: _SummaryCard(data: card),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SummaryData {
  const _SummaryData({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});
  final _SummaryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: const TextStyle(fontSize: 12, color: _kSub, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            data.sub,
            style: TextStyle(fontSize: 11, color: _kSub.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _StudentsTable extends StatelessWidget {
  const _StudentsTable({required this.students});
  final List<StudentCourseGradeModel> students;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Student Grades',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _kText,
              ),
            ),
          ),
          if (students.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No students found for this course.',
                  style: TextStyle(color: _kSub),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                dataRowMinHeight: 56,
                dataRowMaxHeight: 64,
                columns: const [
                  DataColumn(label: Text('Student', style: _headerStyle)),
                  DataColumn(label: Text('Progress', style: _headerStyle)),
                  DataColumn(label: Text('Quizzes', style: _headerStyle)),
                  DataColumn(label: Text('Assignments', style: _headerStyle)),
                  DataColumn(label: Text('Details', style: _headerStyle)),
                ],
                rows: students.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          student.studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                        ),
                      ),
                      DataCell(_ProgressBadge(value: student.lectureProgressPercent)),
                      DataCell(_ScoreBadge(
                        value: student.averageQuizPercent,
                        label: '${student.quizGrades.length}',
                      )),
                      DataCell(_ScoreBadge(
                        value: student.averageAssignmentPercent ?? 0,
                        label: '${student.assignmentGrades.length}',
                        isNeutral: student.averageAssignmentPercent == null,
                      )),
                      DataCell(
                        TextButton(
                          onPressed: () => _showStudentDetails(context, student),
                          child: const Text('View'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: _kSub,
  );

  void _showStudentDetails(BuildContext context, StudentCourseGradeModel student) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
          child: _StudentDetailsDialog(student: student),
        ),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = value >= 75
        ? _kGreen
        : value >= 50
            ? _kOrange
            : _kRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${value.toStringAsFixed(0)}%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({
    required this.value,
    required this.label,
    this.isNeutral = false,
  });
  final double value;
  final String label;
  final bool isNeutral;

  @override
  Widget build(BuildContext context) {
    final color = isNeutral
        ? _kSub
        : value >= 75
            ? _kGreen
            : value >= 50
                ? _kOrange
                : _kRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isNeutral ? '$label submitted' : '${value.toStringAsFixed(0)}% ($label)',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StudentDetailsDialog extends StatelessWidget {
  const _StudentDetailsDialog({required this.student});
  final StudentCourseGradeModel student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCard,
      appBar: AppBar(
        backgroundColor: _kCard,
        elevation: 0,
        foregroundColor: _kText,
        title: Text(
          student.studentName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DetailSectionTitle(title: 'Lecture Progress'),
            const SizedBox(height: 8),
            _DetailProgress(value: student.lectureProgressPercent),
            const SizedBox(height: 24),
            if (student.quizGrades.isNotEmpty) ...[
              const _DetailSectionTitle(title: 'Quizzes'),
              const SizedBox(height: 12),
              ...student.quizGrades.map((q) => _QuizDetailItem(quiz: q)),
              const SizedBox(height: 24),
            ],
            if (student.assignmentGrades.isNotEmpty) ...[
              const _DetailSectionTitle(title: 'Assignments'),
              const SizedBox(height: 12),
              ...student.assignmentGrades.map((a) => _AssignmentDetailItem(assignment: a)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: _kSub,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _DetailProgress extends StatelessWidget {
  const _DetailProgress({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: _kBorder,
            valueColor: AlwaysStoppedAnimation(
              value >= 75 ? _kGreen : value >= 50 ? _kOrange : _kRed,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${value.toStringAsFixed(1)}% viewed',
          style: const TextStyle(fontSize: 12, color: _kSub),
        ),
      ],
    );
  }
}

class _QuizDetailItem extends StatelessWidget {
  const _QuizDetailItem({required this.quiz});
  final QuizGradeModel quiz;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.quizTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${quiz.score.toStringAsFixed(0)} / ${quiz.maxScore.toStringAsFixed(0)}  •  ${quiz.status}',
                  style: const TextStyle(fontSize: 12, color: _kSub),
                ),
              ],
            ),
          ),
          _ProgressBadge(value: quiz.scorePercent),
        ],
      ),
    );
  }
}

class _AssignmentDetailItem extends StatelessWidget {
  const _AssignmentDetailItem({required this.assignment});
  final AssignmentGradeModel assignment;

  @override
  Widget build(BuildContext context) {
    final isGraded = assignment.grade != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.assignmentTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGraded
                      ? '${assignment.grade!.toStringAsFixed(0)} / ${assignment.maxGrade.toStringAsFixed(0)}  •  ${assignment.status}'
                      : 'Not graded  •  ${assignment.status}',
                  style: const TextStyle(fontSize: 12, color: _kSub),
                ),
              ],
            ),
          ),
          if (isGraded)
            _ProgressBadge(value: assignment.gradePercent)
          else
            const _ScoreBadge(value: 0, label: 'Pending', isNeutral: true),
        ],
      ),
    );
  }
}

class AdminGradesOverviewScreen extends StatelessWidget {
  const AdminGradesOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradesOverviewScreen(role: ManagementRole.admin);
  }
}

class InstructorGradesOverviewScreen extends StatelessWidget {
  const InstructorGradesOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradesOverviewScreen(role: ManagementRole.instructor);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: _kRed, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kSub, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
