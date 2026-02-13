import 'dart:io';
import 'dart:typed_data';
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;
import '../../generated/assets.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? userImageUrl;
  final Uint8List? webImage;
  final File? selectedImage;
  final bool isHovered;
  final VoidCallback onTap;
  final Function(bool) onHover;

  const ProfilePictureWidget({
    super.key,
    this.userImageUrl,
    this.webImage,
    this.selectedImage,
    required this.isHovered,
    required this.onTap,
    required this.onHover,
  });

  static String buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    final cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    return 'https://skylearn.runasp.net/$cleanPath';
  }

  Widget _buildProfileImage() {
    if (webImage != null && kIsWeb) {
      return Image.memory(
        webImage!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    if (selectedImage != null && !kIsWeb) {
      return Image.file(
        selectedImage!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    if (userImageUrl != null && userImageUrl!.isNotEmpty) {
      if (kIsWeb) {
        return WebImage(url: buildImageUrl(userImageUrl), width: 100, height: 100);
      } else {
        return Image.network(
          buildImageUrl(userImageUrl),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(Assets.logo, width: 100, height: 100, fit: BoxFit.cover);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      }
    }

    return Image.asset(Assets.logo, width: 100, height: 100, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isHovered
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF2563EB).withOpacity(0.3),
                      width: isHovered ? 4 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(isHovered ? 0.3 : 0.1),
                        blurRadius: isHovered ? 20 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(child: _buildProfileImage()),
                  ),
                ),
                if (isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Change Photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()..rotateZ(isHovered ? 0.2 : 0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.5),
                            blurRadius: isHovered ? 12 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isHovered ? Icons.edit : Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const WebImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final viewId = url;

    ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
      final img = html.HTMLImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      return img;
    });

    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewId),
    );
  }
}