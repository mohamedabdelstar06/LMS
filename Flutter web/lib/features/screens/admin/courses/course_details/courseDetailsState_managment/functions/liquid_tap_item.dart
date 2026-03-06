import 'package:flutter/cupertino.dart';

class TabItem extends StatefulWidget {
  const TabItem({super.key,
    required this.label,
    required this.active,
    required this.proximity,
    required this.onTap,
  });

  final String label;
  final bool active;
  final double proximity;
  final VoidCallback onTap;

  @override
  State<TabItem> createState() => TabItemState();
}

class TabItemState extends State<TabItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  bool _isDown = false;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Color.lerp(
      const Color(0xFF64748B),
      const Color(0xFF0369A1),
      widget.proximity,
    )!;

    final fontWeight = widget.active ? FontWeight.w700 : FontWeight.w500;

    return GestureDetector(
      onTapDown: (_) {
        _press.forward();
        setState(() => _isDown = true);
      },
      onTapUp: (_) {
        _press.reverse();
        setState(() => _isDown = false);
        widget.onTap();
      },
      onTapCancel: () {
        _press.reverse();
        setState(() => _isDown = false);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) {
          final scale = 1.0 - _press.value * 0.04;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: fontWeight,
              letterSpacing: widget.active ? 0.1 : 0.0,
            ),
          ),
        ),
      ),
    );
  }
}