// lib/components/animal_skins/heads/fish.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../utils.dart';

void fishBack(Canvas canvas, double hr, Color body, Color dark) {
  for (final s in [-1.0, 1.0]) {
    for (int g = 0; g < 3; g++) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(-hr * 0.12 - g * hr * 0.08, s * hr * 0.80),
            width:  hr * (1.5  - g * 0.22),
            height: hr * (0.90 - g * 0.10)),
        s > 0 ? -pi * 0.12 : pi * 0.12,
        s > 0 ?  pi * 0.55 : -pi * 0.55,
        false,
        Paint()
          ..color = darken(body, 0.18 + g * 0.08).withValues(alpha: 0.75)
          ..strokeWidth = hr * (0.14 - g * 0.03)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

void fishFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.08, s * hr * 0.42), hr * 0.34,
        irisColor: const Color(0xFF0D47A1));
  }
  final mouthOpen = (sin(t * 2) * 0.35 + 0.65).clamp(0.2, 1.0);
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.76, 0),
          width: hr * 0.58, height: hr * (0.48 * mouthOpen)),
      -pi * 0.5, pi, false,
      Paint()
        ..color = darken(body, 0.28)
        ..strokeWidth = hr * 0.14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
  final scaleP = Paint()
    ..color = Colors.white.withValues(alpha: 0.25)
    ..style = PaintingStyle.stroke
    ..strokeWidth = hr * 0.08;
  canvas.drawArc(
      Rect.fromCenter(center: Offset(0, -hr * 0.46), width: hr * 0.65, height: hr * 0.52),
      0, pi, false, scaleP);
  canvas.drawArc(
      Rect.fromCenter(center: Offset(0,  hr * 0.46), width: hr * 0.65, height: hr * 0.52),
      pi, pi, false, scaleP);
}
