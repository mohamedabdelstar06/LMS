import 'package:flutter/material.dart';

import 'app_network_image_stub.dart'
if (dart.library.html) 'app_network_image_web.dart' as impl;

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double? width;
  final double? height;

  /// 🔥 خلي الافتراضي rectangle بدل circle
  final BoxShape shape;

  final BorderRadius? borderRadius;
  final String? fallbackText;
  final Color? backgroundColor;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle, // ✅ changed
    this.borderRadius,
    this.fallbackText,
    this.backgroundColor,
  });

  static String? resolveImageUrl(String? url, {String? baseUrl}) {
    if (url == null || url.isEmpty) return null;

    final base = baseUrl ?? 'https://skylearn.runasp.net';

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }

  double get _w => width ?? size;
  double get _h => height ?? size;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveImageUrl(imageUrl);

    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      return _buildFallback(context);
    }

    return ClipRRect(
      borderRadius: borderRadius ??
          (shape == BoxShape.circle
              ? BorderRadius.circular(_w / 2)
              : BorderRadius.zero),
      child: impl.buildWebNetworkImage(
        url: resolvedUrl,
        width: _w,
        height: _h,
        shape: shape,
        borderRadius: borderRadius,
        fallbackText: fallbackText,
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: _w,
      height: _h,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        color: backgroundColor ?? Colors.blue.shade100,
      ),
      child: Center(
        child: Text(
          _getFallbackChar(),
          style: TextStyle(
            fontSize: (_w < _h ? _w : _h) * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
      ),
    );
  }

  String _getFallbackChar() {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return fallbackText!.trim()[0].toUpperCase();
    }
    return '?';
  }
}
