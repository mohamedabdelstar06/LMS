import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/model.dart';
import 'Functions_of_Lecture_details/additional_file_card.dart';
import 'Functions_of_Lecture_details/author_card.dart';
import 'Functions_of_Lecture_details/description_card.dart';
import 'Functions_of_Lecture_details/hero_bar.dart';
import 'Functions_of_Lecture_details/info_grid.dart';
import 'Functions_of_Lecture_details/main_file_card.dart';
import 'Functions_of_Lecture_details/meta.dart';



List<String> _parseAdditionalUrls(dynamic raw) {
  if (raw == null) return [];

  if (raw is List) {
    return raw.map((e) => e.toString()).toList();
  }

  if (raw is String && raw.isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
  }

  return [];
}

class ShowViewDialogScreen extends StatefulWidget {
  const ShowViewDialogScreen({super.key, required this.lecture});

  final LectureModel lecture;

  @override
  State<ShowViewDialogScreen> createState() => _ShowViewDialogScreenState();
}

class _ShowViewDialogScreenState extends State<ShowViewDialogScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _enter;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 540),
    );
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lecture;
    final additionalUrls = _parseAdditionalUrls(l.additionalFileUrls);
    // final additionalUrls = l.additionalFileUrls ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              HeroBar(lecture: l),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    MetaStrip(lecture: l),
                    const SizedBox(height: 20),
                    DescriptionCard(text: l.description),
                    const SizedBox(height: 20),
                    MainFileCard(fileUrl: l.fileUrl),
                    if (additionalUrls.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      AdditionalFilesCard(urls: additionalUrls),
                    ],
                    const SizedBox(height: 20),
                    InfoGrid(lecture: l),
                    const SizedBox(height: 20),
                    AuthorCard(lecture: l),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
















