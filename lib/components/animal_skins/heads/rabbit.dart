// lib/components/animal_skins/heads/rabbit.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Colors;
import '../utils.dart';

void rabbitBack(Canvas canvas, double hr, Color body) {
  for (final s in [-1.0, 1.0]) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(hr * 0.05, s * hr * 2.10),
                width: hr * 0.58, height: hr * 2.00),
            const Radius.circular(14)),
        shadowP(0.22));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(hr * 0.06, s * hr * 2.08),
                width: hr * 0.56, height: hr * 1.98),
            const Radius.circular(13)),
        Paint()..color = body);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(hr * 0.06, s * hr * 2.08),
                width: hr * 0.28, height: hr * 1.48),
            const Radius.circular(9)),
        Paint()..color = const Color(0xFFFFB6C1));
  }
}

void rabbitFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawPath(
      Path()
        ..moveTo(hr * 0.60, -hr * 0.09)
        ..lineTo(hr * 0.71,  hr * 0.07)
        ..lineTo(hr * 0.49,  hr * 0.07)
        ..close(),
      Paint()..color = const Color(0xFFFF85A1));
  for (final s in [-1.0, 1.0]) {
    canvas.drawCircle(Offset(hr * 0.52, s * hr * 0.44), hr * 0.24,
        Paint()..color = const Color(0xFFFFB6C1).withValues(alpha: 0.50));
    drawEye(canvas, Offset(hr * 0.14, s * hr * 0.42), hr * 0.30,
        irisColor: const Color(0xFFFF85A1));
  }
  final mP = Paint()
    ..color = darken(body, 0.22)
    ..strokeWidth = hr * 0.09
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(hr * 0.60, hr * 0.08), Offset(hr * 0.55, hr * 0.22), mP);
  canvas.drawLine(Offset(hr * 0.55, hr * 0.22), Offset(hr * 0.64, hr * 0.16), mP);
  canvas.drawLine(Offset(hr * 0.64, hr * 0.16), Offset(hr * 0.73, hr * 0.22), mP);
  canvas.drawLine(Offset(hr * 0.73, hr * 0.22), Offset(hr * 0.68, hr * 0.08), mP);
  canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(hr * 0.56, hr * 0.08, hr * 0.17, hr * 0.21),
          const Radius.circular(3)),
      Paint()..color = Colors.white);
  final wP = Paint()
    ..color = Colors.white.withValues(alpha: 0.90)
    ..strokeWidth = hr * 0.07
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawLine(Offset(hr * 0.46, s * hr * 0.08), Offset(hr * 1.38, s * hr * 0.02), wP);
    canvas.drawLine(Offset(hr * 0.46, s * hr * 0.08), Offset(hr * 1.35, s * hr * 0.24), wP);
  }
}
