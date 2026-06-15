import 'package:flutter/material.dart';
import 'package:lms/features/screens/admin/courses/course_details/assignments/assignment_model.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewSubmissions;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onViewSubmissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0ECFF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: Color(0xFF3B82F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (assignment.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            assignment.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                      if (value == 'submissions') onViewSubmissions?.call();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onViewSubmissions != null)
                        const PopupMenuItem(
                          value: 'submissions',
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 16,
                                color: Color(0xFF8B5CF6),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Submissions',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Meta row
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.grade_rounded,
                    label: '${assignment.maxGrade} pts',
                    color: const Color(0xFF059669),
                    bg: const Color(0xFFECFDF5),
                  ),
                  const SizedBox(width: 8),
                  if (assignment.files.isNotEmpty)
                    _MetaChip(
                      icon: Icons.attach_file_rounded,
                      label:
                          '${assignment.files.length} file${assignment.files.length > 1 ? 's' : ''}',
                      color: const Color(0xFF3B82F6),
                      bg: const Color(0xFFEFF6FF),
                    ),
                  if (assignment.files.isNotEmpty) const SizedBox(width: 8),
                  if (assignment.allowLateSubmission)
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      label: 'Late allowed',
                      color: const Color(0xFFF59E0B),
                      bg: const Color(0xFFFEF3C7),
                    ),
                  const Spacer(),
                  if (!assignment.isVisible)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.visibility_off_outlined,
                            size: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Hidden',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
