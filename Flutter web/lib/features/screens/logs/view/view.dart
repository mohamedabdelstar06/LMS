import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cons/Colors/app_colors.dart';
import '../log_helper/helper.dart';
import '../log_widgets/view.dart';
import '../model.dart';
import '../state_mangement/logs_cubit.dart';
import '../state_mangement/logs_state.dart';

// ─── Sky Palette ───────────────────────────────────────────────────────────────
class _Sky {
  static const surfaceAlt = Color(0xFFF5F9FF);
  static const border = Color(0xFFD4E6F9);

  static const blue1 = Color(0xFF2980D9);
  static const blue2 = Color(0xFF4AA8F2);
  static const blue3 = Color(0xFF82C5F8);
  static const blue5 = Color(0xFFDCEEFD);

  static const textPrimary = Color(0xFF0D2B4E);
  static const textSecondary = Color(0xFF4A7098);
  static const textMuted = Color(0xFF8AAEC8);

  static const green = Color(0xFF10B981);
  static const purple = Color(0xFF7C3AED);
  static const amber = Color(0xFFF59E0B);
  static const pink = Color(0xFFEC4899);
  static const red = Color(0xFFEF4444);
}

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedComponent;
  String? _selectedOrigin;

  @override
  void initState() {
    super.initState();
    context.read<ActivityLogsCubit>().loadLogs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      context.read<ActivityLogsCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    context.read<ActivityLogsCubit>().search(value);
  }

  void _selectComponent(String? component) {
    setState(
      () => _selectedComponent = _selectedComponent == component
          ? null
          : component,
    );
    context.read<ActivityLogsCubit>().applyFilter(
      component: _selectedComponent,
      origin: _selectedOrigin,
    );
  }

  void _selectOrigin(String? origin) {
    setState(() => _selectedOrigin = _selectedOrigin == origin ? null : origin);
    context.read<ActivityLogsCubit>().applyFilter(
      component: _selectedComponent,
      origin: _selectedOrigin,
    );
  }

  void _clearAll() {
    setState(() {
      _selectedComponent = null;
      _selectedOrigin = null;
      _searchController.clear();
    });
    context.read<ActivityLogsCubit>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MYColors.gradientColor_3,
            MYColors.gradientColor_2.withValues(alpha: 0.25),
            MYColors.gradientColor_3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            const SizedBox(height: 4),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<ActivityLogsCubit, ActivityLogsState>(
      builder: (context, state) {
        final totalCount = state is ActivityLogsLoaded ? state.totalCount : 0;
        final currentPage = state is ActivityLogsLoaded ? state.currentPage : 0;
        final totalPages = state is ActivityLogsLoaded ? state.totalPages : 0;

        return Container(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: const Border(
              bottom: BorderSide(color: _Sky.border, width: 1.2),
            ),
            boxShadow: const [
              BoxShadow(
                color: _Sky.blue2,
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildLogoArea(),
                  const Spacer(),
                  _buildBackButton(),
                  const SizedBox(width: 16),

                  _buildSearchBar(),
                  const SizedBox(width: 16),
                  _buildRefreshButton(),
                ],
              ),
              const SizedBox(height: 20),
              _buildStatsRow(totalCount, currentPage, totalPages, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoArea() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_Sky.blue1, _Sky.blue2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _Sky.blue1.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.assessment_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Logs',
              style: TextStyle(
                color: _Sky.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'اّفــــــاق· Monitor all system events',
              style: TextStyle(color: _Sky.textMuted, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 280,
      height: 42,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: _Sky.textPrimary, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'Search logs...',
          hintStyle: const TextStyle(color: _Sky.textMuted, fontSize: 13.5),
          prefixIcon: const Icon(Icons.search, color: _Sky.textMuted, size: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: const Icon(
                    Icons.close,
                    color: _Sky.textMuted,
                    size: 16,
                  ),
                )
              : null,
          filled: true,
          fillColor: _Sky.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Sky.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Sky.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _Sky.blue1, width: 1.8),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: () => context.read<ActivityLogsCubit>().loadLogs(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _Sky.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Sky.border),
            boxShadow: [
              BoxShadow(
                color: _Sky.blue3.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.refresh, color: _Sky.blue1, size: 20),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _Sky.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Sky.border),
            boxShadow: [
              BoxShadow(
                color: _Sky.blue3.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(child: Icon(Icons.arrow_back_ios, color: _Sky.blue1, size: 20)),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    int totalCount,
    int currentPage,
    int totalPages,
    ActivityLogsState state,
  ) {
    final isLoaded = state is ActivityLogsLoaded;
    final logs = isLoaded ? state.logs : <ActivityLog>[];
    final authCount = logs.where((l) => l.component == 'Auth').length;
    final lectureCount = logs
        .where((l) => l.component.toLowerCase().contains('lecture'))
        .length;
    final webCount = logs.where((l) => l.origin == 'web').length;

    return Row(
      children: [
        Expanded(
          child: _LightStatsCard(
            label: 'Total Events',
            value: totalCount > 0 ? totalCount.toString() : '-',
            icon: Icons.bar_chart_rounded,
            color: _Sky.blue1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LightStatsCard(
            label: 'Auth Events',
            value: authCount.toString(),
            icon: Icons.lock_outline_rounded,
            color: _Sky.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LightStatsCard(
            label: 'Lecture Events',
            value: lectureCount.toString(),
            icon: Icons.play_lesson_outlined,
            color: _Sky.purple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LightStatsCard(
            label: 'Web Origin',
            value: webCount.toString(),
            icon: Icons.language_rounded,
            color: _Sky.amber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LightStatsCard(
            label: 'Pages',
            value: totalPages > 0 ? '$currentPage / $totalPages' : '-',
            icon: Icons.auto_stories_outlined,
            color: _Sky.pink,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: const Border(bottom: BorderSide(color: _Sky.border)),
      ),
      child: Row(
        children: [
          const Text(
            'Component:',
            style: TextStyle(
              color: _Sky.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          ...LogHelpers.components.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _LightFilterChip(
                label: c,
                selected: _selectedComponent == c,
                color: LogHelpers.componentColor(c),
                onTap: () => _selectComponent(c),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Origin:',
            style: TextStyle(
              color: _Sky.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          ...LogHelpers.origins.map(
            (o) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _LightFilterChip(
                label: o,
                selected: _selectedOrigin == o,
                color: o == 'web' ? _Sky.blue1 : _Sky.amber,
                onTap: () => _selectOrigin(o),
              ),
            ),
          ),
          const Spacer(),
          if (_selectedComponent != null || _selectedOrigin != null)
            GestureDetector(
              onTap: _clearAll,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _Sky.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _Sky.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.close, size: 13, color: _Sky.red),
                      SizedBox(width: 5),
                      Text(
                        'Clear Filters',
                        style: TextStyle(color: _Sky.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ActivityLogsCubit, ActivityLogsState>(
      builder: (context, state) {
        if (state is ActivityLogsLoading) return _buildLoadingView();
        if (state is ActivityLogsError) return _buildErrorView(state.message);
        if (state is ActivityLogsLoaded) return _buildLogsList(state);
        if (state is ActivityLogsLoadingMore) {
          return _buildLogsList(
            null,
            loadingMore: true,
            logs: state.currentLogs,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _Sky.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _Sky.blue3.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: _Sky.blue1,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading activity logs...',
            style: TextStyle(color: _Sky.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _Sky.red.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: _Sky.red.withOpacity(0.25), width: 1.5),
            ),
            child: const Icon(Icons.error_outline, color: _Sky.red, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading logs',
            style: TextStyle(
              color: _Sky.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: _Sky.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.read<ActivityLogsCubit>().loadLogs(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_Sky.blue1, _Sky.blue2],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _Sky.blue1.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(
    ActivityLogsLoaded? state, {
    bool loadingMore = false,
    List<ActivityLog>? logs,
  }) {
    final displayLogs = state?.logs ?? logs ?? [];

    if (displayLogs.isEmpty && !loadingMore) {
      return _buildEmptyView();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
      itemCount:
          displayLogs.length +
          (loadingMore || (state?.hasNextPage ?? false) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayLogs.length) {
          return _buildLoadMoreIndicator(loadingMore, state);
        }
        return LogCard(log: displayLogs[index], index: index);
      },
    );
  }

  Widget _buildLoadMoreIndicator(bool loadingMore, ActivityLogsLoaded? state) {
    if (loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: _Sky.blue1, strokeWidth: 2),
          ),
        ),
      );
    }
    if (state?.hasNextPage == true) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: GestureDetector(
            onTap: () => context.read<ActivityLogsCubit>().loadMore(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_Sky.blue1, _Sky.blue2],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _Sky.blue1.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Load More',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          'All logs loaded',
          style: TextStyle(color: _Sky.textMuted, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _Sky.blue5,
              shape: BoxShape.circle,
              border: Border.all(color: _Sky.border, width: 1.5),
            ),
            child: const Icon(
              Icons.search_off_outlined,
              color: _Sky.blue3,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No logs found',
            style: TextStyle(
              color: _Sky.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search query',
            style: TextStyle(color: _Sky.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LightStatsCard extends StatelessWidget {

  const _LightStatsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Sky.border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _Sky.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: _Sky.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LightFilterChip extends StatefulWidget {

  const _LightFilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_LightFilterChip> createState() => _LightFilterChipState();
}

class _LightFilterChipState extends State<_LightFilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.color.withOpacity(0.12)
                : _hovered
                ? widget.color.withOpacity(0.06)
                : _Sky.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected
                  ? widget.color.withOpacity(0.55)
                  : _hovered
                  ? widget.color.withOpacity(0.3)
                  : _Sky.border,
              width: widget.selected ? 1.4 : 1.0,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.selected
                  ? widget.color
                  : _hovered
                  ? widget.color.withOpacity(0.8)
                  : _Sky.textSecondary,
              fontSize: 12.5,
              fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
