import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const StatRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const Spacer(),
        Text(value, style: TextStyle(color: color)),
      ],
    );
  }
}
