
import 'package:flutter/material.dart';

import 'card.dart';
import 'card_title.dart';

class DescriptionCard extends StatefulWidget {
  const DescriptionCard({super.key, required this.text});

  final String text;

  @override
  State<DescriptionCard> createState() => DescriptionCardState();
}

class DescriptionCardState extends State<DescriptionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return CardShip(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(Icons.notes_rounded, 'Description'),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: Text(
              widget.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
                height: 1.7,
              ),
            ),
            secondChild: Text(
              widget.text,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
                height: 1.7,
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                color: Color(0xFF0284C7),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
