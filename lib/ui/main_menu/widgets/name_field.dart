// lib/ui/main_menu/widgets/name_field.dart
// Campo de texto para o nome do jogador
import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final Animation<double> fadeAnim;
  final double scale;
  final ValueChanged<String> onChanged;

  const NameField({
    super.key,
    required this.controller,
    required this.fadeAnim,
    required this.scale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Container(
        width: 220 * scale,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          const Icon(Icons.person_rounded, color: Color(0xFF27AE35), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 12,
              style: const TextStyle(
                color: Color(0xFF1A5C2A),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
              decoration: const InputDecoration(
                hintText: 'Seu nome...',
                hintStyle: TextStyle(color: Color(0x88336633), fontSize: 13),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
        ]),
      ),
    );
  }
}
