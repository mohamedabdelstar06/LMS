import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../comments/view/view.dart';
import '../functions/Delete_dialog.dart';
import '../functions/add_editDialog.dart';
import '../functions/body.dart';
import '../functions/add_ViewDialog.dart';
import '../functions/sideBar.dart';
import '../functions/topBar.dart';
import '../state_managment/lectures_cubit.dart';
import '../state_managment/lectures_state.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  bool _sidebarCollapsed = false;
  String _searchQuery = '';
  String _filterType = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openComments(BuildContext context, int lectureId) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 680,
            height: MediaQuery.of(context).size.height * 0.82,
            child: CommentsScreen(lectureId: lectureId),
          ),
        ),
      ),
    );
  }
  void showSnack(BuildContext ctx, String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LectureCubit(
        courseModel: context.read<LectureCubit>().courseModel,
      )..fetchLectures(widget.courseId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: BlocConsumer<LectureCubit, LectureState>(
          listener: (context, state) {
            if (state is LectureDeleteSuccess) {
              showSnack(context, state.message, Colors.green, Icons.check_circle_rounded);
            }
            if (state is LectureDeleteError) {
              showSnack(context, state.message, Colors.red, Icons.error_outline);
            }
            if (state is LectureCreateSuccess) {
              showSnack(context, state.message, Colors.green, Icons.check_circle_rounded);
            }
            if (state is LectureCreateError) {
              showSnack(context, state.message, Colors.red, Icons.error_outline);
            }
            if (state is LectureUpdateSuccess) {
              showSnack(context, state.message, Colors.green, Icons.check_circle_rounded);
            }
            if (state is LectureUpdateError) {
              showSnack(context, state.message, Colors.red, Icons.error_outline);
            }
          },
          builder: (context, state) {
            final cubit = context.read<LectureCubit>();
            final all = cubit.currentLectures;

            final filtered = all.where((l) {
              final matchSearch =
                  l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      l.description.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchType =
                  _filterType == 'All' ||
                      l.contentType.toLowerCase() == _filterType.toLowerCase();
              return matchSearch && matchType;
            }).toList();

            return Row(
              children: [
                // Sidebar(
                //   collapsed: _sidebarCollapsed,
                //   onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                //   activeLabel: 'Lectures',
                //   courseModel: cubit.courseModel,
                //   onIteSelected: (lectureId) {
                //     if (lectureId != null) {
                //       final lecture = all.firstWhere((l) => l.id == lectureId);
                //       showViewDialog(context, lecture);
                //     }
                //   },
                //
                // ),
                Expanded(
                  child: Column(
                    children: [
                      TopBar(
                        searchCtrl: _searchCtrl,
                        onSearch: (v) => setState(() => _searchQuery = v),
                        filterType: _filterType,
                        onFilterChange: (v) => setState(() => _filterType = v),
                        lectureCount: all.length,
                        onAddNew: () => showAddEditDialog(context, widget.courseId, cubit),
                      ),
                      Expanded(
                        child: Body(
                          state: state,
                          filtered: filtered,
                          searchQuery: _searchQuery,
                          cubit: cubit,
                          onEdit: (l) => showAddEditDialog(context, widget.courseId, cubit, lecture: l),
                          onDelete: (l) => showDeleteDialog(context, cubit, l),
                          onView: (l) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ShowViewDialogScreen(lecture: l),
                            ));
                          },
                          onComments: (l) => _openComments(context, l.id),
                          onRetry: () => cubit.fetchLectures(widget.courseId),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}