import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'app_network_image.dart';

Widget buildWebNetworkImage({
  required String url,
  required double width,
  required double height,
  BoxShape shape = BoxShape.circle,
  BorderRadius? borderRadius,
  String? fallbackText,
  Color? backgroundColor,
  AppImageType imageType = AppImageType.general,
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
        color: backgroundColor ?? Colors.grey.shade100,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    placeholder: (_, __) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: borderRadius != null ? BoxShape.rectangle : shape,
        borderRadius: borderRadius,
        color: Colors.grey.shade100,
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    errorWidget: (_, __, ___) {
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
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: borderRadius != null ? BoxShape.rectangle : shape,
          borderRadius: borderRadius ?? (shape == BoxShape.rectangle ? BorderRadius.circular(12) : null),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            fallbackIcon,
            size: width * 0.45,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      );
    },
  );
}
