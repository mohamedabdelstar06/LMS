import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/model.dart';
import 'chip.dart';

class MetaStrip extends StatelessWidget {
  const MetaStrip({super.key, required this.lecture});

  final LectureModel lecture;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChipCard(
          Icons.calendar_today_outlined,
          DateFormat('MMM d, yyyy').format(lecture.createdAt),
          const Color(0xFF0369A1),
        ),
        ChipCard(
          lecture.hasSummary
              ? Icons.summarize_rounded
              : Icons.summarize_outlined,
          lecture.hasSummary ? 'Has Summary' : 'No Summary',
          lecture.hasSummary
              ? const Color(0xFF059669)
              : const Color(0xFF94A3B8),
        ),
        ChipCard(
          lecture.hasTranscript
              ? Icons.closed_caption_rounded
              : Icons.closed_caption_disabled_rounded,
          lecture.hasTranscript ? 'Transcript' : 'No Transcript',
          lecture.hasTranscript
              ? const Color(0xFF7C3AED)
              : const Color(0xFF94A3B8),
        ),
        if (lecture.isViewed == true)
          const ChipCard(Icons.visibility_rounded, 'Viewed', Color(0xFF0284C7)),
      ],
    );
  }
}
