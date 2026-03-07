import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home_courses/model/model.dart';
import '../../comments/view/view.dart';
import '../functions/Delete_dialog.dart';
import '../functions/add_editDialog.dart';
import '../functions/body.dart';
import '../functions/add_ViewDialog.dart';
import '../functions/sideBar.dart';
import '../functions/topBar.dart';
import '../model/model.dart';
import '../state_managment/lectures_cubit.dart';
import '../state_managment/lectures_state.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key, required this.courseId, required this.course});

  final int courseId;
  final GetCoursesModel course;

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
          listener: _listener,
          builder: (context, state) {
            final cubit = context.read<LectureCubit>();
            final allLectures = cubit.currentLectures;
            final filtered = _filterLectures(allLectures);

            return Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TopBar(
                        searchCtrl: _searchCtrl,
                        onSearch: (v) => setState(() => _searchQuery = v),
                        filterType: _filterType,
                        onFilterChange: (v) => setState(() => _filterType = v),
                        lectureCount: allLectures.length,
                        onAddNew: () =>
                            showAddEditDialog(context, widget.courseId, cubit),
                      ),

                      Expanded(
                        child: Body(
                          state: state,
                          filtered: filtered,
                          searchQuery: _searchQuery,
                          cubit: cubit,
                          onEdit: (l) => showAddEditDialog(
                              context, widget.courseId, cubit,
                              lecture: l),
                          onDelete: (l) => showDeleteDialog(context, cubit, l),
                          // onView: (l) => _openLecture(context, l),
                          onComments: (l) => _openComments(context, l.id),
                          onRetry: () => cubit.fetchLectures(widget.courseId), course: widget.course,
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
  void _listener(BuildContext context, LectureState state) {
    if (state is LectureDeleteSuccess ||
        state is LectureCreateSuccess ||
        state is LectureUpdateSuccess) {
      showSnack(
        context,
        (state as dynamic).message,
        Colors.green,
        Icons.check_circle_rounded,
      );
    }

    if (state is LectureDeleteError ||
        state is LectureCreateError ||
        state is LectureUpdateError) {
      showSnack(
        context,
        (state as dynamic).message,
        Colors.red,
        Icons.error_outline,
      );
    }
  }
  List<LectureModel> _filterLectures(List<LectureModel> lectures) {
    return lectures.where((l) {
      final matchSearch =
          l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              l.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchType = _filterType == 'All' ||
          l.contentType.toLowerCase() == _filterType.toLowerCase();

      return matchSearch && matchType;
    }).toList();
  }
  void _openLecture(BuildContext context, LectureModel lecture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShowViewDialogScreen(lecture: lecture, course: widget.course,),
      ),
    );
  }
}