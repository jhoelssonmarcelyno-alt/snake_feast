// lib/ui/main_menu/painters/grass_painter.dart
// Painter do padrão de grama sutil no fundo do menu
import 'dart:math';
import 'package:flutter/material.dart';

class GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rng = Random(42);
    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final h = 8.0 + rng.nextDouble() * 12;
      canvas.drawLine(Offset(x, y), Offset(x + 2, y - h), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
