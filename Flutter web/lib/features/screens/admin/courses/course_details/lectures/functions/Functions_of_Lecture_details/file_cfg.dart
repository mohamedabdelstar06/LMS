
import 'package:flutter/material.dart';

class FileCfg {
  const FileCfg(this.icon, this.color, this.bg);

  final IconData icon;
  final Color color;
  final Color bg;
}

FileCfg fileCfg(String ext) {
  switch (ext) {
    case 'mp4':
    case 'mov':
    case 'avi':
    case 'mkv':
    case 'webm':
      return const FileCfg(
        Icons.videocam_rounded,
        Color(0xFF7C3AED),
        Color(0xFFF3E8FF),
      );
    case 'mp3':
    case 'wav':
    case 'aac':
    case 'm4a':
      return const FileCfg(
        Icons.audiotrack_rounded,
        Color(0xFFDB2777),
        Color(0xFFFCE7F3),
      );
    case 'pdf':
      return const FileCfg(
        Icons.picture_as_pdf_rounded,
        Color(0xFFDC2626),
        Color(0xFFFEE2E2),
      );
    case 'xls':
    case 'xlsx':
    case 'csv':
      return const FileCfg(
        Icons.table_chart_rounded,
        Color(0xFF059669),
        Color(0xFFD1FAE5),
      );
    case 'doc':
    case 'docx':
      return const FileCfg(
        Icons.description_rounded,
        Color(0xFF1D4ED8),
        Color(0xFFDBEAFE),
      );
    case 'ppt':
    case 'pptx':
      return const FileCfg(
        Icons.slideshow_rounded,
        Color(0xFFEA580C),
        Color(0xFFFFEDD5),
      );
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
    case 'svg':
      return const FileCfg(
        Icons.image_rounded,
        Color(0xFF0891B2),
        Color(0xFFCFFAFE),
      );
    case 'zip':
    case 'rar':
    case '7z':
    case 'tar':
    case 'gz':
      return const FileCfg(
        Icons.folder_zip_rounded,
        Color(0xFFD97706),
        Color(0xFFFEF3C7),
      );
    default:
      return const FileCfg(
        Icons.insert_drive_file_rounded,
        Color(0xFF0284C7),
        Color(0xFFE0F2FE),
      );
  }
}