import 'dart:html' as html;


const String _baseUrl = 'https://skylearn.runasp.net';

enum FileType {
  video,
  audio,
  pdf,
  excel,
  word,
  powerpoint,
  image,
  text,
  archive,
  unknown,
}

 class FileDetector {
  static const Map<FileType, Set<String>> _extensions = {
    FileType.video: {'mp4', 'webm', 'mov', 'avi', 'mkv', 'ogg'},

    FileType.audio: {'mp3', 'wav', 'aac', 'flac', 'm4a', 'opus'},

    FileType.image: {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'},

    FileType.pdf: {'pdf'},

    FileType.excel: {'xls', 'xlsx', 'csv'},

    FileType.word: {'doc', 'docx'},

    FileType.powerpoint: {'ppt', 'pptx'},

    FileType.text: {'txt', 'json', 'xml', 'html'},

    FileType.archive: {'zip', 'rar', '7z', 'tar', 'gz'},
  };

   FileType detect(String url) {
    final cleanUrl = url.toLowerCase().split('?').first;

    if (!cleanUrl.contains('.')) {
      return FileType.unknown;
    }

    final extension = cleanUrl.split('.').last;

    for (final entry in _extensions.entries) {
      if (entry.value.contains(extension)) {
        return entry.key;
      }
    }

    return FileType.unknown;
  }
}

String resolveUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final path = url.startsWith('/') ? url : '/$url';
  return '$_baseUrl$path';
}

void openInBrowserTab(String url) {
  html.window.open(resolveUrl(url), '_blank');
}
