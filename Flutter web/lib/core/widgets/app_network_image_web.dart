import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

/// Web-specific image loading using HtmlElementView.
/// Bypasses CORS/Canvas issues that occur with Flutter's Image.network on web.
Widget buildWebNetworkImage({
  required String url,
  required double width,
  required double height,
  BoxShape shape = BoxShape.circle,
  BorderRadius? borderRadius,
  String? fallbackText,
  Color? backgroundColor,
}) {
  final viewId = 'app_img_${url.hashCode}_${DateTime.now().microsecondsSinceEpoch}';

  ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
    final img = html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..onError.listen((_) {});

    final container = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.overflow = 'hidden'
      ..style.borderRadius = borderRadius != null
          ? '${borderRadius.topLeft.x}px'
          : (shape == BoxShape.circle ? '50%' : '0px')
      ..append(img);

    return container;
  });

  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewId),
  );
}
