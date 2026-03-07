import 'package:flutter/material.dart';

import 'card.dart';
import 'card_title.dart';
import 'file_configuration.dart';
import 'file_row_state.dart';

class AdditionalFilesCard extends StatelessWidget {
  const AdditionalFilesCard({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return CardShip(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CardTitle(Icons.folder_open_rounded, 'Additional Files'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${urls.length} file${urls.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...urls.asMap().entries.map((e) {
            final ext = e.value.split('.').last.toLowerCase();
            final cfg = fileCfg(ext);
            return Padding(
              padding: EdgeInsets.only(
                bottom: e.key < urls.length - 1 ? 10 : 0,
              ),
              child: FileRow(
                url: e.value,
                ext: ext,
                cfg: cfg,
                isPrimary: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}
