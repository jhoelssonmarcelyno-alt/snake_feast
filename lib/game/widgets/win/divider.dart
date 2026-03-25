import 'package:flutter/material.dart';

class DividerLabel extends StatelessWidget {
  final String label;

  const DividerLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(label, style: const TextStyle(fontSize: 10)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
