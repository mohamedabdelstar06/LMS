import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({super.key, required this.text});
  final String text;

  @override
  State<ExpandableDescription> createState() =>
      ExpandableDescriptionState();
}

class ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            firstChild: Text(
              widget.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xFF475569), fontSize: 14, height: 1.7),
            ),
            secondChild: Text(
              widget.text,
              style: const TextStyle(
                  color: Color(0xFF475569), fontSize: 14, height: 1.7),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                color: Color(0xFF0EA5E9),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}