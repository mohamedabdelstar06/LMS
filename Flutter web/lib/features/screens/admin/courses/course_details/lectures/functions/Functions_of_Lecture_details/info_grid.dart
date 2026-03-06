import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/model.dart';
import 'card_title.dart';
import 'info_tile.dart';

class InfoGrid extends StatelessWidget {
  const InfoGrid({super.key, required this.lecture});

  final LectureModel lecture;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(Icons.info_outline_rounded, 'Details'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InfoTile(
                  icon: Icons.tag_rounded,
                  label: 'Lecture ID',
                  value: '${lecture.id}',
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InfoTile(
                  icon: Icons.book_rounded,
                  label: 'Course ID',
                  value: '${lecture.courseId}',
                  color: const Color(0xFF0369A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InfoTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Created',
                  value: DateFormat('MMM d, yyyy').format(lecture.createdAt),
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InfoTile(
                  icon: Icons.update_rounded,
                  label: 'Updated',
                  value: lecture.updatedAt != null
                      ? DateFormat('MMM d, yyyy').format(lecture.updatedAt!)
                      : 'Never',
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          if (lecture.viewedAt != null) ...[
            const SizedBox(height: 10),
            InfoTile(
              icon: Icons.visibility_rounded,
              label: 'Viewed At',
              value: DateFormat(
                'MMM d, yyyy – hh:mm a',
              ).format(lecture.viewedAt!),
              color: const Color(0xFF0284C7),
            ),
          ],
        ],
      ),
    );
  }
}
