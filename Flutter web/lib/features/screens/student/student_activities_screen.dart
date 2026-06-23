// ============================================================
// student_activities_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'student_activities_grades_cubits.dart';
import 'student_activities_grades_models.dart';
import 'student_activities_grades_states.dart';

// ── Palette (same as dashboard) ───────────────────────────────
const _kBg = Color(0xFFF0F6FF);
const _kCard = Colors.white;
const _kBlue = Color(0xFF2563EB);
const _kGreen = Color(0xFF10B981);
const _kOrange = Color(0xFFF59E0B);
const _kRed = Color(0xFFEF4444);
const _kPurple = Color(0xFF7C3AED);
const _kCyan = Color(0xFF0BA5EC);
const _kText = Color(0xFF0F172A);
const _kSub = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);

// ── Activity type config ──────────────────────────────────────
class _TypeConfig {
  const _TypeConfig(this.color, this.icon, this.label);
  final Color color;
  final IconData icon;
  final String label;
}

const _typeMap = {
  'Quiz': _TypeConfig(_kPurple, Icons.quiz_rounded, 'Quiz'),
  'Assignment': _TypeConfig(_kBlue, Icons.assignment_rounded, 'Assignment'),
  'Lecture': _TypeConfig(_kCyan, Icons.play_circle_rounded, 'Lecture'),
  'Exam': _TypeConfig(_kRed, Icons.school_rounded, 'Exam'),
};

_TypeConfig _typeOf(String type) =>
    _typeMap[type] ??
    const _TypeConfig(_kSub, Icons.task_alt_rounded, 'Activity');

const _statusColors = {
  'Completed': _kGreen,
  'Pending': _kOrange,
  'Overdue': _kRed,
  'InProgress': _kBlue,
};

Color _statusColor(String s) => _statusColors[s] ?? _kSub;

// ── Entry ─────────────────────────────────────────────────────
class StudentActivitiesScreen extends StatelessWidget {
  const StudentActivitiesScreen({super.key, this.courseId});
  final int? courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StudentActivitiesCubit()..load(courseId: courseId),
      child: _ActivitiesBody(courseId: courseId),
    );
  }
}

class _ActivitiesBody extends StatefulWidget {
  const _ActivitiesBody({this.courseId});
  final int? courseId;
  @override
  State<_ActivitiesBody> createState() => _ActivitiesBodyState();
}

class _ActivitiesBodyState extends State<_ActivitiesBody> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  String? _selectedType;
  String? _selectedStatus;
  bool _showSearch = false;

  static const _types = ['Quiz', 'Assignment', 'Lecture', 'Exam'];
  static const _statuses = ['Completed', 'Pending', 'Overdue', 'InProgress'];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<StudentActivitiesCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: BlocBuilder<StudentActivitiesCubit, StudentActivitiesState>(
              builder: (ctx, state) {
                if (state is StudentActivitiesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: _kBlue),
                  );
                }
                if (state is StudentActivitiesError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () => ctx
                        .read<StudentActivitiesCubit>()
                        .load(courseId: widget.courseId),
                  );
                }

                final data = state is StudentActivitiesLoaded
                    ? state.data
                    : state is StudentActivitiesLoadingMore
                        ? state.current
                        : null;

                if (data == null) return const SizedBox();

                if (data.items.isEmpty) {
                  return _EmptyActivities(
                    onClear: () {
                      setState(() {
                        _selectedType = null;
                        _selectedStatus = null;
                        _searchCtrl.clear();
                      });
                      ctx.read<StudentActivitiesCubit>().load(
                            courseId: widget.courseId,
                          );
                    },
                  );
                }

                return Column(
                  children: [
                    // Summary bar
                    _SummaryBar(data: data),
                    // List
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: data.items.length +
                            (state is StudentActivitiesLoadingMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == data.items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(color: _kBlue),
                              ),
                            );
                          }
                          return _ActivityCard(
                            activity: data.items[i],
                            index: i,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timeline_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Activities',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _kText)),
              Text('Track your learning progress',
                  style: TextStyle(fontSize: 11, color: _kSub)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _showSearch = !_showSearch),
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: _kSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search field
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _showSearch
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    context.read<StudentActivitiesCubit>().search(v),
                decoration: InputDecoration(
                  hintText: 'Search activities...',
                  hintStyle: const TextStyle(fontSize: 13, color: _kSub),
                  prefixIcon:
                      const Icon(Icons.search_rounded, size: 18, color: _kSub),
                  isDense: true,
                  filled: true,
                  fillColor: _kBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
          // Type filter
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterPill(
                  label: 'All',
                  selected: _selectedType == null,
                  color: _kBlue,
                  onTap: () {
                    setState(() => _selectedType = null);
                    context.read<StudentActivitiesCubit>().filterByType(null);
                  },
                ),
                ..._types.map((t) {
                  final cfg = _typeOf(t);
                  return _FilterPill(
                    label: cfg.label,
                    icon: cfg.icon,
                    selected: _selectedType == t,
                    color: cfg.color,
                    onTap: () {
                      setState(() => _selectedType = t);
                      context
                          .read<StudentActivitiesCubit>()
                          .filterByType(t);
                    },
                  );
                }),
              ],
            ),
          ),
          // Status filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              children: [
                _StatusPill(
                  label: 'Any Status',
                  selected: _selectedStatus == null,
                  color: _kSub,
                  onTap: () {
                    setState(() => _selectedStatus = null);
                    context
                        .read<StudentActivitiesCubit>()
                        .filterByStatus(null);
                  },
                ),
                ..._statuses.map((s) => _StatusPill(
                      label: s,
                      selected: _selectedStatus == s,
                      color: _statusColor(s),
                      onTap: () {
                        setState(() => _selectedStatus = s);
                        context
                            .read<StudentActivitiesCubit>()
                            .filterByStatus(s);
                      },
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),
        ],
      ),
    );
  }
}

