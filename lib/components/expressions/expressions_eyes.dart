// lib/components/expressions/expressions_eyes.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, Color;

void drawEyesNormal(Canvas canvas, double hr, Paint eyeWhite, Paint eyePupil,
    Color bodyColorDark) {
  for (final ey in [-hr * 0.42, hr * 0.42]) {
    canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.28, eyeWhite);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.26, ey),
            width: hr * 0.13,
            height: hr * 0.26),
        eyePupil);
    canvas.drawCircle(Offset(hr * 0.17, ey - hr * 0.10), hr * 0.09,
        Paint()..color = Colors.white.withValues(alpha: 0.85));
  }
}

void drawEyesAngry(Canvas canvas, double hr, Paint eyeWhite, Paint eyePupil,
    Color bodyColorDark) {
  final brow = Paint()
    ..color = bodyColorDark
    ..strokeWidth = hr * 0.18
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    final ey = s * hr * 0.42;
    canvas.drawLine(Offset(hr * 0.06, ey - s * hr * 0.22),
        Offset(hr * 0.44, ey - s * hr * 0.10), brow);
    canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.26, eyeWhite);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.26, ey),
            width: hr * 0.12,
            height: hr * 0.24),
        eyePupil);
  }
}

void drawEyesHappy(Canvas canvas, double hr, Color bodyColorDark) {
  final ep = Paint()
    ..color = bodyColorDark
    ..strokeWidth = hr * 0.16
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final ey in [-hr * 0.44, hr * 0.44]) {
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(hr * 0.22, ey),
            width: hr * 0.54,
            height: hr * 0.46),
        pi,
        pi,
        false,
        ep);
  }
}

void drawEyesRound(Canvas canvas, double hr, Paint eyeWhite, Paint eyePupil,
    Color irisColor) {
  for (final ey in [-hr * 0.40, hr * 0.40]) {
    canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.30, eyeWhite);
    canvas.drawCircle(
        Offset(hr * 0.26, ey), hr * 0.18, Paint()..color = irisColor);
    canvas.drawCircle(Offset(hr * 0.26, ey), hr * 0.09, eyePupil);
    canvas.drawCircle(Offset(hr * 0.18, ey - hr * 0.12), hr * 0.08,
        Paint()..color = Colors.white.withValues(alpha: 0.90));
  }
}
