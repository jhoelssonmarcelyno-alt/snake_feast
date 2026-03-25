// lib/components/animal_skins/heads/cat.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../utils.dart';

void catBack(Canvas canvas, double hr, Color body) {
  for (final s in [-1.0, 1.0]) {
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.20, s * hr * 1.0)
          ..lineTo(-hr * 0.85, s * hr * 2.40)
          ..lineTo( hr * 0.20, s * hr * 1.05)
          ..close(),
        shadowP(0.30));
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.18, s * hr * 1.0)
          ..lineTo(-hr * 0.82, s * hr * 2.36)
          ..lineTo( hr * 0.18, s * hr * 1.04)
          ..close(),
        Paint()..color = body);
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.16, s * hr * 1.04)
          ..lineTo(-hr * 0.66, s * hr * 2.10)
          ..lineTo( hr * 0.12, s * hr * 1.08)
          ..close(),
        Paint()..color = const Color(0xFFFF80AB));
  }
}

void catFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.16, s * hr * 0.40), hr * 0.28,
        irisColor: const Color(0xFF7DC242), slitPupil: true);
  }
  canvas.drawPath(
      Path()
        ..moveTo(hr * 0.52, -hr * 0.09)
        ..lineTo(hr * 0.66,  hr * 0.10)
        ..lineTo(hr * 0.38,  hr * 0.10)
        ..close(),
      Paint()..color = const Color(0xFFFF80AB));
  final wP = Paint()
    ..color = Colors.white.withValues(alpha: 0.92)
    ..strokeWidth = hr * 0.07
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawLine(Offset(hr * 0.46, s * hr *  0.10), Offset(hr * 1.42, s * hr *  0.02), wP);
    canvas.drawLine(Offset(hr * 0.46, s * hr *  0.10), Offset(hr * 1.38, s * hr *  0.30), wP);
    canvas.drawLine(Offset(hr * 0.46, s * hr *  0.10), Offset(hr * 1.36, s * hr * -0.20), wP);
    canvas.drawCircle(Offset(hr * 0.52, s * hr * 0.55), hr * 0.18,
        Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.40));
  }
  final mP = Paint()
    ..color = darken(body, 0.22)
    ..strokeWidth = hr * 0.09
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(hr * 0.52, hr * 0.11), Offset(hr * 0.47, hr * 0.28), mP);
  canvas.drawLine(Offset(hr * 0.47, hr * 0.28), Offset(hr * 0.58, hr * 0.20), mP);
  canvas.drawLine(Offset(hr * 0.58, hr * 0.20), Offset(hr * 0.69, hr * 0.28), mP);
  canvas.drawLine(Offset(hr * 0.69, hr * 0.28), Offset(hr * 0.65, hr * 0.11), mP);
  final ext = sin(t * 3) * 0.45 + 0.55;
  if (ext > 0.25) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * (0.88 + ext * 0.18), hr * 0.30),
            width: hr * 0.22,
            height: hr * (0.18 + ext * 0.09)),
        Paint()..color = const Color(0xFFFF80AB));
  }
}
