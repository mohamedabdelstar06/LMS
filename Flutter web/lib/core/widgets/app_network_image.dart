import 'package:flutter/material.dart';

import 'app_network_image_stub.dart'
    if (dart.library.html) 'app_network_image_web.dart' as impl;

/// Global reusable network image with loading placeholder and error fallback.
/// On web: uses HtmlElementView for reliable image loading (avoids CORS issues).
/// On mobile: uses CachedNetworkImage.
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double? width;
  final double? height;
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
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.fallbackText,
    this.backgroundColor,
  });

  /// Resolves potentially relative URLs to full URLs.
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

    return impl.buildWebNetworkImage(
      url: resolvedUrl,
      width: _w,
      height: _h,
      shape: shape,
      borderRadius: borderRadius,
      fallbackText: fallbackText,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: _w,
      height: _h,
      decoration: BoxDecoration(
        shape: borderRadius != null ? BoxShape.rectangle : shape,
        borderRadius: borderRadius,
        color: backgroundColor ?? Colors.blue.shade100,
      ),
      child: Center(
        child: Text(
          _getFallbackChar(),
          style: TextStyle(
            fontSize: (width ?? height ?? size) * 0.4,
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
