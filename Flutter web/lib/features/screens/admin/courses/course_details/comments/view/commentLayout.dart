import 'package:flutter/material.dart';
import 'package:lms/features/screens/admin/courses/course_details/comments/view/view.dart';

import '../../lectures/functions/sideBar.dart';

class CommentLayout extends StatefulWidget {
  const CommentLayout({super.key});

  @override
  State<CommentLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<CommentLayout> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          Sidebar(
            collapsed: _collapsed,
            onToggle: () => setState(() => _collapsed = !_collapsed),
            activeLabel: 'Comments',
          ),
          Expanded(
            child: CommentsScreen(lectureId: 27),
          ),
        ],
      ),
    );
  }
}