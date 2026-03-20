// lib/ui/main_menu/widgets/skin_arrow.dart
import 'package:flutter/material.dart';

class SkinArrow extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double scale;
  const SkinArrow(
      {super.key, required this.icon, required this.onTap, required this.scale});

  @override
  State<SkinArrow> createState() => _SkinArrowState();
}

class _SkinArrowState extends State<SkinArrow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 40 * s,
          height: 40 * s,
          margin: EdgeInsets.symmetric(horizontal: 5 * s),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.55),
            border: Border.all(
                color: const Color(0xFFFFD600).withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD600).withOpacity(0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(widget.icon, color: const Color(0xFFFFD600), size: 26 * s),
        ),
      ),
    );
  }
}
