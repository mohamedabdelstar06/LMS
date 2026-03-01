import 'package:flutter/material.dart';

import '../../../../core/cons/context/navigation_key.dart';
import '../../admin/courses/home_courses/view.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({required this.collapsed, required this.onToggle});
  final bool collapsed;
  final VoidCallback onToggle;

  static final _items = [
    //? _SItem(Icons.dashboard_rounded, 'Dashboard'),
    _SItem(Icons.video_library_rounded, 'Lectures', onTap: () {}),
    _SItem(Icons.book_rounded, 'Courses', onTap: () {
      Navigator.pushReplacement(navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => const AdminCourseScreen()));
    }),
    // ? _SItem(Icons.people_rounded, 'Users'),
    // ? _SItem(Icons.apartment_rounded, 'Departments'),
    // ?_SItem(Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: collapsed ? 70.0 : 230.0,
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
              child: collapsed
                  ? Center(
                child: GestureDetector(
                  onTap: onToggle,
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
                    onTap: onToggle,
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
                  active: _items[i].label == 'Lectures',
                  collapsed: collapsed,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(collapsed ? 10 : 14),
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
                if (!collapsed) ...[
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
      ), // AnimatedContainer
    ); // ClipRect
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

class STileState extends State<STile> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final a = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 10 : 12, vertical: 11),
          decoration: BoxDecoration(
            color: a
                ? const Color(0xFF175CD3)
                : _hov
                ? const Color(0xFF1E293B)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.collapsed
              ? Center(
            child: Icon(widget.item.icon,
                size: 20,
                color: a
                    ? Colors.white
                    : _hov
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF64748B)),
          )
              : Row(children: [
            Icon(widget.item.icon,
                size: 19,
                color: a
                    ? Colors.white
                    : _hov
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF64748B)),
            const SizedBox(width: 11),
            Expanded(
              child: Text(widget.item.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      a ? FontWeight.w600 : FontWeight.w500,
                      color: a
                          ? Colors.white
                          : _hov
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF94A3B8))),
            ),
            if (a)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
          ]),
        ),
      ),
    );
  }
}
