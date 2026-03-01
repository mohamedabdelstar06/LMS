
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../functions/addAndEditDialog.dart';
import '../functions/body.dart';
import '../functions/delateAndViewDialog.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LectureCubit()..fetchLectures(widget.courseId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: BlocConsumer<LectureCubit, LectureState>(
          listener: (context, state) {
            if (state is LectureDeleteSuccess) {
              showSnack(
                context,
                state.message,
                Colors.green,
                Icons.check_circle_rounded,
              );
            }
            if (state is LectureDeleteError) {
              showSnack(
                context,
                state.message,
                Colors.red,
                Icons.error_outline,
              );
            }
            if (state is LectureCreateSuccess) {
              showSnack(
                context,
                state.message,
                Colors.green,
                Icons.check_circle_rounded,
              );
            }
            if (state is LectureCreateError) {
              showSnack(
                context,
                state.message,
                Colors.red,
                Icons.error_outline,
              );
            }
            if (state is LectureUpdateSuccess) {
              showSnack(
                context,
                state.message,
                Colors.green,
                Icons.check_circle_rounded,
              );
            }
            if (state is LectureUpdateError) {
              showSnack(
                context,
                state.message,
                Colors.red,
                Icons.error_outline,
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<LectureCubit>();
            final all = cubit.currentLectures;

            final filtered = all.where((l) {
              final matchSearch =
                  l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  l.description.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
              final matchType =
                  _filterType == 'All' ||
                  l.contentType.toLowerCase() == _filterType.toLowerCase();
              return matchSearch && matchType;
            }).toList();

            return Row(
              children: [
                Sidebar(
                  collapsed: _sidebarCollapsed,
                  onToggle: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TopBar(
                        searchCtrl: _searchCtrl,
                        onSearch: (v) => setState(() => _searchQuery = v),
                        filterType: _filterType,
                        onFilterChange: (v) => setState(() => _filterType = v),
                        lectureCount: all.length,
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
                            context,
                            widget.courseId,
                            cubit,
                            lecture: l,
                          ),
                          onDelete: (l) => showDeleteDialog(context, cubit, l),
                          onView: (l) => showViewDialog(context, l),
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