// ── Summary Bar ───────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.data});
  final StudentActivitiesPage data;

  @override
  Widget build(BuildContext context) {
    final completed =
        data.items.where((a) => a.status == 'Completed').length;
    final pending =
        data.items.where((a) => a.status == 'Pending').length;
    final overdue =
        data.items.where((a) => a.status == 'Overdue').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          _SummaryChip(
              label: 'Total', value: data.totalCount, color: _kBlue),
          _VertDivider(),
          _SummaryChip(
              label: 'Done', value: completed, color: _kGreen),
          _VertDivider(),
          _SummaryChip(
              label: 'Pending', value: pending, color: _kOrange),
          _VertDivider(),
          _SummaryChip(
              label: 'Overdue', value: overdue, color: _kRed),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: _kSub)),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30,
        color: _kBorder,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

// ── Activity Card ─────────────────────────────────────────────
class _ActivityCard extends StatefulWidget {
  const _ActivityCard({required this.activity, required this.index});
  final StudentActivity activity;
  final int index;
  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide, _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<double>(begin: 30, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _opacity = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    Future.delayed(
        Duration(milliseconds: (widget.index * 60).clamp(0, 300)),
        () {
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
    final a = widget.activity;
    final cfg = _typeOf(a.activityType);
    final statusColor = _statusColor(a.status);
    final pct = a.scorePercent;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
              boxShadow: [
                BoxShadow(
                  color: cfg.color.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Type icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cfg.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(cfg.icon, color: cfg.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _kText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a.courseTitle,
                              style: const TextStyle(
                                  fontSize: 11, color: _kSub),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          a.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Score bar (if scored)
                if (pct != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Score: ${a.score!.toStringAsFixed(0)} / ${a.maxScore!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: _kSub,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: pct >= 60 ? _kGreen : _kRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _ScoreBar(percent: pct / 100, color: cfg.color),
                      ],
                    ),
                  ),
                ],
                // Footer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cfg.color.withOpacity(0.04),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cfg.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.activityType,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: cfg.color),
                        ),
                      ),
                      const Spacer(),
                      if (a.dueDate != null) ...[
                        const Icon(Icons.schedule_rounded,
                            size: 12, color: _kSub),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(a.dueDate!),
                          style: const TextStyle(
                              fontSize: 10, color: _kSub),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Score progress bar ────────────────────────────────────────
class _ScoreBar extends StatefulWidget {
  const _ScoreBar({required this.percent, required this.color});
  final double percent;
  final Color color;
  @override
  State<_ScoreBar> createState() => _ScoreBarState();
}

class _ScoreBarState extends State<_ScoreBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0, end: widget.percent.clamp(0, 1))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => Stack(
        children: [
          Container(
            height: 6,
            width: c.maxWidth,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              height: 6,
              width: c.maxWidth * _anim.value,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.color, widget.color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Pills ──────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData? icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : _kBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: selected ? Colors.white : color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _kSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? color : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? color : _kSub,
          ),
        ),
      ),
    );
  }
}

// ── Empty & Error ─────────────────────────────────────────────
class _EmptyActivities extends StatelessWidget {
  const _EmptyActivities({required this.onClear});
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded,
                size: 40, color: _kBlue),
          ),
          const SizedBox(height: 16),
          const Text('No activities found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText)),
          const SizedBox(height: 6),
          const Text('Try adjusting your filters',
              style: TextStyle(fontSize: 13, color: _kSub)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(
              foregroundColor: _kBlue,
              backgroundColor: _kBlue.withOpacity(0.08),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: _kRed),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kText, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
