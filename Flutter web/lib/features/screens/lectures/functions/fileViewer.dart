import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'fileTypeHelper.dart';

class _Sky {
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF5F9FF);
  static const border     = Color(0xFFD4E6F9);
  static const blue1      = Color(0xFF2980D9);
  static const blue2      = Color(0xFF4AA8F2);
  static const blue3      = Color(0xFF82C5F8);
  static const blue5      = Color(0xFFDCEEFD);
  static const textPrimary   = Color(0xFF0D2B4E);
  static const textSecondary = Color(0xFF4A7098);
  static const textMuted     = Color(0xFF8AAEC8);
  static const purple     = Color(0xFF7C3AED);
  static const green      = Color(0xFF059669);
  static const amber      = Color(0xFFF59E0B);
  static const red        = Color(0xFFEF4444);
}

void navigateToFileViewer(
    BuildContext context, {
      required String fileUrl,
      required String title,
      String? description,
      String? createdByName,
    }) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => FileViewerPage(
        fileUrl: fileUrl,
        title: title,
        description: description,
        createdByName: createdByName,
      ),
    ),
  );
}

class FileViewerPage extends StatelessWidget {
  final String fileUrl;
  final String title;
  final String? description;
  final String? createdByName;

  const FileViewerPage({
    super.key,
    required this.fileUrl,
    required this.title,
    this.description,
    this.createdByName,
  });

  @override
  Widget build(BuildContext context) {
    final type = detectFileType(fileUrl);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F4FE), Color(0xFFF5FAFF), Color(0xFFEAF3FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context, type),
        body: _buildBody(context, type),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, FileType type) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _Sky.blue1, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: _Sky.blue5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
      title: Row(
        children: [
          _TypeIcon(type: type, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _Sky.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
                Text(_typeLabel(type),
                    style: const TextStyle(
                        color: _Sky.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _OpenInTabButton(fileUrl: fileUrl),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: _Sky.border),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FileType type) {
    switch (type) {
      case FileType.video:
        return _VideoLayout(
            fileUrl: fileUrl,
            title: title,
            description: description,
            createdByName: createdByName);
      case FileType.audio:
        return _AudioLayout(
            fileUrl: fileUrl,
            title: title,
            description: description,
            createdByName: createdByName);
      case FileType.pdf:
      case FileType.unknown:
        openInBrowserTab(fileUrl);
        return const SizedBox.shrink();
    }
  }

  String _typeLabel(FileType type) {
    switch (type) {
      case FileType.video:   return 'Video Lecture';
      case FileType.audio:   return 'Audio Lecture';
      case FileType.pdf:     return 'PDF Document';
      case FileType.unknown: return 'File';
    }
  }
}

class _VideoLayout extends StatelessWidget {
  final String fileUrl;
  final String title;
  final String? description;
  final String? createdByName;

  const _VideoLayout({
    required this.fileUrl,
    required this.title,
    this.description,
    this.createdByName,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 860;
      final videoW = isWide ? constraints.maxWidth * 0.65 : constraints.maxWidth;
      final videoH = videoW * (9 / 16);

      final player = _HtmlVideo(fileUrl: fileUrl, width: videoW, height: videoH);
      final info = _InfoCard(
          title: title,
          description: description,
          createdByName: createdByName,
          typeColor: _Sky.purple,
          typeLabel: 'VIDEO');

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 65,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                    children: [player, const SizedBox(height: 20), info]),
              ),
            ),
            Container(width: 1, color: _Sky.border),
            Expanded(
              flex: 35,
              child: _SidePanel(fileUrl: fileUrl, type: FileType.video),
            ),
          ],
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [player, const SizedBox(height: 20), info]),
      );
    });
  }
}

class _AudioLayout extends StatelessWidget {
  final String fileUrl;
  final String title;
  final String? description;
  final String? createdByName;

