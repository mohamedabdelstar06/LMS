import 'dart:ui';
import 'package:flutter/material.dart';
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

class _SidebarState extends State<Sidebar>
    with SingleTickerProviderStateMixin {
  late String _activeLabel;
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;

  static const _items = [
    _SItem(Icons.auto_awesome_rounded,   'Dashboard'),
    _SItem(Icons.play_circle_rounded,    'Lectures'),
    _SItem(Icons.quiz_rounded,           'Quizzes'),
    _SItem(Icons.assignment_rounded,     'Assignments'),
  ];

  @override
  void initState() {
    super.initState();
    _activeLabel = widget.activeLabel;
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.collapsed ? 0 : 1,
    );
    _expandAnim = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(Sidebar old) {
    super.didUpdateWidget(old);
    if (old.activeLabel != widget.activeLabel) {
      _activeLabel = widget.activeLabel;
    }
    if (old.collapsed != widget.collapsed) {
      widget.collapsed ? _expandCtrl.reverse() : _expandCtrl.forward();
    }
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _setActive(String label) {
    setState(() => _activeLabel = label);
    widget.onIteSelected(label);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: widget.collapsed ? 70.0 : 224.0,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF0F9FF),
          ],
        ),
        border: Border(
          right: BorderSide(color: Color(0xFFBAE6FD)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x140EA5E9),
            blurRadius: 24,
            offset: Offset(6, 0),
          ),
        ],
      ),
      child: ClipRect(
        child: Column(
          children: [
            _SidebarHeader(
              collapsed: widget.collapsed,
              expandAnim: _expandAnim,
              onToggle: widget.onToggle,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (_, i) => _STile(
                  item: _items[i],
                  active: _items[i].label == _activeLabel,
                  collapsed: widget.collapsed,
                  expandAnim: _expandAnim,
                  onTap: () => _setActive(_items[i].label),
                ),
              ),
            ),
            _SidebarFooter(
              collapsed: widget.collapsed,
              expandAnim: _expandAnim,
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.collapsed,
    required this.expandAnim,
    required this.onToggle,
  });

  final bool collapsed;
  final Animation<double> expandAnim;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE0F2FE))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 16),
            ),
           const SizedBox(width: 7,),

            _ToggleButton(
              onTap: onToggle,
              collapsed: collapsed,
            ),
          ],
        ),
      );
    }

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0F2FE))),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded,
                color: Colors.white, size: 18),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: FadeTransition(
              opacity: expandAnim,
              child: const Text(
                'اّفــــــاق',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF0369A1),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          _ToggleButton(
            onTap: onToggle,
            collapsed: collapsed,
          ),
        ],
      ),
    );
  }
}class _ToggleButton extends StatefulWidget {
  const _ToggleButton({required this.onTap, required this.collapsed});
  final VoidCallback onTap;
  final bool collapsed;

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hov ? const Color(0xFF0EA5E9) : const Color(0xFFE0F2FE),
            shape: BoxShape.circle,
            boxShadow: _hov
                ? const [
              BoxShadow(
                color: Color(0x440EA5E9),
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Icon(
            widget.collapsed
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            size: 16,
            color: _hov ? Colors.white : const Color(0xFF0EA5E9),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    required this.collapsed,
    required this.expandAnim,
  });
  final bool collapsed;
  final Animation<double> expandAnim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? 12 : 14,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0F2FE))),
      ),
      child: Row(
        mainAxisAlignment:
        collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF38BDF8)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          if (!collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: FadeTransition(
                opacity: expandAnim,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Color(0xFF0369A1),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'System Administrator',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      )
    );
  }
}

class _SItem {
  const _SItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _STile extends StatefulWidget {
  const _STile({
    required this.item,
    required this.active,
    required this.collapsed,
    required this.expandAnim,
    required this.onTap,
  });
  final _SItem item;
  final bool active;
  final bool collapsed;
  final Animation<double> expandAnim;
  final VoidCallback onTap;

  @override
  State<_STile> createState() => _STileState();
}

class _STileState extends State<_STile>
    with SingleTickerProviderStateMixin {
  bool _hov = false;
  late AnimationController _ripple;
  late Animation<double> _rippleScale;
  late Animation<double> _rippleOpacity;

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _rippleScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ripple, curve: Curves.easeOutCubic),
    );
    _rippleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ripple, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_STile old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) {
      _ripple.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  Widget _buildTileInner() {
    final a = widget.active;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 0 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: a
                ? null
                : _hov
                ? const Color(0xFFE0F2FE).withOpacity(0.6)
                : Colors.transparent,
            gradient: a
                ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE0F2FE),
                Color(0xFFBAE6FD),
              ],
            )
                : null,
            border: Border.all(
              color: a
                  ? const Color(0xFF7DD3FC).withOpacity(0.7)
                  : _hov
                  ? const Color(0xFFBAE6FD).withOpacity(0.5)
                  : Colors.transparent,
            ),
            boxShadow: a
                ? [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ]
                : _hov
                ? [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: widget.collapsed
              ? _CollapsedContent(
            item: widget.item,
            active: a,
            hov: _hov,
          )
              : _ExpandedContent(
            item: widget.item,
            active: a,
            hov: _hov,
            expandAnim: widget.expandAnim,
            rippleScale: _rippleScale,
            rippleOpacity: _rippleOpacity,
            rippleCtrl: _ripple,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.collapsed) {
      return Tooltip(
        message: widget.item.label,
        preferBelow: false,
        verticalOffset: 4,
        textStyle: const TextStyle(
          color: Color(0xFF0369A1),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBAE6FD)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0EA5E9),
              blurRadius: 10,
            ),
          ],
        ),
        child: _buildTileInner(),
      );
    }
    return _buildTileInner();
  }
}

class _CollapsedContent extends StatelessWidget {
  const _CollapsedContent({
    required this.item,
    required this.active,
    required this.hov,
  });
  final _SItem item;
  final bool active;
  final bool hov;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedScale(
        scale: hov && !active ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Icon(
          item.icon,
          size: 20,
          color: active
              ? const Color(0xFF0284C7)
              : hov
              ? const Color(0xFF0EA5E9)
              : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({
    required this.item,
    required this.active,
    required this.hov,
    required this.expandAnim,
    required this.rippleScale,
    required this.rippleOpacity,
    required this.rippleCtrl,
  });
  final _SItem item;
  final bool active;
  final bool hov;
  final Animation<double> expandAnim;
  final Animation<double> rippleScale;
  final Animation<double> rippleOpacity;
  final AnimationController rippleCtrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (active)
              AnimatedBuilder(
                animation: rippleCtrl,
                builder: (_, __) => Transform.scale(
                  scale: rippleScale.value,
                  child: Opacity(
                    opacity: rippleOpacity.value * 0.25,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF0284C7).withOpacity(0.15)
                    : hov
                    ? const Color(0xFF0EA5E9).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedScale(
                scale: hov && !active ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: Icon(
                  item.icon,
                  size: 17,
                  color: active
                      ? const Color(0xFF0284C7)
                      : hov
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active
                  ? const Color(0xFF0369A1)
                  : hov
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF64748B),
              letterSpacing: active ? -0.2 : 0,
            ),
          ),
        ),
        if (active) ...[
          const SizedBox(width: 6),
          _LiquidGlassDot(),
        ],
      ],
    );
  }
}

class _LiquidGlassDot extends StatefulWidget {
  @override
  State<_LiquidGlassDot> createState() => _LiquidGlassDotState();
}

class _LiquidGlassDotState extends State<_LiquidGlassDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.65, end: 1.25).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.45, end: 1.0).animate(
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
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x550EA5E9),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}