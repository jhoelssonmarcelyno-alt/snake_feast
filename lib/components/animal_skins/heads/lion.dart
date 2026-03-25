// lib/components/animal_skins/heads/lion.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../utils.dart';

void lionBack(Canvas canvas, double hr) {
  final maneColors = [
    const Color(0xFF6D3E00),
    const Color(0xFF8B5E0A),
    const Color(0xFFA07212),
  ];
  for (int ring = 2; ring >= 0; ring--) {
    final count = 12 + ring * 5;
    for (int i = 0; i < count; i++) {
      final a    = (i / count) * pi * 2;
      final dist = hr * (1.40 + ring * 0.30);
      final len  = hr * (0.60 + ring * 0.22);
      canvas.drawLine(
        Offset(cos(a) * dist * 0.80, sin(a) * dist * 0.80),
        Offset(cos(a) * (dist + len), sin(a) * (dist + len)),
        Paint()
          ..color = maneColors[ring]
          ..strokeWidth = hr * (0.32 - ring * 0.05)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }
}

void lionFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.44, hr * 0.08),
          width: hr * 1.35, height: hr * 1.05),
      Paint()..color = const Color(0xFFE8C87A));
  canvas.drawPath(
      Path()
        ..moveTo(hr * 0.64, -hr * 0.16)
        ..lineTo(hr * 0.83,  hr * 0.14)
        ..lineTo(hr * 0.45,  hr * 0.14)
        ..close(),
      Paint()..color = const Color(0xFFD2691E));
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.12, s * hr * 0.46), hr * 0.30,
        irisColor: const Color(0xFFFFB300));
  }
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.56, hr * 0.28),
          width: hr * 0.95, height: hr * 0.68),
      0, pi, true,
      Paint()..color = const Color(0xFF8B0000));
  final tooth = Paint()..color = Colors.white;
  for (final tx in [hr * 0.28, hr * 0.68]) {
    canvas.drawPath(
        Path()
          ..moveTo(tx,             hr * 0.28)
          ..lineTo(tx + hr * 0.08, hr * 0.52)
          ..lineTo(tx + hr * 0.16, hr * 0.28)
          ..close(),
        tooth);
  }
  final wP = Paint()
    ..color = Colors.white.withValues(alpha: 0.85)
    ..strokeWidth = hr * 0.08
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawLine(Offset(hr * 0.48, s * hr * 0.10), Offset(hr * 1.45, s * hr * 0.04), wP);
    canvas.drawLine(Offset(hr * 0.48, s * hr * 0.10), Offset(hr * 1.42, s * hr * 0.28), wP);
  }
}