  const _AudioLayout({
    required this.fileUrl,
    required this.title,
    this.description,
    this.createdByName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              const _AudioVisual(),
              const SizedBox(height: 24),
              _HtmlAudio(fileUrl: fileUrl),
              const SizedBox(height: 24),
              _InfoCard(
                  title: title,
                  description: description,
                  createdByName: createdByName,
                  typeColor: _Sky.green,
                  typeLabel: 'AUDIO'),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlVideo extends StatefulWidget {
  final String fileUrl;
  final double width;
  final double height;

  const _HtmlVideo(
      {required this.fileUrl, required this.width, required this.height});

  @override
  State<_HtmlVideo> createState() => _HtmlVideoState();
}

class _HtmlVideoState extends State<_HtmlVideo> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId =
    'video-${widget.fileUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    ui.platformViewRegistry.registerViewFactory(_viewId, (_) {
      return html.VideoElement()
        ..src = widget.fileUrl
        ..controls = true
        ..autoplay = false
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.backgroundColor = '#0A1628'
        ..setAttribute('playsinline', 'true')
        ..setAttribute('preload', 'metadata');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Sky.border, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _Sky.blue1.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}

class _HtmlAudio extends StatefulWidget {
  final String fileUrl;
  const _HtmlAudio({required this.fileUrl});

  @override
  State<_HtmlAudio> createState() => _HtmlAudioState();
}

class _HtmlAudioState extends State<_HtmlAudio> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId =
    'audio-${widget.fileUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    ui.platformViewRegistry.registerViewFactory(_viewId, (_) {
      return html.AudioElement()
        ..src = widget.fileUrl
        ..controls = true
        ..style.width = '100%'
        ..style.height = '54px'
        ..setAttribute('preload', 'metadata');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _Sky.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Sky.border, width: 1.4),
        boxShadow: [
          BoxShadow(
              color: _Sky.green.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      clipBehavior: Clip.hardEdge,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}

class _AudioVisual extends StatelessWidget {
  const _AudioVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _Sky.green.withOpacity(0.12),
            _Sky.blue1.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Sky.green.withOpacity(0.25), width: 1.4),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headphones_rounded, color: _Sky.green, size: 48),
          SizedBox(height: 14),
          Text('Audio Lecture',
              style: TextStyle(
                  color: _Sky.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('Use the player below to listen',
              style: TextStyle(color: _Sky.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? createdByName;
  final Color typeColor;
  final String typeLabel;

  const _InfoCard({
    required this.title,
    this.description,
    this.createdByName,
    required this.typeColor,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _Sky.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Sky.border),
        boxShadow: [
          BoxShadow(
              color: _Sky.blue3.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _Sky.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description!,
                style: const TextStyle(
                    color: _Sky.textSecondary, fontSize: 13, height: 1.55)),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (createdByName != null)
                _Chip(
                    icon: Icons.person_outline_rounded,
                    label: createdByName!,
                    color: _Sky.blue1),
              _Chip(
                  icon: Icons.label_outline_rounded,
                  label: typeLabel,
                  color: typeColor),
              _Chip(
                  icon: Icons.open_in_browser_rounded,
                  label: 'Native Browser',
                  color: _Sky.amber),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  final String fileUrl;
  final FileType type;

  const _SidePanel({required this.fileUrl, required this.type});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Details',
              style: TextStyle(
                  color: _Sky.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.smart_display_outlined,
              label: 'Type',
              value: type == FileType.video ? 'Video' : 'Audio'),
          const SizedBox(height: 10),
          _DetailRow(
              icon: Icons.open_in_browser_rounded,
              label: 'Player',
              value: 'Native Browser'),
          const SizedBox(height: 24),
          _OpenInTabButton(fileUrl: fileUrl, showLabel: true),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _Sky.blue5,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _Sky.border),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_outlined,
                    size: 15, color: _Sky.blue1),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use native browser controls for fullscreen, speed, and volume.',
                    style: TextStyle(
                        color: _Sky.textSecondary,
                        fontSize: 11.5,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _Sky.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _Sky.border),
          ),
          child: Icon(icon, size: 15, color: _Sky.blue1),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                const TextStyle(color: _Sky.textMuted, fontSize: 10.5)),
            Text(value,
                style: const TextStyle(
                    color: _Sky.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _OpenInTabButton extends StatelessWidget {
  final String fileUrl;
  final bool showLabel;

  const _OpenInTabButton({required this.fileUrl, this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      return GestureDetector(
        onTap: () => openInBrowserTab(fileUrl),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _Sky.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _Sky.border),
            ),
            child: const Icon(Icons.open_in_new_rounded,
                color: _Sky.blue1, size: 17),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => openInBrowserTab(fileUrl),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_Sky.blue1, _Sky.blue2]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: _Sky.blue1.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_in_new_rounded, color: Colors.white, size: 15),
              SizedBox(width: 8),
              Text('Open in New Tab',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final FileType type;
  final double size;

  const _TypeIcon({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconData();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }

  (IconData, Color) _iconData() {
    switch (type) {
      case FileType.video:
        return (Icons.play_circle_outline_rounded, _Sky.purple);
      case FileType.audio:
        return (Icons.headphones_rounded, _Sky.green);
      case FileType.pdf:
        return (Icons.picture_as_pdf_outlined, _Sky.red);
      case FileType.unknown:
        return (Icons.insert_drive_file_outlined, _Sky.blue1);
    }
  }
}