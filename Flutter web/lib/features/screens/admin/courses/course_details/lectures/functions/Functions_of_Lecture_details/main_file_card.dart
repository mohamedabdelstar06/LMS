import 'package:flutter/material.dart';

import 'card.dart';
import 'card_title.dart';
import 'file_configuration.dart';
import 'file_row_state.dart';

class MainFileCard extends StatelessWidget {
  const MainFileCard({super.key, required this.fileUrl});

  final String fileUrl;

  @override
  Widget build(BuildContext context) {
    final ext = fileUrl.split('.').last.toLowerCase();
    final cfg = fileCfg(ext);

    return CardShip(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(Icons.attach_file_rounded, 'Lecture File'),
          const SizedBox(height: 14),
          FileRow(url: fileUrl, ext: ext, cfg: cfg, isPrimary: true),
        ],
      ),
    );
  }
}
