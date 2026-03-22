// lib/ui/main_menu/widgets/menu_title.dart
// Título "SNAKE FEAST" com gradiente e sombra
import 'package:flutter/material.dart';

class MenuTitle extends StatelessWidget {
  final double scale;
  final Animation<double> titleFade;
  final Animation<double> subtitleFade;
  final Animation<Offset> titleSlide;

  const MenuTitle({
    super.key,
    required this.scale,
    required this.titleFade,
    required this.subtitleFade,
    required this.titleSlide,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: titleSlide,
      child: FadeTransition(
        opacity: titleFade,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SnakeFeastTitle(scale: scale),
            const SizedBox(height: 4),
            FadeTransition(
              opacity: subtitleFade,
              child: Text(
                'O SEU DESAFIO DE COBRA!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9 * scale,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnakeFeastTitle extends StatelessWidget {
  final double scale;
  const _SnakeFeastTitle({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'SNAKE FEAST',
          style: TextStyle(
            fontSize: 36 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.black.withValues(alpha: 0.35),
            decoration: TextDecoration.none,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFFFF3CAC),
              Color(0xFF784BA0), Color(0xFF29CFFF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'SNAKE FEAST',
            style: TextStyle(
              fontSize: 36 * scale,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
