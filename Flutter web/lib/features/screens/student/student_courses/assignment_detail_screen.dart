import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/student/student_courses/assignment_student_cubit.dart';
import 'package:lms/features/screens/student/student_courses/assignment_student_states.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/cons/Colors/app_colors.dart';

import 'student_assignment_model.dart';
import 'student_assignment_repository.dart';

String _fileUrl(String path) {
  if (path.startsWith('http')) return path;
  return 'https://skylearn.runasp.net$path';
}

String _fileNameFromUrl(String url) {
  final parts = url.split('/');
  return parts.isNotEmpty ? parts.last : url;
}

class AssignmentDetailScreen extends StatelessWidget {
  const AssignmentDetailScreen({super.key, required this.assignmentId});
  final int assignmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssignmentStudentCubit()..loadAssignmentDetail(assignmentId),
      child: _AssignmentDetailView(assignmentId: assignmentId),
    );
  }
}

class _AssignmentDetailView extends StatefulWidget {
  const _AssignmentDetailView({required this.assignmentId});
  final int assignmentId;

  @override
  State<_AssignmentDetailView> createState() => _AssignmentDetailViewState();
}

class _AssignmentDetailViewState extends State<_AssignmentDetailView> {
  final List<PlatformFile> _pickedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      _pickedFiles.addAll(result.files.where((f) => f.bytes != null));
    });
  }

  void _removeFile(int index) {
    setState(() => _pickedFiles.removeAt(index));
  }

  Future<void> _submit(BuildContext context) async {
    if (_pickedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach at least one file before submitting.')),
      );
      return;
    }
    final files = _pickedFiles
        .map((pf) => PickedSubmissionFile(
              name: pf.name,
              extension: pf.extension ?? pf.name.split('.').last,
              sizeBytes: pf.size,
              bytes: pf.bytes!,
            ))
        .toList();

    final ok = await context.read<AssignmentStudentCubit>().submitAssignment(
          assignmentId: widget.assignmentId,
          files: files,
        );

    if (ok && mounted) {
      setState(_pickedFiles.clear);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Assignment submitted successfully'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          child: BlocConsumer<AssignmentStudentCubit, AssignmentStudentState>(
            listener: (context, state) {
              if (state is AssignmentSubmitError) {
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
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 40 : (isMediumScreen ? 20 : 16),
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            const Text(
                              'Assignment Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'inter',
                                color: Color(0xFF175CD3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildBody(context, state),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AssignmentStudentState state) {
    if (state is AssignmentDetailLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is AssignmentDetailError) {
      return _ErrorBox(
        message: state.message,
        onRetry: () => context.read<AssignmentStudentCubit>().loadAssignmentDetail(widget.assignmentId),
      );
    }

    StudentAssignmentModel? assignment;
    if (state is AssignmentDetailSuccess) assignment = state.assignment;
    if (state is AssignmentSubmitting || state is AssignmentSubmitSuccess) {
      final cubit = context.read<AssignmentStudentCubit>();
      assignment ??= cubit.state is AssignmentDetailSuccess
          ? (cubit.state as AssignmentDetailSuccess).assignment
          : null;
    }

    if (assignment == null) return const SizedBox();

    final isSubmitting = state is AssignmentSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailHeaderCard(assignment: assignment),
        const SizedBox(height: 20),
        if (assignment.description.isNotEmpty)
          _SectionCard(
            title: 'Description',
            icon: Icons.description_rounded,
            child: Text(
              assignment.description,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'inter',
                color: Color(0xFF334155),
                height: 1.6,
              ),
            ),
          ),
        if (assignment.instructions.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Instructions',
            icon: Icons.menu_book_rounded,
            child: Text(
              assignment.instructions,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'inter',
                color: Color(0xFF334155),
                height: 1.6,
              ),
            ),
          ),
        ],
        if (assignment.fileUrls.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Attached Materials',
            icon: Icons.folder_open_rounded,
            child: Column(
              children: [
                for (final url in assignment.fileUrls)
                  _AttachmentTile(
                    fileName: _fileNameFromUrl(url),
                    onTap: () async {
                      final uri = Uri.parse(_fileUrl(url));
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _SubmissionSection(
          assignment: assignment,
          pickedFiles: _pickedFiles,
          isSubmitting: isSubmitting,
          submitProgress: isSubmitting ? state.progress : 0,
          onPickFiles: _pickFiles,
          onRemoveFile: _removeFile,
          onSubmit: () => _submit(context),
        ),
      ],
    );
  }
}

class _DetailHeaderCard extends StatelessWidget {
  const _DetailHeaderCard({required this.assignment});
  final StudentAssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    final statusColor = assignment.isSubmitted
        ? const Color(0xFF059669)
        : assignment.hasDeadlinePassed
            ? const Color(0xFFDC2626)
            : const Color(0xFFF59E0B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF175CD3), Color(0xFF4F8DFD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF175CD3).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'inter',
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  assignment.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'inter',
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _HeaderStat(icon: Icons.star_rounded, label: 'Max Grade', value: '${assignment.maxGrade} pts'),
              if (assignment.startDate != null)
                _HeaderStat(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Opens',
                  value: DateFormat('MMM d, y').format(assignment.startDate!),
                ),
              if (assignment.deadlineDate != null)
                _HeaderStat(
                  icon: Icons.event_busy_rounded,
                  label: 'Deadline',
                  value: DateFormat('MMM d, y · h:mm a').format(assignment.deadlineDate!),
                ),
              _HeaderStat(
                icon: Icons.update_rounded,
                label: 'Late Submission',
                value: assignment.allowLateSubmission ? 'Allowed' : 'Not allowed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'inter',
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'inter',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF175CD3)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'inter',
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.fileName, required this.onTap});
  final String fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_rounded, size: 18, color: Color(0xFF175CD3)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'inter',
                  color: Color(0xFF334155),
                ),
              ),
            ),
            const Icon(Icons.download_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _SubmissionSection extends StatelessWidget {

  const _SubmissionSection({
    required this.assignment,
    required this.pickedFiles,
    required this.isSubmitting,
    required this.submitProgress,
    required this.onPickFiles,
    required this.onRemoveFile,
    required this.onSubmit,
  });
  final StudentAssignmentModel assignment;
  final List<PlatformFile> pickedFiles;
  final bool isSubmitting;
  final double submitProgress;
  final VoidCallback onPickFiles;
  final void Function(int index) onRemoveFile;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final blocked = assignment.isSubmitted ||
        (assignment.hasDeadlinePassed && !assignment.allowLateSubmission);

    return _SectionCard(
      title: assignment.isSubmitted ? 'Your Submission' : 'Submit Your Work',
      icon: Icons.cloud_upload_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (assignment.isSubmitted)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You already submitted this assignment. Submitting again will replace your previous submission (if allowed).',
                      style: TextStyle(fontSize: 12, fontFamily: 'inter', color: Color(0xFF065F46)),
                    ),
                  ),
                ],
              ),
            )
          else if (blocked)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock_rounded, color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The deadline has passed and late submissions are not allowed for this assignment.',
                      style: TextStyle(fontSize: 12, fontFamily: 'inter', color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            ),
          if (!blocked) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: isSubmitting ? null : onPickFiles,
              borderRadius: BorderRadius.circular(12),
              child: DottedBorderBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    children: [
                      Icon(Icons.upload_file_rounded, size: 32, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'Click to attach files',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'inter',
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PDF, Word, PowerPoint, images, and more',
                        style: TextStyle(fontSize: 11, fontFamily: 'inter', color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (pickedFiles.isNotEmpty) ...[
              const SizedBox(height: 14),
              for (int i = 0; i < pickedFiles.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PickedFileRow(
                    file: pickedFiles[i],
                    onRemove: isSubmitting ? null : () => onRemoveFile(i),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            if (isSubmitting) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: submitProgress > 0 ? submitProgress : null,
                  minHeight: 8,
                  backgroundColor: const Color(0xffE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF175CD3)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Uploading... ${(submitProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12, fontFamily: 'inter', color: Color(0xFF64748B)),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(assignment.isSubmitted ? 'Resubmit' : 'Submit Assignment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF175CD3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'inter'),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PickedFileRow extends StatelessWidget {
  const _PickedFileRow({required this.file, this.onRemove});
  final PlatformFile file;
  final VoidCallback? onRemove;

  String _sizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_rounded, size: 18, color: Color(0xFF175CD3)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'inter'),
            ),
          ),
          Text(
            _sizeLabel(file.size),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'inter'),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 16, color: Color(0xFFDC2626)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffCBD5E1), width: 1.4),
        color: const Color(0xffF8FAFC),
      ),
      child: child,
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
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
      ),
    );
  }
}
