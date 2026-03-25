// lib/components/animal_skins/heads/dog.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../utils.dart';

void dogBack(Canvas canvas, double hr) {
  for (final s in [-1.0, 1.0]) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.30, s * hr * 1.60),
            width: hr * 0.90, height: hr * 1.20),
        shadowP(0.22));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.28, s * hr * 1.58),
            width: hr * 0.88, height: hr * 1.18),
        Paint()..color = const Color(0xFFA0522D));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.28, s * hr * 1.58),
            width: hr * 0.55, height: hr * 0.82),
        Paint()..color = const Color(0xFFCD853F));
  }
}

void dogFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.54, hr * 0.08),
          width: hr * 1.15, height: hr * 0.90),
      Paint()..color = const Color(0xFFD2A679));
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.80, -hr * 0.12),
          width: hr * 0.48, height: hr * 0.32),
      Paint()..color = const Color(0xFF1A1A1A));
  canvas.drawCircle(Offset(hr * 0.73, -hr * 0.16), hr * 0.10,
      Paint()..color = Colors.white.withValues(alpha: 0.65));
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.12, s * hr * 0.44), hr * 0.30,
        irisColor: const Color(0xFF8B4513));
    final browP = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = hr * 0.14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(hr * -0.05, s * hr * 0.22),
        Offset(hr *  0.34, s * hr * 0.18),
        browP);
  }
  final lick = sin(t * 3) * 0.28 + 0.72;
  canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(hr * (0.80 + lick * 0.18), hr * (0.38 + lick * 0.10)),
              width: hr * 0.40,
              height: hr * (0.58 + lick * 0.16)),
          const Radius.circular(10)),
      Paint()..color = const Color(0xFFFF6B8A));
}
