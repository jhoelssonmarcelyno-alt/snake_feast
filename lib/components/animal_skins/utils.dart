// lib/components/animal_skins/utils.dart
// Utilitários compartilhados entre todos os animais.
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, HSVColor;

Color lighten(Color c, double v) {
  final h = HSVColor.fromColor(c);
  return h.withValue((h.value + v).clamp(0.0, 1.0)).toColor();
}

Color darken(Color c, double v) {
  final h = HSVColor.fromColor(c);
  return h.withValue((h.value - v).clamp(0.0, 1.0)).toColor();
}

Paint shadowP(double o) => Paint()..color = Colors.black.withValues(alpha: o);

void drawEye(Canvas canvas, Offset center, double r,
    {Color irisColor = const Color(0xFF1A237E), bool slitPupil = false}) {
  canvas.drawCircle(center, r, Paint()..color = Colors.white);
  canvas.drawCircle(center, r * 0.66, Paint()..color = irisColor);
  if (slitPupil) {
    canvas.drawOval(
        Rect.fromCenter(center: center, width: r * 0.20, height: r * 0.62),
        Paint()..color = Colors.black);
  } else {
    canvas.drawCircle(center, r * 0.32, Paint()..color = Colors.black);
  }
  canvas.drawCircle(Offset(center.dx - r * 0.28, center.dy - r * 0.28),
      r * 0.22, Paint()..color = Colors.white.withValues(alpha: 0.90));
  canvas.drawCircle(Offset(center.dx + r * 0.10, center.dy - r * 0.16),
      r * 0.10, Paint()..color = Colors.white.withValues(alpha: 0.60));
}

(double, double) animalHeadShape(String skinId) {
  switch (skinId) {
    case 'gato':          return (2.0, 2.2);
    case 'cachorro':      return (2.3, 2.4);
    case 'leao':          return (2.7, 2.6);
    case 'vaca':          return (2.4, 2.5);
    case 'coelho':        return (2.0, 2.5);
    case 'peixe':         return (2.5, 1.9);
    case 'dragao_animal': return (2.7, 2.1);
    case 'raposa':        return (2.6, 2.1);
    default:              return (2.2, 1.9);
  }
}
