// lib/ui/main_menu/widgets/tips_column.dart
// Dicas no canto esquerdo inferior
import 'package:flutter/material.dart';

class TipsColumn extends StatelessWidget {
  final Animation<double> fadeAnim;

  const TipsColumn({super.key, required this.fadeAnim});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Tip(icon: '☝', label: 'Arraste p/ mover', color: Color(0xFFFF9500)),
          SizedBox(height: 8),
          _Tip(icon: '✦', label: 'Coma p/ crescer',  color: Color(0xFF2ECC71)),
          SizedBox(height: 8),
          _Tip(icon: '⚡', label: 'Boost no botão',   color: Color(0xFFFF9500)),
          SizedBox(height: 8),
          _Tip(icon: '☠', label: 'Evite colisões',   color: Color(0xFFE74C3C)),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String icon, label;
  final Color color;
  const _Tip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.18),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 13, decoration: TextDecoration.none)),
          ),
        ),
        const SizedBox(width: 7),
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
              shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4)],
            )),
      ],
    );
  }
}
