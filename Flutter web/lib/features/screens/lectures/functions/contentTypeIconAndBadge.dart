
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContentTypeIcon extends StatelessWidget {
  const ContentTypeIcon(this.type, {this.size = 36});
  final String type;
  final double size;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'video':
        icon = Icons.play_circle_fill_rounded;
        color = const Color(0xFF7C3AED);
        break;
      case 'audio':
        icon = Icons.headphones_rounded;
        color = const Color(0xFF059669);
        break;
      default:
        icon = Icons.picture_as_pdf_rounded;
        color = const Color(0xFFDC2626);
    }
    return Icon(icon, color: color, size: size);
  }
}

class ContentTypeBadge extends StatelessWidget {
  const ContentTypeBadge(this.type);
  final String type;

  Color get _color {
    switch (type.toLowerCase()) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Text(type,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: _color)),
    );
  }
}
