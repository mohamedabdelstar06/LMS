import 'package:flutter/cupertino.dart';

class MetaChip extends StatelessWidget {
  const MetaChip(this.icon, this.label,
      {this.color = const Color(0xFF64748B)});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }
}