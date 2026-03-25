import 'package:flutter/material.dart';

class XpLine extends StatelessWidget {
  final String label;
  final int value;

  const XpLine({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        Text('+$value XP'),
      ],
    );
  }
}
