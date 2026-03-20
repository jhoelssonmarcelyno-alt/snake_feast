// lib/ui/main_menu/widgets/glow_icon_button.dart
import 'package:flutter/material.dart';

class GlowIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  const GlowIconButton(
      {super.key, required this.onTap, required this.color, required this.icon});

  @override
  State<GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<GlowIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Fundo sólido para ser visível no fundo verde
            color: const Color(0xFF29CFFF).withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF29CFFF).withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
