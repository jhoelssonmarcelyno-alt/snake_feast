// lib/ui/main_menu/widgets/tip_widgets.dart
import 'package:flutter/material.dart';

class Tip extends StatelessWidget {
  final String icon;
  final String label;
  final double scale;
  final Color color;

  const Tip({
    super.key,
    required this.icon,
    required this.label,
    this.scale = 1.0,
    this.color = const Color(0xFF00E5FF),
  });

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 44 * scale,
        height: 44 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(icon,
              style: TextStyle(
                fontSize: 18 * scale,
                decoration: TextDecoration.none,
              )),
        ),
      ),
      SizedBox(height: 5 * scale),
      Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 9 * scale,
            height: 1.3,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            shadows: [
              Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4)
            ],
          )),
    ]);
  }
}

class TipDivider extends StatelessWidget {
  const TipDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.12));
}
