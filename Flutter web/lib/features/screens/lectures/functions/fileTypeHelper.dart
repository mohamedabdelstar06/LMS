import 'dart:html' as html;

const String _baseUrl = 'https://skylearn.runasp.net';

enum FileType { video, audio, pdf, unknown }

FileType detectFileType(String url) {
  final lower = url.toLowerCase().split('?').first;
  if (lower.endsWith('.mp4') || lower.endsWith('.webm') ||
      lower.endsWith('.mov') || lower.endsWith('.avi') ||
      lower.endsWith('.mkv') || lower.endsWith('.ogg')) {
    return FileType.video;
  }
  if (lower.endsWith('.mp3') || lower.endsWith('.wav') ||
      lower.endsWith('.aac') || lower.endsWith('.flac') ||
      lower.endsWith('.m4a') || lower.endsWith('.opus')) {
    return FileType.audio;
  }
  if (lower.endsWith('.pdf')) return FileType.pdf;
  return FileType.unknown;
}

String resolveUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final path = url.startsWith('/') ? url : '/$url';
  return '$_baseUrl$path';
}

void openInBrowserTab(String url) {
  html.window.open(resolveUrl(url), '_blank');
}