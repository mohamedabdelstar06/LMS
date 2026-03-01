import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionBtn extends StatefulWidget {
  const ActionBtn(
      {required this.icon,
        required this.tooltip,
        required this.color,
        required this.onTap});
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  @override
  State<ActionBtn> createState() => ActionBtnState();
}

class ActionBtnState extends State<ActionBtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color:
              _hov ? widget.color.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hov
                    ? widget.color.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Icon(widget.icon, size: 17, color: widget.color),
          ),
        ),
      ),
    );
  }
}