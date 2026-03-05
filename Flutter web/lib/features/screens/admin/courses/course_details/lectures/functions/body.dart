import 'package:flutter/material.dart';

import '../model/model.dart';
import '../state_managment/lectures_cubit.dart';
import '../state_managment/lectures_state.dart';
import 'lectureTile.dart';

class Body extends StatelessWidget {
  const Body({
    required this.state,
    required this.filtered,
    required this.searchQuery,
    required this.cubit,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
    required this.onComments,
    required this.onRetry,
  });

  final LectureState state;
  final List<LectureModel> filtered;
  final String searchQuery;
  final LectureCubit cubit;
  final void Function(LectureModel) onEdit;
  final void Function(LectureModel) onDelete;
  final void Function(LectureModel) onView;
  final void Function(LectureModel) onComments;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state is LectureLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF175CD3), strokeWidth: 3),
            SizedBox(height: 16),
            Text('Loading lectures...',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
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
            Text((state as LectureError).message,
                style: const TextStyle(color: Colors.red, fontSize: 15)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF175CD3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No results for "$searchQuery"',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No lectures yet',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Text('Add your first lecture to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    final isDeleting = state is LectureDeleteLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: AbsorbPointer(
        absorbing: isDeleting,
        child: ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final l = filtered[i];
            return LectureTile(
              lecture: l,
              isDeleting: isDeleting,
              onView: () => onView(l),
              onEdit: () => onEdit(l),
              onDelete: () => onDelete(l),
              onComments: () => onComments(l),
            );
          },
        ),
      ),
    );
  }
}