import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/lectures/functions/smallBadge.dart';

import '../model/model.dart';
import 'actionButton.dart';
import 'contentTypeIconAndBadge.dart';
import 'metaChip.dart';

class LectureTile extends StatefulWidget {

  const LectureTile({
    required this.lecture,
    required this.isDeleting,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });
  final LectureModel lecture;
  final bool isDeleting;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<LectureTile> createState() => LectureTileState();
}

class LectureTileState extends State<LectureTile> {
  bool _hovered = false;

  Color get _accent {
    switch (widget.lecture.contentType.toLowerCase()) {
      case 'video':
        return const Color(0xFF7C3AED);
      case 'audio':
        return const Color(0xFF059669);
      default:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lecture;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onView,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? _accent.withOpacity(0.35)
                  : const Color(0xFFE2E8F0),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
              BoxShadow(
                  color: _accent.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6))
            ]
                : [
              const BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2))
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),

                Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: ContentTypeIcon(l.contentType, size: 36)),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF175CD3).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('#${l.id}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF175CD3))),
                          ),
                          Expanded(
                            child: Text(l.title,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A))),
                          ),
                          if (l.hasSummary)
                            const SmallBadge('Summary', Color(0xFF059669)),
                          if (l.hasSummary && l.hasTranscript)
                            const SizedBox(width: 4),
                          if (l.hasTranscript)
                            const SmallBadge('Transcript', Color(0xFF7C3AED)),
                        ]),
                        const SizedBox(height: 4),
                        Text(l.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        Row(children: [
                          MetaChip(
                              Icons.person_outline_rounded, l.createdByName),
                          const SizedBox(width: 8),
                          MetaChip(Icons.calendar_today_outlined,
                              DateFormat('MMM d, yyyy').format(l.createdAt)),
                          const SizedBox(width: 8),
                          ContentTypeBadge(l.contentType),
                        ]),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionBtn(
                          icon: Icons.visibility_outlined,
                          tooltip: 'View Details',
                          color: const Color(0xFF175CD3),
                          onTap: widget.onView),
                      const SizedBox(height: 6),
                      ActionBtn(
                          icon: Icons.edit_outlined,
                          tooltip: 'Edit',
                          color: const Color(0xFF059669),
                          onTap: widget.onEdit),
                      const SizedBox(height: 6),
                      ActionBtn(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Delete',
                          color: const Color(0xFFEF4444),
                          onTap: widget.onDelete),
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


