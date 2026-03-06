import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'file_cfg.dart';
const String _kBase = 'https://skylearn.runasp.net';

String _url(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  url = url.replaceAll('"', '').trim();


  final path = url.startsWith('/') ? url : '/$url';
  return '$_kBase$path';
}


class FileRow extends StatefulWidget {
  const FileRow({super.key,
    required this.url,
    required this.ext,
    required this.cfg,
    required this.isPrimary,
  });

  final String url;
  final String ext;
  final FileCfg cfg;
  final bool isPrimary;

  @override
  State<FileRow> createState() => FileRowState();
}

class FileRowState extends State<FileRow> {
  bool _hover = false;

  String get _fileName => widget.url.split('/').last;

  Future<void> _open() async {
    final fullUrl = _url(widget.url);

    if (kDebugMode) {
      print('Full URL: $fullUrl');
    }

    final uri = Uri.parse(fullUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (kDebugMode) {
        print('Cannot open URL: $fullUrl');
      }
    }
  }
  String cleanUrl(String url) {
    return url.replaceAll('"', '').replaceAll('%22', '');
  }


  @override
  Widget build(BuildContext context) {
    final cfg = widget.cfg;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hover ? cfg.color.withOpacity(0.07) : cfg.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hover
                  ? cfg.color.withOpacity(0.4)
                  : cfg.color.withOpacity(0.15),
              width: _hover ? 1.5 : 1,
            ),
            boxShadow: _hover
                ? [
              BoxShadow(
                color: cfg.color.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cfg.color, cfg.color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: cfg.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(cfg.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fileName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.ext.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: cfg.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: _hover
                      ? LinearGradient(
                    colors: [cfg.color, cfg.color.withOpacity(0.8)],
                  )
                      : null,
                  color: _hover ? null : cfg.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 13,
                      color: _hover ? Colors.white : cfg.color,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Open',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _hover ? Colors.white : cfg.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
