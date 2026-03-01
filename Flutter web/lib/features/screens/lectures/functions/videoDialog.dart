import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'dart:html' as html;

class _Sky {
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF5F9FF);
  static const bg         = Color(0xFFF0F7FF);
  static const border     = Color(0xFFD4E6F9);
  static const blue1      = Color(0xFF2980D9);
  static const blue2      = Color(0xFF4AA8F2);
  static const blue3      = Color(0xFF82C5F8);
  static const blue4      = Color(0xFFBEDEFB);
  static const blue5      = Color(0xFFDCEEFD);
  static const textPrimary   = Color(0xFF0D2B4E);
  static const textSecondary = Color(0xFF4A7098);
  static const textMuted     = Color(0xFF8AAEC8);
  static const purple     = Color(0xFF7C3AED);
  static const green      = Color(0xFF059669);
  static const red        = Color(0xFFEF4444);
}

void navigateToVideoPage(
    BuildContext context, {
      required String videoUrl,
      required String title,
      String? description,
      String? createdByName,
      String? contentType,
    }) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => VideoPlayerPage(
        videoUrl: videoUrl,
        title: title,
        description: description,
        createdByName: createdByName,
        contentType: contentType ?? 'video',
      ),
    ),
  );
}

class VideoPlayerPage extends StatelessWidget {
  final String videoUrl;
  final String title;
  final String? description;
  final String? createdByName;
  final String? contentType;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
    this.description,
    this.createdByName,
    this.contentType,
  });

  @override
  Widget build(BuildContext context) {
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
        appBar: _buildAppBar(context),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return isWide
                ? _buildWideLayout(constraints)
                : _buildNarrowLayout(constraints);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_Sky.blue1, _Sky.blue2]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_outline_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _Sky.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: _Sky.border),
      ),
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints) {
    final videoW = constraints.maxWidth * 0.65;
    final videoH = videoW * (9 / 16);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 65,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                _VideoContainer(
                  videoUrl: videoUrl,
                  width: videoW,
                  height: videoH,
                ),
                const SizedBox(height: 20),
                _VideoInfoCard(
                  title: title,
                  description: description,
                  createdByName: createdByName,
                  contentType: contentType,
                  horizontal: true,
                ),
              ],
            ),
          ),
        ),
        Container(width: 1, color: _Sky.border),
        Expanded(
          flex: 35,
          child: _SidePanel(videoUrl: videoUrl, title: title),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BoxConstraints constraints) {
    final videoW = constraints.maxWidth;
    final videoH = videoW * (9 / 16);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _VideoContainer(
            videoUrl: videoUrl,
            width: videoW,
            height: videoH,
          ),
          const SizedBox(height: 20),
          _VideoInfoCard(
            title: title,
            description: description,
            createdByName: createdByName,
            contentType: contentType,
            horizontal: false,
          ),
        ],
      ),
    );
  }
}

class _VideoContainer extends StatelessWidget {
  final String videoUrl;
  final double width;
  final double height;

  const _VideoContainer({
    required this.videoUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Sky.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _Sky.blue1.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: WebVideoPlayer(videoUrl: videoUrl),
    );
  }
}

class WebVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const WebVideoPlayer({super.key, required this.videoUrl});

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId =
    'web-video-${widget.videoUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    _register();
  }

  void _register() {
    ui.platformViewRegistry.registerViewFactory(_viewId, (_) {
      return html.VideoElement()
        ..src = widget.videoUrl
        ..controls = true
        ..autoplay = false
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.backgroundColor = '#0A1628'
        ..setAttribute('playsinline', 'true')
        ..setAttribute('preload', 'metadata')
        ..setAttribute('controlsList', 'nodownload');
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}

class _VideoInfoCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? createdByName;
  final String? contentType;
  final bool horizontal;

  const _VideoInfoCard({
    required this.title,
    this.description,
    this.createdByName,
    this.contentType,
    required this.horizontal,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: _Sky.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              )),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description!,
                style: const TextStyle(
                    color: _Sky.textSecondary, fontSize: 13, height: 1.5)),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (createdByName != null)
                _InfoChip(
                    icon: Icons.person_outline_rounded,
                    label: createdByName!,
                    color: _Sky.blue1),
              if (contentType != null)
                _InfoChip(
                    icon: Icons.videocam_outlined,
                    label: contentType!.toUpperCase(),
                    color: _Sky.purple),
              _InfoChip(
                  icon: Icons.hd_outlined,
                  label: 'Browser Player',
                  color: _Sky.green),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
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
  final String videoUrl;
  final String title;

  const _SidePanel({required this.videoUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Video Details',
              style: TextStyle(
                  color: _Sky.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.play_lesson_outlined,
              label: 'Type',
              value: 'Lecture Video'),
          const SizedBox(height: 10),
          _DetailRow(
              icon: Icons.open_in_browser_rounded,
              label: 'Player',
              value: 'Native Browser'),
          const SizedBox(height: 10),
          _DetailRow(
              icon: Icons.hd_outlined, label: 'Quality', value: 'Auto'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _Sky.blue5,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _Sky.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: _Sky.blue1),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use the video controls below the player to adjust playback speed, volume, and fullscreen.',
                    style:
                    TextStyle(color: _Sky.textSecondary, fontSize: 11.5, height: 1.5),
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
                style: const TextStyle(
                    color: _Sky.textMuted, fontSize: 10.5)),
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