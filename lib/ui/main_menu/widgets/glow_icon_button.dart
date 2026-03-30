import 'package:flutter/material.dart';

class GlowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const GlowIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white12,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
