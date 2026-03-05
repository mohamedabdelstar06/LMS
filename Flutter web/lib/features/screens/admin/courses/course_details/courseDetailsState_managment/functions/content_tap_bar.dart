import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContentTabBar extends StatelessWidget {
  const ContentTabBar({required this.activeIndex, required this.onTap});
  final int activeIndex;
  final ValueChanged<int> onTap;

  static const _tabs = ['Lectures', 'Quizzes', 'Assignments'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9)
                          .withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      color: active
                          ? const Color(0xFF0369A1)
                          : const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
