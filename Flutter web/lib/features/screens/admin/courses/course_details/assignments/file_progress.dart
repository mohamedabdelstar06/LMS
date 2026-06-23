import 'package:flutter/material.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';

class FileUploadProgressList extends StatelessWidget {

  const FileUploadProgressList({super.key, required this.progresses});
  final List<UploadFileProgress> progresses;

  @override
  Widget build(BuildContext context) {
    if (progresses.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0ECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF3B82F6),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Uploading ${progresses.length} file${progresses.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0ECFF)),
          ...progresses.map((p) => _FileProgressTile(progress: p)),
        ],
      ),
    );
  }
}

class _FileProgressTile extends StatelessWidget {
  const _FileProgressTile({required this.progress});
  final UploadFileProgress progress;

  String get _fileIcon {
    final ext = progress.fileName.split('.').last.toLowerCase();
    const icons = {
      'pdf': '📄',
      'doc': '📝',
      'docx': '📝',
      'pptx': '📊',
      'ppt': '📊',
      'xls': '📈',
      'xlsx': '📈',
      'jpg': '🖼️',
      'jpeg': '🖼️',
      'png': '🖼️',
      'zip': '🗜️',
      'rar': '🗜️',
    };
    return icons[ext] ?? '📎';
  }

  @override
  Widget build(BuildContext context) {
    final color = progress.hasError
        ? const Color(0xFFEF4444)
        : progress.isCompleted
        ? const Color(0xFF10B981)
        : const Color(0xFF3B82F6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_fileIcon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  progress.fileName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (progress.hasError)
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 18,
                )
              else if (progress.isCompleted)
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 18,
                )
              else
                Text(
                  '${(progress.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress.progress),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
          if (progress.hasError) ...[
            const SizedBox(height: 4),
            Text(
              'Upload failed — check your connection',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFFEF4444).withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
