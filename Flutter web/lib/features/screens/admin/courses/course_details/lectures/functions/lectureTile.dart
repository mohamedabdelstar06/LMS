import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/admin/courses/course_details/lectures/functions/smallBadge.dart';

import '../model/model.dart';
import 'actionButton.dart';
import 'contentTypeIconAndBadge.dart';
import 'fileTypeHelper.dart';
import 'fileViewer.dart';
import 'metaChip.dart';

class LectureTile extends StatefulWidget {
  const LectureTile({
    super.key,
    required this.lecture,
    required this.isDeleting,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onComments,
  });

  final LectureModel lecture;
  final bool isDeleting;
  final VoidCallback onView;
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
  FileType get _fileType => _hasMedia ? detectFileType(_mediaUrl!) : FileType.unknown;

  Color get _accent {
    switch (_fileType) {
      case FileType.video:   return const Color(0xFF7C3AED);
      case FileType.audio:   return const Color(0xFF059669);
      case FileType.pdf:     return const Color(0xFFEF4444);
      case FileType.unknown: return const Color(0xFFDC2626);
    }
  }

  IconData get _actionIcon {
    switch (_fileType) {
      case FileType.video:   return Icons.play_circle_outline_rounded;
      case FileType.audio:   return Icons.headphones_rounded;
      case FileType.pdf:     return Icons.picture_as_pdf_outlined;
      case FileType.unknown: return Icons.visibility_outlined;
    }
  }

  String get _actionTooltip {
    switch (_fileType) {
      case FileType.video:   return 'Watch Video';
      case FileType.audio:   return 'Listen';
      case FileType.pdf:     return 'Open PDF';
      case FileType.unknown: return 'View Details';
    }
  }

  void _handleMainTap() {
    if (!_hasMedia) { widget.onView(); return; }
    switch (_fileType) {
      case FileType.pdf:
      case FileType.unknown:
        openInBrowserTab(_mediaUrl!);
      case FileType.video:
      case FileType.audio:
        navigateToFileViewer(
          context,
          fileUrl: _mediaUrl!,
          title: widget.lecture.title,
          description: widget.lecture.description,
          createdByName: widget.lecture.createdByName,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lecture;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _handleMainTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? _accent.withOpacity(0.35) : const Color(0xFFE2E8F0),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: _accent.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 6))]
                : [const BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
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
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        ),
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
                child: Text('#${l.id}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF175CD3))),
              ),
              Expanded(
                child: Text(l.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ),
              if (l.hasSummary) const SmallBadge('Summary', Color(0xFF059669)),
              if (l.hasSummary && l.hasTranscript) const SizedBox(width: 4),
              if (l.hasTranscript) const SmallBadge('Transcript', Color(0xFF7C3AED)),
            ],
          ),
          const SizedBox(height: 4),
          Text(l.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              MetaChip(Icons.person_outline_rounded, l.createdByName),
              MetaChip(Icons.calendar_today_outlined,
                  DateFormat('MMM d, yyyy').format(l.createdAt)),
              ContentTypeBadge(l.contentType),
              if (_hasMedia) _ActionBadge(accent: _accent, label: _actionTooltip),
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
          ActionBtn(
            icon: _actionIcon,
            tooltip: _actionTooltip,
            color: const Color(0xFF175CD3),
            onTap: _handleMainTap,
          ),
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
  final VoidCallback onTap;
  const _CommentsBtn({required this.onTap});

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
  final Color accent;
  final String label;
  const _ActionBadge({required this.accent, required this.label});

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