import 'package:flutter/material.dart';

import '../../../get_all_courses/model/model.dart';
import '../../../home_courses/model/model.dart';
import '../model/model.dart';
import '../state_managment/lectures_cubit.dart';
import '../state_managment/lectures_state.dart';
import 'lectureTile.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.state,
    required this.filtered,
    required this.searchQuery,
    required this.cubit,
    this.onEdit,
    this.onDelete,
    required this.onComments,
    required this.onRetry,
    required this.course,
  });

  final LectureState state;
  final List<LectureModel> filtered;
  final String searchQuery;
  final LectureCubit cubit;

  /// Null hides the Edit action on every card (e.g. for students).
  final void Function(LectureModel)? onEdit;

  /// Null hides the Delete action on every card (e.g. for students).
  final void Function(LectureModel)? onDelete;

  final void Function(LectureModel) onComments;
  final VoidCallback onRetry;
  final GetCoursesModel course;

  @override
  Widget build(BuildContext context) {
    if (state is LectureLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF175CD3), strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Loading lectures...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (state is LectureError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              (state as LectureError).message,
              style: const TextStyle(color: Colors.red, fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF175CD3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty && searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No results for "$searchQuery"',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No lectures yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first lecture to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    final isDeleting = state is LectureDeleteLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: AbsorbPointer(
        absorbing: isDeleting,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380,
            mainAxisExtent: 210,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final l = filtered[i];
            return _AnimatedGridTile(
              key: ValueKey(l.id),
              index: i,
              child: LectureTile(
                lecture: l,
                isDeleting: isDeleting,
                course: course,
                // Forwarded as-is: null stays null, so LectureTile hides
                // the corresponding icon entirely for students.
                onEdit: onEdit == null ? null : () => onEdit!(l),
                onDelete: onDelete == null ? null : () => onDelete!(l),
                onComments: () => onComments(l),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedGridTile extends StatefulWidget {
  const _AnimatedGridTile({
    super.key,
    required this.child,
    required this.index,
  });

  final Widget child;
  final int index;

  @override
  State<_AnimatedGridTile> createState() => _AnimatedGridTileState();
}

class _AnimatedGridTileState extends State<_AnimatedGridTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 40),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..translate(0.0, _hovered ? -4.0 : 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? const Color(0xFF4361EE).withOpacity(0.5)
                    : const Color(0xFFE2E8F0),
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4361EE).withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
