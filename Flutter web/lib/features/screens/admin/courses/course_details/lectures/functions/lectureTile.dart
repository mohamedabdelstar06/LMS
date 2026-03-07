import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/functions/smallBadge.dart';

import '../../../home_courses/model/model.dart';
import '../model/model.dart';
import 'actionButton.dart';
import 'add_ViewDialog.dart';
import 'contentTypeIconAndBadge.dart';
import 'fileTypeHelper.dart';
import 'metaChip.dart';

class LectureTile extends StatefulWidget {
  const LectureTile({
    super.key,
    required this.lecture,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
    required this.onComments,
    required this.course,
  });

  final LectureModel lecture;
  final GetCoursesModel course;
  final bool isDeleting;
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
      case FileType.video:      return const Color(0xFF7C3AED);
      case FileType.audio:      return const Color(0xFF059669);
      case FileType.pdf:        return const Color(0xFFEF4444);
      case FileType.excel:      return const Color(0xFF16A34A);
      case FileType.word:       return const Color(0xFF2563EB);
      case FileType.powerpoint: return const Color(0xFFF97316);
      case FileType.image:      return const Color(0xFFDB2777);
      case FileType.text:       return const Color(0xFF6B7280);
      case FileType.archive:    return const Color(0xFF92400E);
      case FileType.unknown:    return const Color(0xFF4361EE);
    }
  }

  IconData get _typeIcon {
    switch (_fileType) {
<<<<<<< HEAD
      case FileType.video:      return Icons.play_circle_fill_rounded;
      case FileType.audio:      return Icons.headphones_rounded;
      case FileType.pdf:        return Icons.picture_as_pdf_rounded;
      case FileType.excel:      return Icons.table_chart_rounded;
      case FileType.word:       return Icons.description_rounded;
      case FileType.powerpoint: return Icons.slideshow_rounded;
      case FileType.image:      return Icons.image_rounded;
      case FileType.text:       return Icons.text_snippet_rounded;
      case FileType.archive:    return Icons.folder_zip_rounded;
      case FileType.unknown:    return Icons.insert_drive_file_rounded;
=======
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
>>>>>>> 064128c30de0e5f4887896a8b9a29bf77281ff35
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lecture;
    final hasThumb = l.thumbnailUrl != null && l.thumbnailUrl!.isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ShowViewDialogScreen(lecture: l, course: widget.course),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? _accent.withOpacity(0.45)
                  : const Color(0xFFE2E8F0),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
              BoxShadow(
                color: _accent.withOpacity(0.13),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ]
                : [
              const BoxShadow(
                color: Color(0x09000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(l, hasThumb),
              _buildBody(l),
              _buildFooter(l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(LectureModel l, bool hasThumb) {
    final isImage = _fileType == FileType.image;
    final showNetworkImage = hasThumb || isImage;
    final imageUrl = hasThumb ? l.thumbnailUrl! : (isImage ? l.fileUrl : null);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: SizedBox(
        height: 108,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showNetworkImage && imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultThumb(),
              )
            else
              _buildDefaultThumb(),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _accent.withOpacity(0.55),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon, color: Colors.white, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      l.contentType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (l.hasSummary || l.hasTranscript)
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    if (l.hasSummary)
                      const _ThumbBadge('S', Color(0xFF059669)),
                    if (l.hasSummary && l.hasTranscript)
                      const SizedBox(width: 4),
                    if (l.hasTranscript)
                      const _ThumbBadge('T', Color(0xFF7C3AED)),
                  ],
                ),
              ),

            Positioned(
              bottom: 10,
              left: 10,
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded,
                      color: Colors.white70, size: 11),
                  const SizedBox(width: 4),
                  Text(
                    l.createdByName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultThumb() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accent.withOpacity(0.12),
            _accent.withOpacity(0.22),
          ],
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _accent.withOpacity(_hovered ? 0.2 : 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_typeIcon, color: _accent, size: 32),
        ),
      ),
    );
  }

  Widget _buildBody(LectureModel l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Text(
        l.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildFooter(LectureModel l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 10),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 11, color: Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM d, yyyy').format(l.createdAt),
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const Spacer(),
          _ActionIconBtn(
            icon: Icons.edit_outlined,
            color: const Color(0xFF059669),
            tooltip: 'Edit',
            onTap: widget.onEdit,
          ),
          const SizedBox(width: 4),
          _ActionIconBtn(
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF0EA5E9),
            tooltip: 'Comments',
            onTap: widget.onComments,
          ),
          const SizedBox(width: 4),
          _ActionIconBtn(
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFFEF4444),
            tooltip: 'Delete',
            onTap: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
class _ThumbBadge extends StatelessWidget {
  const _ThumbBadge(this.label, this.color);
  final String label;
  final Color color;
=======
class _CommentsBtn extends StatefulWidget {
  const _CommentsBtn({required this.onTap});
  final VoidCallback onTap;
>>>>>>> 064128c30de0e5f4887896a8b9a29bf77281ff35

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ActionIconBtn extends StatefulWidget {
  const _ActionIconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_ActionIconBtn> createState() => _ActionIconBtnState();
}

class _ActionIconBtnState extends State<_ActionIconBtn> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: Tooltip(
        message: widget.tooltip,
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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _hov
                  ? widget.color.withOpacity(0.12)
                  : widget.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: _hov
                    ? widget.color.withOpacity(0.45)
                    : widget.color.withOpacity(0.15),
              ),
            ),
            child: AnimatedScale(
              scale: _hov ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(widget.icon, size: 14, color: widget.color),
            ),
          ),
        ),
      ),
    );
  }
}