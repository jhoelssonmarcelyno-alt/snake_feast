import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const NameField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Largura fixa reduzida
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white12,
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Seu nome',
          hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ),
    );
  }
}
