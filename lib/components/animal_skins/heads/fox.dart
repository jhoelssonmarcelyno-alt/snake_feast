// lib/components/animal_skins/heads/fox.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../utils.dart';

void foxBack(Canvas canvas, double hr, Color body) {
  for (final s in [-1.0, 1.0]) {
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.35, s * hr * 1.0)
          ..lineTo(-hr * 1.10, s * hr * 2.20)
          ..lineTo( hr * 0.18, s * hr * 1.05)
          ..close(),
        shadowP(0.22));
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.33, s * hr * 0.98)
          ..lineTo(-hr * 1.06, s * hr * 2.16)
          ..lineTo( hr * 0.16, s * hr * 1.03)
          ..close(),
        Paint()..color = body);
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.30, s * hr * 1.02)
          ..lineTo(-hr * 0.88, s * hr * 1.95)
          ..lineTo( hr * 0.10, s * hr * 1.06)
          ..close(),
        Paint()..color = const Color(0xFF1A1A1A));
  }
}

void foxFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.54, hr * 0.06),
          width: hr * 1.25, height: hr * 0.84),
      Paint()..color = Colors.white);
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.82, -hr * 0.08),
          width: hr * 0.30, height: hr * 0.22),
      Paint()..color = const Color(0xFF1A1A1A));
  canvas.drawCircle(Offset(hr * 0.75, -hr * 0.11), hr * 0.09,
      Paint()..color = Colors.white.withValues(alpha: 0.65));
  for (final s in [-1.0, 1.0]) {
    drawEye(canvas, Offset(hr * 0.12, s * hr * 0.44), hr * 0.28,
        irisColor: const Color(0xFFAF7700), slitPupil: true);
    canvas.drawCircle(Offset(hr * 0.52, s * hr * 0.52), hr * 0.18,
        Paint()..color = const Color(0xFFFF8F00).withValues(alpha: 0.38));
  }
  final wP = Paint()
    ..color = Colors.white.withValues(alpha: 0.90)
    ..strokeWidth = hr * 0.07
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawLine(Offset(hr * 0.48, s * hr *  0.09), Offset(hr * 1.42, s * hr *  0.03), wP);
    canvas.drawLine(Offset(hr * 0.48, s * hr *  0.09), Offset(hr * 1.40, s * hr *  0.27), wP);
    canvas.drawLine(Offset(hr * 0.48, s * hr *  0.09), Offset(hr * 1.38, s * hr * -0.16), wP);
  }
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.62, hr * 0.30),
          width: hr * 0.78, height: hr * 0.52),
      0, pi, false,
      Paint()
        ..color = darken(body, 0.22)
        ..strokeWidth = hr * 0.12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
  final lt = sin(t * 3) * 0.48 + 0.52;
  if (lt > 0.25) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * (0.95 + lt * 0.14), hr * 0.32),
            width: hr * 0.22,
            height: hr * (0.17 + lt * 0.07)),
        Paint()..color = const Color(0xFFFF80AB));
  }
}
