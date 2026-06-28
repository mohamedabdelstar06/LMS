import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/Announcement/cubit.dart';
import 'package:lms/features/screens/Announcement/model.dart';
import 'package:lms/features/screens/Announcement/states.dart';
import 'package:lms/features/screens/admin/department/get_department/model/model.dart';
import 'package:lms/features/screens/admin/department/get_department/state_mangment/cubit.dart';
import 'package:lms/features/screens/admin/department/get_department/state_mangment/states.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/model/view.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/state_mangment/cubit.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/state_mangment/states.dart';
import 'package:lms/features/screens/admin/year/get_year/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/year/get_year/state_managment/states.dart';
import 'package:lms/features/screens/admin/year/get_year/model.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart';




const _kDark = Color(0xFF0B1120);
const _kNavy = Color(0xFF0F172A);
const _kSky = Color(0xFF38BDF8);
const _kSkyDim = Color(0xFF0EA5E9);
const _kIndigoS = Color(0xFF6366F1);
const _kSurface = Color(0xFFF0F6FF);
const _kCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFDDE6F0);
const _kSlate = Color(0xFF64748B);
const _kMuted = Color(0xFF94A3B8);
const _kGreen = Color(0xFF10B981);
const _kAmber = Color(0xFFF59E0B);
const _kRed = Color(0xFFEF4444);

const _audienceColors = {
  0: Color(0xFF6366F1),
  1: Color(0xFF0EA5E9),
  2: Color(0xFF10B981),
  3: Color(0xFFF59E0B),
  4: Color(0xFFEC4899),
};


String _audienceLabel(int audienceType) {
  switch (audienceType) {
    case 0:
      return 'All';
    case 1:
      return 'Department';
    case 2:
      return 'Year';
    case 3:
      return 'Squadron';
    case 4:
      return 'Course';
    default:
      return 'All';
  }
}





class AllAnnouncementScreen extends StatelessWidget {
  const AllAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnnouncementCubit()..getAllAnnouncements(),
      child: const _AllAnnouncementView(),
    );
  }
}

class _AllAnnouncementView extends StatefulWidget {
  const _AllAnnouncementView();
  @override
  State<_AllAnnouncementView> createState() => _AllAnnouncementViewState();
}

