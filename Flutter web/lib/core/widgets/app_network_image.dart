import 'package:lms/core/helpers/api_url_helper.dart';
import 'package:flutter/material.dart';

import 'app_network_image_stub.dart'
if (dart.library.html) 'app_network_image_web.dart' as impl;

enum AppImageType { user, course, department, general }

class AppNetworkImage extends StatelessWidget {

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
    this.imageType = AppImageType.general,
  });
  final String? imageUrl;
  final double size;
  final double? width;
  final double? height;
  final AppImageType imageType;

  /// 🔥 خلي الافتراضي rectangle بدل circle
  final BoxShape shape;

  final BorderRadius? borderRadius;
  final String? fallbackText;
  final Color? backgroundColor;

  static String? resolveImageUrl(String? url, {String? baseUrl}) {
    return ApiUrlHelper.resolveMediaUrl(url);
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
        imageType: imageType,
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    IconData fallbackIcon;
    List<Color> gradientColors;
    switch (imageType) {
      case AppImageType.user:
        fallbackIcon = Icons.person_rounded;
        gradientColors = [const Color(0xFFE0E7FF), const Color(0xFFC7D2FE)];
        break;
      case AppImageType.course:
        fallbackIcon = Icons.menu_book_rounded;
        gradientColors = [const Color(0xFFFEF08A), const Color(0xFFFDE047)];
        break;
      case AppImageType.department:
        fallbackIcon = Icons.domain_rounded;
        gradientColors = [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)];
        break;
      case AppImageType.general:
      default:
        fallbackIcon = Icons.image_rounded;
        gradientColors = [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)];
        break;
    }

    return Container(
      width: _w,
      height: _h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? (borderRadius ?? BorderRadius.circular(12)) : null,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: _w * 0.45,
          color: Colors.black.withOpacity(0.3),
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
