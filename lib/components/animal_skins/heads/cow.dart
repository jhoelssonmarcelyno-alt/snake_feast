// lib/components/animal_skins/heads/cow.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../utils.dart';

void cowBack(Canvas canvas, double hr) {
  for (final s in [-1.0, 1.0]) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.20, s * hr * 1.45),
            width: hr * 1.30, height: hr * 0.65),
        shadowP(0.20));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.18, s * hr * 1.43),
            width: hr * 1.28, height: hr * 0.63),
        Paint()..color = const Color(0xFFEEEEEE));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.18, s * hr * 1.43),
            width: hr * 0.70, height: hr * 0.32),
        Paint()..color = const Color(0xFFFFCDD2));
  }
}

void cowFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(hr * 0.50, hr * 0.12),
              width: hr * 1.15, height: hr * 0.95),
          const Radius.circular(10)),
      Paint()..color = const Color(0xFFDDDDDD));
  for (final s in [-1.0, 1.0]) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.72, s * hr * 0.22),
            width: hr * 0.30, height: hr * 0.22),
        Paint()..color = const Color(0xFF9E9E9E));
    drawEye(canvas, Offset(hr * 0.10, s * hr * 0.48), hr * 0.29,
        irisColor: const Color(0xFF5D4037));
    final lashP = Paint()
      ..color = Colors.black
      ..strokeWidth = hr * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int c = 0; c < 4; c++) {
      final lx = hr * (-0.06 + c * 0.10);
      canvas.drawLine(
          Offset(lx, s * hr * 0.48 - hr * 0.27 * s),
          Offset(lx - hr * 0.06, s * hr * 0.48 - hr * 0.44 * s),
          lashP);
    }
  }
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-hr * 0.32, -hr * 0.52),
          width: hr * 0.75, height: hr * 0.55),
      Paint()..color = const Color(0xFF212121).withValues(alpha: 0.55));
}