class _AllAnnouncementViewState extends State<_AllAnnouncementView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabAnim;
  final ScrollController _scroll = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scroll.addListener(() {
      final scrolled = _scroll.offset > 80;
      if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _goToAdd() {
    final cubit = context.read<AnnouncementCubit>();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => BlocProvider.value(
          value: cubit,
          child: const AddAnnouncementScreen(),
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) {
      if (mounted) cubit.getAllAnnouncements();
    });
  }

  Future<void> _confirmDelete(int id, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(title: title),
    );
    if (ok == true && mounted) {
      context.read<AnnouncementCubit>().deleteAnnouncement(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: BlocConsumer<AnnouncementCubit, AnnouncementState>(
        listener: (ctx, state) {
          if (state is DeleteAnnouncementSuccess) {
            _showSnack(ctx, 'Announcement deleted', isError: false);
            ctx.read<AnnouncementCubit>().getAllAnnouncements();
          } else if (state is DeleteAnnouncementError) {
            _showSnack(ctx, state.message, isError: true);
          }
        },
        builder: (ctx, state) {
          return CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeroHeaderDelegate(
                  isScrolled: _isScrolled,
                  onAdd: _goToAdd,
                  onRefresh: () =>
                      ctx.read<AnnouncementCubit>().getAllAnnouncements(),
                  stats: state is GetAllAnnouncementsSuccess
                      ? (
                          total: state.totalCount,
                          pages: state.totalPages,
                          page: state.currentPage,
                        )
                      : null,
                ),
              ),

              if (state is GetAllAnnouncementsLoading)
                const SliverFillRemaining(child: _LoadingView())
              else if (state is GetAllAnnouncementsError)
                SliverFillRemaining(
                  child: _ErrorView(
                    message: state.message,
                    onRetry: () =>
                        ctx.read<AnnouncementCubit>().getAllAnnouncements(),
                  ),
                )
              else if (state is GetAllAnnouncementsSuccess) ...[
                if (state.announcements.isEmpty)
                  const SliverFillRemaining(child: _EmptyView())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _AnnouncementCard(
                          announcement: state.announcements[i],
                          index: i,
                          onDelete: () => _confirmDelete(
                            state.announcements[i].id,
                            state.announcements[i].title,
                          ),
                        ),
                        childCount: state.announcements.length,
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),

      
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
        child: FloatingActionButton.extended(
          onPressed: _goToAdd,
          backgroundColor: _kSky,
          foregroundColor: Colors.white,
          elevation: 6,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'New Announcement',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}





class _HeroHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isScrolled;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final ({int total, int pages, int page})? stats;

  const _HeroHeaderDelegate({
    required this.isScrolled,
    required this.onAdd,
    required this.onRefresh,
    this.stats,
  });

  static const double _expandedH = 220;
  static const double _collapsedH = 70;

  @override
  double get minExtent => _collapsedH;
  @override
  double get maxExtent => _expandedH;

  @override
  bool shouldRebuild(_HeroHeaderDelegate o) =>
      o.isScrolled != isScrolled || o.stats != stats;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (_expandedH - _collapsedH)).clamp(0.0, 1.0);
    final isCollapsed = t > 0.85;
    
    
    final available =
        (_expandedH - shrinkOffset).clamp(_collapsedH, _expandedH);
    final showStats = stats != null && available >= _collapsedH + 44;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kDark, Color(0xFF0F2A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isCollapsed
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: (1 - t).clamp(0.0, 1.0),
              child: const _StarField(),
            ),
          ),
          Positioned(
            right: -60,
            top: -60,
            child: Opacity(
              opacity: (1 - t * 1.5).clamp(0.0, 1.0),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kSky.withOpacity(0.12), width: 40),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: _collapsedH - MediaQuery.of(ctx).padding.top,
                    child: Row(
                      children: [
                        _IconBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(ctx),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isCollapsed
                                ? const Text(
                                    'Announcements',
                                    key: ValueKey('c'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  )
                                : Row(
                                    key: const ValueKey('e'),
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _kSky.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.campaign_rounded,
                                          color: _kSky,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Announcements',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          Text(
                                            'اّفــــــاق',
                                            style: TextStyle(
                                              color: _kSky,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        _IconBtn(icon: Icons.refresh_rounded, onTap: onRefresh),
                        const SizedBox(width: 8),
                        _IconBtn(
                          icon: Icons.add_rounded,
                          onTap: onAdd,
                          accent: true,
                        ),
                      ],
                    ),
                  ),
                  if (showStats) ...[
                    const SizedBox(height: 4),
                    Opacity(
                      opacity: (1 - t * 2).clamp(0.0, 1.0),
                      child: _HeaderStatsRow(stats: stats!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.accent = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: accent
              ? _kSky.withOpacity(0.22)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accent
                ? _kSky.withOpacity(0.4)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Icon(icon, color: accent ? _kSky : Colors.white70, size: 18),
      ),
    );
  }
}

class _HeaderStatsRow extends StatelessWidget {
  const _HeaderStatsRow({required this.stats});
  final ({int total, int pages, int page}) stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatPill(
          icon: Icons.campaign_rounded,
          label: '${stats.total} Total',
          color: _kSky,
        ),
        const SizedBox(width: 10),
        _StatPill(
          icon: Icons.auto_stories_outlined,
          label: 'Page ${stats.page} / ${stats.pages}',
          color: _kIndigoS,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}





class _StarField extends StatelessWidget {
  const _StarField();

  static const _stars = [
    (0.08, 0.15, 2.0),
    (0.22, 0.32, 1.4),
    (0.45, 0.12, 1.8),
    (0.65, 0.28, 1.2),
    (0.78, 0.08, 2.2),
    (0.91, 0.40, 1.6),
    (0.15, 0.65, 1.0),
    (0.38, 0.58, 1.8),
    (0.55, 0.72, 1.3),
    (0.72, 0.55, 2.0),
    (0.88, 0.68, 1.1),
    (0.30, 0.85, 1.5),
    (0.60, 0.90, 1.2),
    (0.82, 0.82, 1.7),
    (0.05, 0.45, 1.4),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        children: _stars
            .map(
              (s) => Positioned(
                left: s.$1 * constraints.maxWidth,
                top: s.$2 * constraints.maxHeight,
                child: Container(
                  width: s.$3,
                  height: s.$3,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}





class _AnnouncementCard extends StatefulWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.index,
    required this.onDelete,
  });
  final AnnouncementModel announcement;
  final int index;
  final VoidCallback onDelete;

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _hovered = false;

  Color get _accent =>
      _audienceColors[widget.announcement.audienceType] ??
      _audienceColors[widget.index % _audienceColors.length] ??
      _kSky;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.announcement;
    final fmt = DateFormat('d MMM y  ·  h:mm a');
    final hasImage = a.imageUrl != null && a.imageUrl!.isNotEmpty;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _hovered ? _accent.withOpacity(0.35) : _kBorder,
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? _accent.withOpacity(0.12)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _hovered ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Container(
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.06),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Row(
                      children: [
                        
                        _UserAvatar(
                          name: a.createdByName,
                          imageUrl: a.createdByImageUrl,
                          accent: _accent,
                          size: 40,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.createdByName.isNotEmpty
                                    ? a.createdByName
                                    : 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _kNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _accent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      a.createdByRole.isNotEmpty
                                          ? a.createdByRole
                                          : 'Admin',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      fmt.format(a.createdAt),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: _kMuted,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _CardMenu(
                          accent: _accent,
                          onDelete: widget.onDelete,
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: _accent.withOpacity(0.15),
                    thickness: 1,
                  ),

                  
                  if (hasImage)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AspectRatio(
                          aspectRatio: 3.5,
                          child: Image.network(
                            a.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _accent.withOpacity(0.3),
                                    _accent.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.campaign_rounded,
                                color: _accent,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (a.isPinned) ...[
                          _PinBadge(accent: _accent),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          a.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: _kNavy,
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          a.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kSlate,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(
                      children: [
                        
                        _AudiencePill(
                          announcement: a,
                          accent: _accent,
                        ),
                        const Spacer(),
                        if (a.commentsCount != null)
                          _FooterStat(
                            icon: Icons.chat_bubble_outline_rounded,
                            value: a.commentsCount!,
                          ),
                        if (a.viewsCount != null) ...[
                          const SizedBox(width: 12),
                          _FooterStat(
                            icon: Icons.visibility_outlined,
                            value: a.viewsCount!,
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
      ),
    );
  }
}


class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.name,
    required this.imageUrl,
    required this.accent,
    this.size = 42,
  });
  final String name;
  final String? imageUrl;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImg = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasImg
            ? null
            : LinearGradient(
                colors: [accent, accent.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: hasImg
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _InitialFallback(name: name, accent: accent, size: size),
              )
            : _InitialFallback(name: name, accent: accent, size: size),
      ),
    );
  }
}

class _InitialFallback extends StatelessWidget {
  const _InitialFallback({
    required this.name,
    required this.accent,
    required this.size,
  });
  final String name;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}


class _PinBadge extends StatelessWidget {
  const _PinBadge({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kAmber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kAmber.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.push_pin_rounded, size: 12, color: _kAmber),
          SizedBox(width: 5),
          Text(
            'Pinned',
            style: TextStyle(
              fontSize: 11,
              color: _kAmber,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


class _AudiencePill extends StatelessWidget {
  const _AudiencePill({required this.announcement, required this.accent});
  final AnnouncementModel announcement;
  final Color accent;

  
  
  int get _effectiveType {
    final a = announcement;
    if (a.audienceType != 0) return a.audienceType;
    if (a.courseId != null) return 4;
    if (a.squadronId != null) return 3;
    if (a.yearId != null) return 2;
    if (a.departmentId != null) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final a = announcement;
    final type = _effectiveType;
    String label;
    IconData icon;
    switch (type) {
      case 1:
        final name = a.departmentName;
        label = (name != null && name.isNotEmpty)
            ? 'Dept · $name'
            : 'Department';
        icon = Icons.business_rounded;
        break;
      case 2:
        final name = a.yearName;
        label = (name != null && name.isNotEmpty)
            ? 'Year · $name'
            : 'Year';
        icon = Icons.school_rounded;
        break;
      case 3:
        final name = a.squadronName;
        label = (name != null && name.isNotEmpty)
            ? 'Squadron · $name'
            : 'Squadron';
        icon = Icons.groups_rounded;
        break;
      case 4:
        final name = a.courseTitle;
        label = (name != null && name.isNotEmpty)
            ? 'Course · $name'
            : 'Course';
        icon = Icons.book_rounded;
        break;
      default:
        label = 'All';
        icon = Icons.public_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accent),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  const _FooterStat({required this.icon, required this.value});
  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _kMuted),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12,
            color: _kMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({required this.accent, required this.onDelete});
  final Color accent;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        child: const Icon(Icons.more_vert_rounded, size: 18, color: _kSlate),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 8,
      shadowColor: Colors.black26,
      onSelected: (v) {
        if (v == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kRed.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: _kRed,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Delete',
                style: TextStyle(
                  color: _kRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}





class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kRed.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: _kRed,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Delete Announcement',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Delete "$title"?\nThis cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kSlate,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kSlate,
                      side: const BorderSide(color: _kBorder),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





class AddAnnouncementScreen extends StatelessWidget {
  const AddAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final existing = context.read<AnnouncementCubit?>();
    if (existing != null) return const _AddAnnouncementView();
    return BlocProvider(
      create: (_) => AnnouncementCubit(),
      child: const _AddAnnouncementView(),
    );
  }
}

class _AddAnnouncementView extends StatefulWidget {
  const _AddAnnouncementView();
  @override
  State<_AddAnnouncementView> createState() => _AddAnnouncementViewState();
}

class _AddAnnouncementViewState extends State<_AddAnnouncementView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late final AnimationController _formAnim;
  late final Animation<double> _formFade;

  AnnouncementAudienceType _audience = AnnouncementAudienceType.all;
  bool _isPinned = false;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  DateTime? _startDate;
  DateTime? _endDate;

  int? _deptId, _yearId, _squadId, _courseId;

  @override
  void initState() {
    super.initState();
    _formAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _formFade = CurvedAnimation(parent: _formAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _formAnim.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _kSky)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => isStart ? _startDate = picked : _endDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    context.read<AnnouncementCubit>().addAnnouncement(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      imageBytes: _imageBytes,
      imageFilename: _imageFile?.name,
      startDate: _startDate,
      endDate: _endDate,
      isPinned: _isPinned,
      audienceType: _audience.value,
      departmentId: _deptId,
      yearId: _yearId,
      squadronId: _squadId,
      courseId: _courseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnnouncementCubit, AnnouncementState>(
      listener: (ctx, state) {
        if (state is AnnouncementSuccess) {
          _showSnack(ctx, state.message, isError: false);
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted) Navigator.pop(context);
          });
        } else if (state is AnnouncementError) {
          _showSnack(ctx, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: _kSurface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            
            SliverPersistentHeader(
              pinned: true,
              delegate: _AddScreenHeaderDelegate(),
            ),

            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _formFade,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Section(
                          icon: Icons.edit_document,
                          title: 'Content',
                          accent: _kSky,
                          children: [
                            _Field(
                              ctrl: _titleCtrl,
                              label: 'Title',
                              hint: 'e.g. Final Exam Schedule Released',
                              prefixIcon: Icons.title_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Title is required'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _Field(
                              ctrl: _contentCtrl,
                              label: 'Content',
                              hint: 'Write the full announcement here…',
                              maxLines: 5,
                              prefixIcon: Icons.notes_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Content is required'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _Field(
                              ctrl: _descCtrl,
                              label: 'Short Description (optional)',
                              hint: 'One-line summary shown in previews',
                              maxLines: 2,
                              prefixIcon: Icons.short_text_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          icon: Icons.image_rounded,
                          title: 'Cover Image',
                          accent: _kIndigoS,
                          children: [
                            _ImageTile(
                              file: _imageFile,
                              imageBytes: _imageBytes,
                              onPick: _pickImage,
                              onRemove: () => setState(() {
                                _imageFile = null;
                                _imageBytes = null;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          icon: Icons.calendar_month_rounded,
                          title: 'Schedule (optional)',
                          accent: _kGreen,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _DateTile(
                                    label: 'Start Date',
                                    date: _startDate,
                                    onTap: () => _pickDate(isStart: true),
                                    onClear: () =>
                                        setState(() => _startDate = null),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DateTile(
                                    label: 'End Date',
                                    date: _endDate,
                                    onTap: () => _pickDate(isStart: false),
                                    onClear: () =>
                                        setState(() => _endDate = null),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          icon: Icons.groups_2_rounded,
                          title: 'Target Audience',
                          accent: _kAmber,
                          children: [
                            _AudienceChips(
                              selected: _audience,
                              onChanged: (v) => setState(() {
                                _audience = v;
                                _deptId = null;
                                _yearId = null;
                                _squadId = null;
                                _courseId = null;
                              }),
                            ),
                            if (_audience != AnnouncementAudienceType.all) ...[
                              const SizedBox(height: 14),
                              _AudienceDropdownsWidget(
                                audience: _audience,
                                deptId: _deptId,
                                yearId: _yearId,
                                squadId: _squadId,
                                courseId: _courseId,
                                onDeptChanged: (v) => setState(() {
                                  _deptId = v;
                                  _yearId = null;
                                }),
                                onYearChanged: (v) =>
                                    setState(() => _yearId = v),
                                onSquadChanged: (v) =>
                                    setState(() => _squadId = v),
                                onCourseChanged: (v) =>
                                    setState(() => _courseId = v),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          icon: Icons.tune_rounded,
                          title: 'Options',
                          accent: _kIndigoS,
                          children: [
                            _PinnedToggle(
                              value: _isPinned,
                              onChanged: (v) => setState(() => _isPinned = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _PublishButton(onPressed: _submit),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _PublishButton extends StatelessWidget {
  const _PublishButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementCubit, AnnouncementState>(
      builder: (ctx, state) {
        final loading = state is AnnouncementLoading;
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: loading ? _kSky.withOpacity(0.6) : _kSky,
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: _kSky.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.campaign_rounded, size: 22),
            label: Text(loading ? 'Publishing…' : 'Publish Announcement'),
          ),
        );
      },
    );
  }
}





class _AddScreenHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double _expandedH = 200;
  static const double _collapsedH = 70;

  @override
  double get minExtent => _collapsedH;
  @override
  double get maxExtent => _expandedH;

  @override
  bool shouldRebuild(_AddScreenHeaderDelegate o) => false;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (_expandedH - _collapsedH)).clamp(0.0, 1.0);
    final isCollapsed = t > 0.85;
    
    final available =
        (_expandedH - shrinkOffset).clamp(_collapsedH, _expandedH);
    final showExpanded = available >= _collapsedH + 90;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kDark, Color(0xFF0F2A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isCollapsed
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          
          Positioned.fill(
            child: Opacity(
              opacity: (1 - t).clamp(0.0, 1.0),
              child: const _StarField(),
            ),
          ),
          
          Positioned(
            right: -60,
            top: -60,
            child: Opacity(
              opacity: (1 - t * 1.5).clamp(0.0, 1.0),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kSky.withOpacity(0.12), width: 40),
                ),
              ),
            ),
          ),
          
          Positioned(
            left: -40,
            bottom: -40,
            child: Opacity(
              opacity: (1 - t * 2).clamp(0.0, 1.0),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kIndigoS.withOpacity(0.10),
                    width: 28,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  SizedBox(
                    height: _collapsedH - MediaQuery.of(ctx).padding.top,
                    child: Row(
                      children: [
                        _IconBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(ctx),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isCollapsed
                                ? const Text(
                                    'New Announcement',
                                    key: ValueKey('collapsed'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('expanded'),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  if (showExpanded) ...[
                    Opacity(
                      opacity: (1 - t * 2).clamp(0.0, 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _kSky.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.campaign_rounded,
                                  color: _kSky,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'New Announcement',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  Text(
                                    'Broadcast to your audience',
                                    style: TextStyle(
                                      color: _kSky,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              _StatPill(
                                icon: Icons.edit_note_rounded,
                                label: 'Fill all required fields',
                                color: _kIndigoS,
                              ),
                              const SizedBox(width: 8),
                              _StatPill(
                                icon: Icons.send_rounded,
                                label: 'Publish below',
                                color: _kSky,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}






class _AudienceDropdownsWidget extends StatelessWidget {
  const _AudienceDropdownsWidget({
    required this.audience,
    required this.deptId,
    required this.yearId,
    required this.squadId,
    required this.courseId,
    required this.onDeptChanged,
    required this.onYearChanged,
    required this.onSquadChanged,
    required this.onCourseChanged,
  });

  final AnnouncementAudienceType audience;
  final int? deptId, yearId, squadId, courseId;
  final ValueChanged<int?> onDeptChanged;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int?> onSquadChanged;
  final ValueChanged<int?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DepartmentsCubitDrop()..fetchDepartments()),
        BlocProvider(create: (_) => YearsCubitDrop()..fetchYears()),
        BlocProvider(create: (_) => SquadronsCubitDrop()..fetchSquadrons()),
        BlocProvider(create: (_) => GetCoursesCubit()..getCourses()),
      ],
      child: _AudienceDropdownsBody(
        audience: audience,
        deptId: deptId,
        yearId: yearId,
        squadId: squadId,
        courseId: courseId,
        onDeptChanged: onDeptChanged,
        onYearChanged: onYearChanged,
        onSquadChanged: onSquadChanged,
        onCourseChanged: onCourseChanged,
      ),
    );
  }
}

class _AudienceDropdownsBody extends StatelessWidget {
  const _AudienceDropdownsBody({
    required this.audience,
    required this.deptId,
    required this.yearId,
    required this.squadId,
    required this.courseId,
    required this.onDeptChanged,
    required this.onYearChanged,
    required this.onSquadChanged,
    required this.onCourseChanged,
  });

  final AnnouncementAudienceType audience;
  final int? deptId, yearId, squadId, courseId;
  final ValueChanged<int?> onDeptChanged;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int?> onSquadChanged;
  final ValueChanged<int?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    switch (audience) {
      
      case AnnouncementAudienceType.department:
        return BlocBuilder<DepartmentsCubitDrop, DepartmentsStateDrop>(
          builder: (_, state) => _DropdownOrLoading<GetDepartmentModel>(
            label: 'Department',
            icon: Icons.business_rounded,
            state: state,
            isLoading: state is DepartmentLoadingState,
            isError: state is DepartmentsErrorState,
            errorMsg: state is DepartmentsErrorState ? state.message : '',
            items: state is DepartmentLoadedState
                ? state.departments.whereType<GetDepartmentModel>().toList()
                : [],
            selectedId: deptId,
            itemId: (d) => d.id,
            itemLabel: (d) => d.name,
            onChanged: onDeptChanged,
          ),
        );

      
      case AnnouncementAudienceType.year:
        return BlocBuilder<DepartmentsCubitDrop, DepartmentsStateDrop>(
          builder: (_, deptState) {
            final departments = deptState is DepartmentLoadedState
                ? deptState.departments.whereType<GetDepartmentModel>().toList()
                : <GetDepartmentModel>[];

            return BlocBuilder<YearsCubitDrop, YearsStateDrop>(
              builder: (_, yearState) {
                final allYears = yearState is YearLoadedState
                    ? yearState.years
                    : <GetYearModel>[];

                
                
                String selectedDeptName = '';
                if (deptId != null) {
                  final match = departments.where((d) => d.id == deptId);
                  if (match.isNotEmpty) selectedDeptName = match.first.name;
                }

                
                final filteredYears = deptId != null
                    ? allYears
                        .where((y) => y.departmentName == selectedDeptName)
                        .toList()
                    : allYears;

                return Column(
                  children: [
                    _DropdownOrLoading<GetDepartmentModel>(
                      label: 'Department',
                      icon: Icons.business_rounded,
                      state: deptState,
                      isLoading: deptState is DepartmentLoadingState,
                      isError: deptState is DepartmentsErrorState,
                      errorMsg: deptState is DepartmentsErrorState
                          ? deptState.message
                          : '',
                      items: departments,
                      selectedId: deptId,
                      itemId: (d) => d.id,
                      itemLabel: (d) => d.name,
                      onChanged: onDeptChanged,
                    ),
                    const SizedBox(height: 10),
                    
                    if (deptId != null)
                      _DropdownOrLoading<GetYearModel>(
                        label: 'Year',
                        icon: Icons.school_rounded,
                        state: yearState,
                        isLoading: yearState is YearLoadingState,
                        isError: yearState is YearsErrorState,
                        errorMsg: yearState is YearsErrorState
                            ? yearState.message
                            : '',
                        items: filteredYears,
                        selectedId: yearId,
                        itemId: (y) => y.id,
                        itemLabel: (y) => y.name,
                        onChanged: onYearChanged,
                      )
                    else
                      
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _kAmber.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _kAmber.withOpacity(0.25)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: _kAmber,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Select a department first to see its years',
                              style: TextStyle(
                                color: _kAmber,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );

      
      case AnnouncementAudienceType.squadron:
        return BlocBuilder<SquadronsCubitDrop, GetSquadronsState>(
          builder: (_, state) => _DropdownOrLoading<SquadronModel>(
            label: 'Squadron',
            icon: Icons.groups_rounded,
            state: state,
            isLoading: state is GetSquadronsLoading,
            isError: state is GetSquadronsError,
            errorMsg: state is GetSquadronsError ? state.message : '',
            items: state is GetSquadronsLoaded
                ? state.squadrons.whereType<SquadronModel>().toList()
                : [],
            selectedId: squadId,
            itemId: (s) => s.id,
            itemLabel: (s) => '${s.name} (${s.studentCount} students)',
            onChanged: onSquadChanged,
          ),
        );

      
      case AnnouncementAudienceType.course:
        return BlocBuilder<GetCoursesCubit, GetCourseStates>(
          builder: (_, state) => _DropdownOrLoading<GetCoursesModel>(
            label: 'Course',
            icon: Icons.book_rounded,
            state: state,
            isLoading: state is GetCourseLoading,
            isError: state is GetCourseError,
            errorMsg: state is GetCourseError ? state.message : '',
            items: state is GetCourseSuccess
                ? state.courses.whereType<GetCoursesModel>().toList()
                : [],
            selectedId: courseId,
            itemId: (c) => c.id,
            itemLabel: (c) =>
                c.title.isNotEmpty ? c.title : 'Course #${c.id}',
            onChanged: onCourseChanged,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}


class _DropdownOrLoading<T> extends StatelessWidget {
  const _DropdownOrLoading({
    required this.label,
    required this.icon,
    required this.state,
    required this.isLoading,
    required this.isError,
    required this.errorMsg,
    required this.items,
    required this.selectedId,
    required this.itemId,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final dynamic state;
  final bool isLoading;
  final bool isError;
  final String errorMsg;
  final List<T> items;
  final int? selectedId;
  final int Function(T) itemId;
  final String Function(T) itemLabel;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: _kSky),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading ${label}s…',
              style: const TextStyle(color: _kSlate, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (isError) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _kRed.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, size: 16, color: _kRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMsg,
                style: const TextStyle(color: _kRed, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return _ApiDropdown<T>(
      label: label,
      icon: icon,
      items: items,
      selectedId: selectedId,
      itemId: itemId,
      itemLabel: itemLabel,
      onChanged: onChanged,
    );
  }
}





class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
    required this.accent,
  });
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(color: accent.withOpacity(0.12)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 15, color: accent),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.prefixIcon,
    this.validator,
  });
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final int maxLines;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _kNavy),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: _kMuted, fontSize: 13),
        labelStyle: const TextStyle(color: _kSlate, fontSize: 13),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 17, color: _kMuted)
            : null,
        filled: true,
        fillColor: _kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kSky, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

class _AudienceChips extends StatelessWidget {
  const _AudienceChips({required this.selected, required this.onChanged});
  final AnnouncementAudienceType selected;
  final ValueChanged<AnnouncementAudienceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AnnouncementAudienceType.values.map((t) {
        final active = selected == t;
        final color = _audienceColors[t.value] ?? _kSky;
        return GestureDetector(
          onTap: () => onChanged(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? color : _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: active ? color : _kBorder),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              t.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _kSlate,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PinnedToggle extends StatelessWidget {
  const _PinnedToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? _kAmber.withOpacity(0.15) : _kSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value ? _kAmber.withOpacity(0.4) : _kBorder,
            ),
          ),
          child: Icon(
            Icons.push_pin_rounded,
            size: 16,
            color: value ? _kAmber : _kMuted,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pin this announcement',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _kNavy,
                ),
              ),
              Text(
                'Pinned items appear at the top',
                style: TextStyle(fontSize: 11, color: _kSlate),
              ),
            ],
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged, activeColor: _kSky),
      ],
    );
  }
}

class _ApiDropdown<T> extends StatelessWidget {
  const _ApiDropdown({
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedId,
    required this.itemId,
    required this.itemLabel,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final List<T> items;
  final int? selectedId;
  final int Function(T) itemId;
  final String Function(T) itemLabel;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _kMuted),
            const SizedBox(width: 8),
            Text(
              'No $label available',
              style: const TextStyle(color: _kSlate, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedId,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 17, color: _kMuted),
              const SizedBox(width: 8),
              Text(
                'Select $label',
                style: const TextStyle(color: _kSlate, fontSize: 14),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kSlate),
          borderRadius: BorderRadius.circular(12),
          items: items
              .map(
                (item) => DropdownMenuItem<int>(
                  value: itemId(item),
                  child: Row(
                    children: [
                      Icon(icon, size: 15, color: _kSky),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          itemLabel(item),
                          style: const TextStyle(
                            fontSize: 14,
                            color: _kNavy,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.file,
    required this.imageBytes,
    required this.onPick,
    required this.onRemove,
  });
  final XFile? file;
  final Uint8List? imageBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              imageBytes!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        height: 130,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 28, color: _kMuted),
            SizedBox(height: 6),
            Text(
              'Tap to add a cover image',
              style: TextStyle(fontSize: 13, color: _kMuted),
            ),
            Text('Optional', style: TextStyle(fontSize: 11, color: _kBorder)),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final has = date != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: has ? _kSky.withOpacity(0.08) : _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: has ? _kSky : _kBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: has ? _kSky : _kMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: _kMuted),
                  ),
                  Text(
                    has ? DateFormat('MMM d, y').format(date!) : 'Not set',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: has ? _kSky : _kMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (has)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: _kMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}





class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: _kSky, strokeWidth: 2.5),
        SizedBox(height: 16),
        Text(
          'Loading announcements…',
          style: TextStyle(color: _kSlate, fontSize: 14),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kRed.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded, size: 40, color: _kRed),
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _kSlate),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kSky,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _kSky.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.campaign_outlined, size: 44, color: _kSky),
        ),
        const SizedBox(height: 16),
        const Text(
          'No announcements yet',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap "+ New Announcement" to publish your first one',
          style: TextStyle(fontSize: 13, color: _kSlate),
        ),
      ],
    ),
  );
}

void _showSnack(BuildContext ctx, String msg, {required bool isError}) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: isError ? _kRed : _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
