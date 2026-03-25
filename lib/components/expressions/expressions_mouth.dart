// lib/components/expressions/expressions_mouth.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Color;

void drawTongue(
  Canvas canvas,
  double hr,
  double t, {
  Color color = const Color(0xFFFF1744),
  double speed = 4,
}) {
  final ext = (sin(t * speed) * 0.5 + 0.5);
  if (ext < 0.05) return;
  final p = Paint()
    ..color = color
    ..strokeWidth = hr * 0.13
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final double base = hr * 1.05;
  final double len = hr * (0.55 + ext * 0.6);
  canvas.drawLine(Offset(base, 0), Offset(base + len, 0), p);
  canvas.drawLine(
      Offset(base + len * 0.55, 0), Offset(base + len, -hr * 0.28), p);
  canvas.drawLine(
      Offset(base + len * 0.55, 0), Offset(base + len, hr * 0.28), p);
}

void drawSmile(Canvas canvas, double hr, Color bodyColorDark) {
  canvas.drawArc(
    Rect.fromCenter(
        center: Offset(hr * 0.3, hr * 0.10),
        width: hr * 1.1,
        height: hr * 0.8),
    0.0,
    pi,
    false,
    Paint()
      ..color = bodyColorDark
      ..strokeWidth = hr * 0.14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round,
  );
}

void drawFrown(Canvas canvas, double hr, Color bodyColorDark) {
  canvas.drawArc(
    Rect.fromCenter(
        center: Offset(hr * 0.3, hr * 0.55),
        width: hr * 0.9,
        height: hr * 0.6),
    pi,
    pi,
    false,
    Paint()
      ..color = bodyColorDark
      ..strokeWidth = hr * 0.14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round,
  );
}
