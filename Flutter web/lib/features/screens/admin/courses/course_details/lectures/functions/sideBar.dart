import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home_courses/model/model.dart';



class Sidebar extends StatefulWidget {
  const Sidebar({
    super.key,
    required this.collapsed,
    required this.onToggle,
    required this.activeLabel,
    required this.courseModel,
    required this.onIteSelected,
  });
  final bool collapsed;
  final VoidCallback onToggle;
  final String activeLabel;
  final GetCoursesModel courseModel;
  final ValueChanged<String> onIteSelected;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late final List<_SItem> _items;
  late String activeLabel;

  @override
  void initState() {
    super.initState();
    activeLabel = widget.activeLabel;
    _items = [
      _SItem(Icons.details_rounded, 'Course Details'),
      _SItem(Icons.video_library_rounded, 'Lectures'),
      _SItem(Icons.quiz_rounded, 'Quizzes'),
      _SItem(Icons.assignment_rounded, 'Assignments'),
      _SItem(Icons.help_outline_rounded, 'Questions'),
      _SItem(Icons.settings_rounded, 'Settings'),
    ];
  }

  @override
  void didUpdateWidget(Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeLabel != widget.activeLabel) {
      activeLabel = widget.activeLabel;
    }
  }

  void _setActive(String label) {
    setState(() => activeLabel = label);
    widget.onIteSelected(label);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: widget.collapsed ? 68.0 : 220.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(4, 0),
            ),
          ],
          border: Border(
            right: BorderSide(
              color: const Color(0xFF0EA5E9).withOpacity(0.12),
            ),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _items.length,
                itemBuilder: (_, i) => STile(
                  item: _items[i],
                  active: _items[i].label == activeLabel,
                  collapsed: widget.collapsed,
                  onTap: () => _setActive(_items[i].label),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF0EA5E9).withOpacity(0.12),
          ),
        ),
      ),
      child: widget.collapsed
          ? Center(
        child: GestureDetector(
          onTap: widget.onToggle,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF0EA5E9),
              size: 20,
            ),
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'SkyLearn',
                style: TextStyle(
                  color: Color(0xFF0369A1),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: widget.onToggle,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF0EA5E9),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(widget.collapsed ? 10 : 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF0EA5E9).withOpacity(0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Color(0xFF0369A1),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'System Administrator',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SItem {
  const _SItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class STile extends StatefulWidget {
  const STile({
    super.key,
    required this.item,
    required this.active,
    required this.collapsed,
    required this.onTap,
  });
  final _SItem item;
  final bool active;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<STile> createState() => STileState();
}

class STileState extends State<STile> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final bool a = widget.active;

    final Widget tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 0 : 12,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: a
                ? const Color(0xFFE0F2FE)
                : _hov
                ? const Color(0xFFF0F9FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: a
                  ? const Color(0xFF38BDF8).withOpacity(0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: widget.collapsed
              ? Center(
            child: AnimatedScale(
              scale: _hov ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 160),
              child: Icon(
                widget.item.icon,
                size: 20,
                color: a
                    ? const Color(0xFF0284C7)
                    : _hov
                    ? const Color(0xFF0EA5E9)
                    : const Color(0xFF94A3B8),
              ),
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: a ? 18 : 0,
                margin: const EdgeInsets.only(right: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedScale(
                scale: _hov && !a ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 160),
                child: Icon(
                  widget.item.icon,
                  size: 19,
                  color: a
                      ? const Color(0xFF0284C7)
                      : _hov
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 11),
              Flexible(
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: a ? FontWeight.w700 : FontWeight.w500,
                    color: a
                        ? const Color(0xFF0369A1)
                        : _hov
                        ? const Color(0xFF0EA5E9)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
              if (a) const Spacer(),
              if (a) const _PulseDot(),
            ],
          ),
        ),
      ),
    );

    if (widget.collapsed) {
      return Tooltip(
        message: widget.item.label,
        preferBelow: false,
        textStyle: const TextStyle(
          color: Color(0xFF0369A1),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBAE6FD)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withOpacity(0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: tile,
      );
    }

    return tile;
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}