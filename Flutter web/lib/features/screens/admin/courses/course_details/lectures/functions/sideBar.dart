import 'package:flutter/material.dart';

import '../../../../../../../core/cons/context/navigation_key.dart';
import '../../../home_courses/view.dart';
import '../../comments/view/commentLayout.dart';
import '../../comments/view/view.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({required this.collapsed, required this.onToggle, required this.activeLabel});
  final bool collapsed;
  final VoidCallback onToggle;
  final String activeLabel;

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
      _SItem(Icons.book_rounded, 'Courses', onTap: () {
        _setActive('Courses');
        Navigator.pushReplacement(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => const AdminCourseScreen()),
        );
      }),
      _SItem(Icons.video_library_rounded, 'Lectures', onTap: () {
        _setActive('Lectures');
      }),
      _SItem(Icons.quiz_rounded, 'Quizes', onTap: () {
        _setActive('Quizes');
      }),
      _SItem(Icons.assignment_rounded, 'Assignments', onTap: () {
        _setActive('Assignments');
      }),
      _SItem(Icons.help_outline_rounded, 'Questions', onTap: () {
        _setActive('Questions');
      }),
      _SItem(Icons.comment, 'Comments', onTap: () {

        _setActive('Comments');
        Navigator.pushReplacement(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => const CommentLayout()),
        );
      }),
      _SItem(Icons.settings_rounded, 'Settings', onTap: () {
        _setActive('Settings');
      }),
    ];
  }

  void _setActive(String label) {
    setState(() =>  activeLabel = label);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: widget.collapsed ? 70.0 : 230.0,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 16, offset: Offset(4, 0))
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 66,
              decoration: const BoxDecoration(
                  border:
                  Border(bottom: BorderSide(color: Color(0xFF1E293B)))),
              child: widget.collapsed
                  ? Center(
                child: GestureDetector(
                  onTap: widget.onToggle,
                  child: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF64748B), size: 22),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF175CD3), Color(0xFF53B1FD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 17),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('SkyLearn',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: const Icon(Icons.chevron_left_rounded,
                        color: Color(0xFF64748B), size: 20),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _items.length,
                itemBuilder: (_, i) => STile(
                  item: _items[i],
                  active: _items[i].label == activeLabel,
                  collapsed: widget.collapsed,
                ),
              ),
            ),

            Container(
              padding:
              EdgeInsets.all(widget.collapsed ? 10 : 14),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF1E293B)))),
              child: Row(children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF175CD3),
                  child: Text('A',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Text('System Administrator',
                            style: TextStyle(
                                color: Color(0xFF64748B), fontSize: 10),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}


class _SItem {
  const _SItem(this.icon, this.label, {required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}


class STile extends StatefulWidget {
  const STile(
      {required this.item, required this.active, required this.collapsed});
  final _SItem item;
  final bool active;
  final bool collapsed;

  @override
  State<STile> createState() => STileState();
}

class STileState extends State<STile> with SingleTickerProviderStateMixin {
  bool _hov = false;
  late final AnimationController _rippleCtrl;
  late final Animation<double> _rippleAnim;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _rippleAnim = CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _rippleCtrl.forward(from: 0);
    widget.item.onTap();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final bool a = widget.active;

    final Widget tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: _onTap,
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
                ? const Color(0xFF1D4ED8).withOpacity(0.18)
                : _hov
                ? const Color(0xFF1E293B)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: a
                  ? const Color(0xFF3B82F6).withOpacity(0.35)
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
                    ? const Color(0xFF60A5FA)
                    : _hov
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF64748B),
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
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              AnimatedScale(
                scale: _hov && !a ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 160),
                child: Icon(
                  widget.item.icon,
                  size: 19,
                  color: a
                      ? const Color(0xFF60A5FA)
                      : _hov
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF64748B),
                ),
              ),

              if (!widget.collapsed) const SizedBox(width: 11),

              Flexible(
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: a ? FontWeight.w600 : FontWeight.w500,
                    color: a
                        ? Colors.white
                        : _hov
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF94A3B8),
                    letterSpacing: a ? 0.1 : 0,
                  ),
                ),
              ),

              if (a) Expanded(child: const SizedBox(width: double.infinity)),
              if (a) _PulseDot(),
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
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: tile,
      );
    }

    return tile;
  }}


class _PulseDot extends StatefulWidget {
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
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF60A5FA),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}