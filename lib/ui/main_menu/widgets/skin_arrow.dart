// lib/ui/main_menu/widgets/skin_arrow.dart
import 'package:flutter/material.dart';

class SkinArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap; // ← Torna opcional
  final double scale;

  const SkinArrow({
    super.key,
    required this.icon,
    this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40 * scale,
        height: 40 * scale,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24 * scale),
      ),
    );
  }
}
