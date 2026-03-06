import 'package:flutter/material.dart';

class ContentTypePill extends StatelessWidget {
  const ContentTypePill({super.key, required this.type});

  final String type;

  _PillStyle get _style {
    switch (type.toLowerCase()) {
      case 'video':
        return _PillStyle(Icons.videocam_rounded, const Color(0xFFA78BFA));
      case 'audio':
        return _PillStyle(Icons.headphones_rounded, const Color(0xFFF472B6));
      case 'pdf':
        return _PillStyle(
          Icons.picture_as_pdf_rounded,
          const Color(0xFFFCA5A5),
        );
      case 'mixed':
        return _PillStyle(Icons.auto_awesome_rounded, const Color(0xFF67E8F9));
      default:
        return _PillStyle(
          Icons.insert_drive_file_rounded,
          const Color(0xFF93C5FD),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: s.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 13, color: s.color),
          const SizedBox(width: 5),
          Text(
            type,
            style: TextStyle(
              color: s.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
class _PillStyle {
  _PillStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}
