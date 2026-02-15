import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Stub for non-web platforms - uses CachedNetworkImage.
Widget buildWebNetworkImage({
  required String url,
  required double width,
  required double height,
  BoxShape shape = BoxShape.circle,
  BorderRadius? borderRadius,
  String? fallbackText,
  Color? backgroundColor,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    imageBuilder: (context, imageProvider) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: borderRadius != null ? BoxShape.rectangle : shape,
        borderRadius: borderRadius,
        color: backgroundColor ?? Colors.blue.shade100,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    placeholder: (_, __) => Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
    errorWidget: (_, __, ___) => _buildFallback(
      width, height, shape, borderRadius, fallbackText, backgroundColor,
    ),
  );
}

Widget _buildFallback(
  double width,
  double height,
  BoxShape shape,
  BorderRadius? borderRadius,
  String? fallbackText,
  Color? backgroundColor,
) {
  final char = (fallbackText != null && fallbackText.isNotEmpty)
      ? fallbackText.trim()[0].toUpperCase()
      : '?';
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      shape: borderRadius != null ? BoxShape.rectangle : shape,
      borderRadius: borderRadius,
      color: backgroundColor ?? Colors.blue.shade100,
    ),
    child: Center(
      child: Text(
        char,
        style: TextStyle(
          fontSize: (width < height ? width : height) * 0.45,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    ),
  );
}
