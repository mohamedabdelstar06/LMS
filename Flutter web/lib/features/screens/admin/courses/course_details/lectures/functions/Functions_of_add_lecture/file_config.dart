import 'package:flutter/material.dart';

Widget labelField(String text) => Text(
  text,
  style: TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.blue.shade900,
  ),
);


String sizeLabel(int size) {
  if (size < 1024) return '$size B';
  if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
  return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
}

IconData typeIconFor(String type) {
  switch (type.toLowerCase()) {
    case 'video':
      return Icons.videocam_rounded;
    case 'audio':
      return Icons.headphones_rounded;
    case 'image':
      return Icons.image_rounded;
    default:
      return Icons.picture_as_pdf_rounded;
  }
}

void snack(BuildContext ctx, String msg, Color color, IconData icon) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}

enum FileCategory {
  video, audio, pdf, excel, word, powerpoint, image, text, archive, other,
}

class CatConfig {
  const CatConfig(this.icon, this.color, this.bg, this.label);
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
}

const catMap = <FileCategory, CatConfig>{
  FileCategory.video:      CatConfig(Icons.videocam_rounded,         Color(0xFF7C3AED), Color(0xFFF3E8FF), 'Video'),
  FileCategory.audio:      CatConfig(Icons.audiotrack_rounded,       Color(0xFFDB2777), Color(0xFFFCE7F3), 'Audio'),
  FileCategory.pdf:        CatConfig(Icons.picture_as_pdf_rounded,   Color(0xFFDC2626), Color(0xFFFEE2E2), 'PDF'),
  FileCategory.excel:      CatConfig(Icons.table_chart_rounded,      Color(0xFF059669), Color(0xFFD1FAE5), 'Excel'),
  FileCategory.word:       CatConfig(Icons.description_rounded,      Color(0xFF1D4ED8), Color(0xFFDBEAFE), 'Word'),
  FileCategory.powerpoint: CatConfig(Icons.slideshow_rounded,        Color(0xFFEA580C), Color(0xFFFFEDD5), 'PowerPoint'),
  FileCategory.image:      CatConfig(Icons.image_rounded,            Color(0xFF0891B2), Color(0xFFCFFAFE), 'Image'),
  FileCategory.text:       CatConfig(Icons.text_snippet_rounded,     Color(0xFF64748B), Color(0xFFF1F5F9), 'Text'),
  FileCategory.archive:    CatConfig(Icons.folder_zip_rounded,       Color(0xFFD97706), Color(0xFFFEF3C7), 'Archive'),
  FileCategory.other:      CatConfig(Icons.insert_drive_file_rounded, Color(0xFF64748B), Color(0xFFF1F5F9), 'File'),
};

FileCategory categoryFromExt(String ext) {
  const map = {
    'mp4': FileCategory.video, 'mov': FileCategory.video,
    'avi': FileCategory.video, 'mkv': FileCategory.video,
    'webm': FileCategory.video,
    'mp3': FileCategory.audio, 'wav': FileCategory.audio,
    'aac': FileCategory.audio, 'm4a': FileCategory.audio,
    'pdf': FileCategory.pdf,
    'xls': FileCategory.excel, 'xlsx': FileCategory.excel,
    'csv': FileCategory.excel,
    'doc': FileCategory.word, 'docx': FileCategory.word,
    'ppt': FileCategory.powerpoint, 'pptx': FileCategory.powerpoint,
    'jpg': FileCategory.image, 'jpeg': FileCategory.image,
    'png': FileCategory.image, 'gif': FileCategory.image,
    'webp': FileCategory.image, 'svg': FileCategory.image,
    'txt': FileCategory.text, 'md': FileCategory.text,
    'zip': FileCategory.archive, 'rar': FileCategory.archive,
    '7z': FileCategory.archive, 'tar': FileCategory.archive,
    'gz': FileCategory.archive,
  };
  return map[ext] ?? FileCategory.other;
}

const allowedExtensions = [
  'mp4', 'mov', 'avi', 'mkv', 'webm',
  'mp3', 'wav', 'aac', 'm4a',
  'pdf', 'xls', 'xlsx', 'csv',
  'doc', 'docx', 'ppt', 'pptx',
  'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg',
  'txt', 'md', 'zip', 'rar', '7z', 'tar', 'gz',
];