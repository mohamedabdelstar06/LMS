import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/functions/smallBadge.dart';

import '../../../home_courses/model/model.dart';
import '../model/model.dart';
import 'actionButton.dart';
import 'add_ViewDialog.dart';
import 'contentTypeIconAndBadge.dart';
import 'fileTypeHelper.dart';
import 'fileViewer.dart';
import 'metaChip.dart';

class LectureTile extends StatefulWidget {
  const LectureTile({
    super.key,
    required this.lecture,
    required this.isDeleting,
    // required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onComments,
    required this.course,
  });

  final LectureModel lecture;
  final GetCoursesModel course;
  final bool isDeleting;

  // final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onComments;

  @override
  State<LectureTile> createState() => LectureTileState();
}

class LectureTileState extends State<LectureTile> {
  bool _hovered = false;

  String? get _mediaUrl => widget.lecture.fileUrl;

  bool get _hasMedia => _mediaUrl != null && _mediaUrl!.isNotEmpty;

  FileType get _fileType =>
      _hasMedia ? FileDetector().detect(_mediaUrl!) : FileType.unknown;

  Color get _accent {
    switch (_fileType) {
      case FileType.video:
        return const Color(0xFF7C3AED);

      case FileType.audio:
        return const Color(0xFF059669);

      case FileType.pdf:
        return const Color(0xFFEF4444);

      case FileType.excel:
        return const Color(0xFF16A34A);

      case FileType.word:
        return const Color(0xFF2563EB);

      case FileType.powerpoint:
        return const Color(0xFFF97316);

      case FileType.image:
        return const Color(0xFFDB2777);

      case FileType.text:
        return const Color(0xFF6B7280);

      case FileType.archive:
        return const Color(0xFF92400E);

      case FileType.unknown:
        return const Color(0xFFDC2626);
    }
  }

  IconData get _actionIcon {
    switch (_fileType) {
      case FileType.video:
        return Icons.play_circle_outline_rounded;

      case FileType.audio:
        return Icons.headphones_rounded;

      case FileType.pdf:
        return Icons.picture_as_pdf_outlined;

      case FileType.excel:
        return Icons.table_chart_rounded;

      case FileType.word:
        return Icons.description_outlined;

      case FileType.powerpoint:
        return Icons.slideshow_outlined;

      case FileType.image:
        return Icons.image_outlined;

      case FileType.text:
        return Icons.text_snippet_outlined;

      case FileType.archive:
        return Icons.folder_zip_outlined;

      case FileType.unknown:
        return Icons.visibility_outlined;
    }
  }

  String get _actionTooltip {
    switch (_fileType) {
      case FileType.video:
        return 'Watch Video';

      case FileType.audio:
        return 'Listen Audio';

      case FileType.pdf:
        return 'Open PDF';

      case FileType.excel:
        return 'Open Excel';

      case FileType.word:
        return 'Open Word Document';

      case FileType.powerpoint:
        return 'Open Presentation';

      case FileType.image:
        return 'View Image';

      case FileType.text:
        return 'Open Text File';

      case FileType.archive:
        return 'Download Archive';

      case FileType.unknown:
        return 'Open File';
    }
  }

  ///! TODO: For videos, consider embedding a video player instead of opening in a new tab. For PDFs, an inline viewer could enhance UX.

  void _handleMainTap() {
    if (!_hasMedia) {
      // widget.onView();
      return;
    }
    switch (_fileType) {
      case FileType.pdf:
      case FileType.unknown:
      case FileType.audio:
      case FileType.video:
      case FileType.excel:
      case FileType.word:
      case FileType.powerpoint:
      case FileType.image:
      case FileType.text:
      case FileType.archive:
        openInBrowserTab(_mediaUrl!);

      // navigateToFileViewer(
      //   context,
      //   fileUrl: _mediaUrl!,
      //   title: widget.lecture.title,
      //   description: widget.lecture.description,
      //   createdByName: widget.lecture.createdByName,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lecture;
    final course = widget.course;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        //!  onTap: _handleMainTap,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShowViewDialogScreen(lecture: l, course: course),
            ),
          );
        },
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
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAccentBar(),
                _buildIcon(l),
                Expanded(child: _buildContent(l)),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccentBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 2.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _hovered
              ? [_accent, _accent.withOpacity(0.6)]
              : [_accent.withOpacity(0.7), _accent.withOpacity(0.3)],
        ),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: _accent.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildIcon(LectureModel l) {
    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ContentTypeIcon(l.contentType, size: 36),
          if (_hasMedia)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(_actionIcon, color: Colors.white, size: 9),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(LectureModel l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF175CD3).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${l.title}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF175CD3),
                  ),
                ),
              ),
              // Expanded(
              //   child: Text(l.title,
              //       style: const TextStyle(
              //           fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              // ),
              if (l.hasSummary) const SmallBadge('Summary', Color(0xFF059669)),
              if (l.hasSummary && l.hasTranscript) const SizedBox(width: 4),
              if (l.hasTranscript)
                const SmallBadge('Transcript', Color(0xFF7C3AED)),
            ],
          ),
          // const SizedBox(height: 4),
          // Text(l.description,
          //     maxLines: 1,
          //     overflow: TextOverflow.ellipsis,
          //     style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              MetaChip(Icons.person_outline_rounded, l.createdByName),
              MetaChip(
                Icons.calendar_today_outlined,
                DateFormat('MMM d, yyyy').format(l.createdAt),
              ),
              ContentTypeBadge(l.contentType),
              // if (_hasMedia) _ActionBadge(accent: _accent, label: _actionTooltip),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ActionBtn(
          //   icon: Icons.visibility,
          //   tooltip: 'View',
          //   //! icon: _actionIcon,
          //  //! tooltip: _actionTooltip,
          //   color: const Color(0xFF175CD3),
          //   onTap: _handleMainTap,
          // ),
          const SizedBox(height: 6),
          ActionBtn(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            color: const Color(0xFF059669),
            onTap: widget.onEdit,
          ),
          const SizedBox(height: 6),
          _CommentsBtn(onTap: widget.onComments),
          const SizedBox(height: 6),
          ActionBtn(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete',
            color: const Color(0xFFEF4444),
            onTap: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

class _CommentsBtn extends StatefulWidget {
  const _CommentsBtn({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_CommentsBtn> createState() => _CommentsBtnState();
}

class _CommentsBtnState extends State<_CommentsBtn> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: Tooltip(
        message: 'Comments',
        preferBelow: false,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 11),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hov
                  ? const Color(0xFF0EA5E9).withOpacity(0.12)
                  : const Color(0xFF0EA5E9).withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hov
                    ? const Color(0xFF0EA5E9).withOpacity(0.5)
                    : const Color(0xFF0EA5E9).withOpacity(0.2),
              ),
            ),
            child: AnimatedScale(
              scale: _hov ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 15,
                color: Color(0xFF0EA5E9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.accent, required this.label});

  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.open_in_new_rounded, size: 10, color: accent),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
