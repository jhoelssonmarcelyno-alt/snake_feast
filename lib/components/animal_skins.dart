// lib/components/animal_skins.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, Color, HSVColor;

// ─────────────────────────────────────────────────────────────
// CAUDAS
// ─────────────────────────────────────────────────────────────

void renderAnimalTail(
    Canvas canvas, String skinId, Offset tailPos, double angle, double r) {
  canvas.save();
  canvas.translate(tailPos.dx, tailPos.dy);
  canvas.rotate(angle);
  switch (skinId) {
    case 'gato':
      _tailCat(canvas, r);
      break;
    case 'cachorro':
      _tailDog(canvas, r);
      break;
    case 'leao':
      _tailLion(canvas, r);
      break;
    case 'vaca':
      _tailCow(canvas, r);
      break;
    case 'coelho':
      _tailRabbit(canvas, r);
      break;
    case 'peixe':
      _tailFish(canvas, r);
      break;
    case 'dragao_animal':
      _tailDragonAnimal(canvas, r);
      break;
    case 'raposa':
      _tailFox(canvas, r);
      break;
    default:
      _tailDefault(canvas, r);
  }
  canvas.restore();
}

void _tailCat(Canvas canvas, double r) {
  final p = Paint()
    ..color = const Color(0xFFFF9800)
    ..strokeWidth = r * 0.75
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 1.5, -r * 0.5, -r * 2.5, r * 0.8, -r * 1.2, r * 1.8)
        ..cubicTo(-r * 0.2, r * 2.6, r * 0.8, r * 2.2, r * 0.5, r * 1.4),
      p);
  canvas.drawCircle(Offset(r * 0.5, r * 1.4), r * 0.45,
      Paint()..color = const Color(0xFFFF9800));
  final stripe = Paint()
    ..color = const Color(0xFFE65100)
    ..strokeWidth = r * 0.18
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(-r * 0.4, r * 0.5), Offset(-r * 0.8, r * 0.6), stripe);
  canvas.drawLine(Offset(-r * 0.8, r * 1.0), Offset(-r * 1.2, r * 1.1), stripe);
}

void _tailDog(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFD4A35A)
    ..strokeWidth = r * 0.85
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 0.4, -r * 1.0, r * 0.6, -r * 2.0, r * 0.2, -r * 2.8),
      base);
  final fur = Paint()
    ..color = const Color(0xFFEFD5A0)
    ..strokeWidth = r * 0.28
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (int i = 0; i < 6; i++) {
    final a = -pi / 2 + (i - 2.5) * 0.28;
    canvas.drawLine(
        Offset(r * 0.2 + cos(a) * r * 0.2, -r * 2.8 + sin(a) * r * 0.2),
        Offset(r * 0.2 + cos(a) * r * 0.80, -r * 2.8 + sin(a) * r * 0.80),
        fur);
  }
}

void _tailLion(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFC8971F)
    ..strokeWidth = r * 0.65
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset.zero, Offset(-r * 2.2, r * 0.4), base);
  final pompom = Paint()..color = const Color(0xFF6D3E00);
  for (int i = 0; i < 10; i++) {
    final a = (i / 10) * pi * 2;
    canvas.drawCircle(
        Offset(-r * 2.2 + cos(a) * r * 0.60, r * 0.4 + sin(a) * r * 0.60),
        r * 0.40,
        pompom);
  }
  canvas.drawCircle(Offset(-r * 2.2, r * 0.4), r * 0.45, pompom);
}

void _tailCow(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFEEEEEE)
    ..strokeWidth = r * 0.50
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 1.0, r * 0.3, -r * 1.8, -r * 0.5, -r * 2.2, r * 0.8),
      base);
  final tuftP = Paint()
    ..color = const Color(0xFF212121)
    ..strokeWidth = r * 0.24
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (int i = 0; i < 5; i++) {
    final a = pi + (i - 2) * 0.38;
    canvas.drawLine(
        Offset(-r * 2.2, r * 0.8),
        Offset(-r * 2.2 + cos(a) * r * 0.60, r * 0.8 + sin(a) * r * 0.60),
        tuftP);
  }
}

void _tailRabbit(Canvas canvas, double r) {
  canvas.drawCircle(
      Offset(-r * 0.5, 0), r * 0.80, Paint()..color = Colors.white);
  canvas.drawCircle(
      Offset(-r * 0.5, 0),
      r * 0.80,
      Paint()
        ..color = const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.14);
}

void _tailFish(Canvas canvas, double r) {
  final p = Paint()..color = const Color(0xFF29B6F6);
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-r * 2.0, -r * 1.3)
        ..lineTo(-r * 1.1, 0)
        ..close(),
      p);
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-r * 2.0, r * 1.3)
        ..lineTo(-r * 1.1, 0)
        ..close(),
      p);
  final stripe = Paint()
    ..color = Colors.white.withValues(alpha: 0.45)
    ..strokeWidth = r * 0.13
    ..style = PaintingStyle.stroke;
  canvas.drawLine(
      Offset(-r * 0.5, -r * 0.5), Offset(-r * 1.6, -r * 1.1), stripe);
  canvas.drawLine(Offset(-r * 0.5, r * 0.5), Offset(-r * 1.6, r * 1.1), stripe);
}

void _tailDragonAnimal(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFFF1744)
    ..strokeWidth = r * 0.75
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 1.2, -r * 0.3, -r * 2.2, r * 0.5, -r * 2.8, r * 0.2),
      base);
  final spine = Paint()..color = const Color(0xFFFFD700);
  for (int i = 0; i < 4; i++) {
    final t = (i + 1) / 5.0;
    final cx = -r * 2.8 * t;
    final cy = r * 0.2 * t - r * 0.35 * t;
    canvas.drawPath(
        Path()
          ..moveTo(cx, cy)
          ..lineTo(cx - r * 0.12, cy - r * 0.7)
          ..lineTo(cx + r * 0.12, cy)
          ..close(),
        spine);
  }
  canvas.drawPath(
      Path()
        ..moveTo(-r * 2.8, r * 0.2)
        ..lineTo(-r * 3.5, -r * 0.2)
        ..lineTo(-r * 3.1, r * 0.6)
        ..close(),
      Paint()..color = const Color(0xFFFF1744));
}

void _tailFox(Canvas canvas, double r) {
  final base = Paint()
    ..color = const Color(0xFFFF6D00)
    ..strokeWidth = r * 1.10
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 1.0, -r * 0.8, -r * 2.2, -r * 0.2, -r * 2.5, r * 0.8),
      base);
  canvas.drawCircle(
      Offset(-r * 2.5, r * 0.8), r * 0.70, Paint()..color = Colors.white);
  final fur = Paint()
    ..color = const Color(0xFFFF8F00)
    ..strokeWidth = r * 0.20
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(Offset(0, 0), Offset(-r * 1.2, -r * 0.5), fur);
  canvas.drawLine(Offset(-r * 0.5, -r * 0.3), Offset(-r * 1.8, -r * 0.1), fur);
}

void _tailDefault(Canvas canvas, double r) {
  canvas.drawPath(
      Path()
        ..moveTo(0, -r * 0.5)
        ..lineTo(-r * 1.6, 0)
        ..lineTo(0, r * 0.5)
        ..close(),
      Paint()..color = const Color(0xFF00E5FF));
}

// ─────────────────────────────────────────────────────────────
// UTILITÁRIOS
// ─────────────────────────────────────────────────────────────

(double, double) animalHeadShape(String skinId) {
  switch (skinId) {
    case 'gato':
      return (2.0, 2.2);
    case 'cachorro':
      return (2.3, 2.4);
    case 'leao':
      return (2.7, 2.6);
    case 'vaca':
      return (2.4, 2.5);
    case 'coelho':
      return (2.0, 2.5);
    case 'peixe':
      return (2.5, 1.9);
    case 'dragao_animal':
      return (2.7, 2.1);
    case 'raposa':
      return (2.6, 2.1);
    default:
      return (2.2, 1.9);
  }
}

Color _lighten(Color c, double v) {
  final h = HSVColor.fromColor(c);
  return h.withValue((h.value + v).clamp(0.0, 1.0)).toColor();
}

Color _darken(Color c, double v) {
  final h = HSVColor.fromColor(c);
  return h.withValue((h.value - v).clamp(0.0, 1.0)).toColor();
}

Paint _shadowP(double o) => Paint()..color = Colors.black.withValues(alpha: o);

void _drawEye(Canvas canvas, Offset center, double r,
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

// ─────────────────────────────────────────────────────────────
// LAYER SYSTEM
// back  = orelhas/chifres/juba (desenhado ANTES do oval base)
// front = olhos/nariz/boca     (desenhado DEPOIS do oval base)
// ─────────────────────────────────────────────────────────────

void renderAnimalBack(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) {
  switch (skinId) {
    case 'gato':
      _catBack(canvas, hr, body);
      break;
    case 'cachorro':
      _dogBack(canvas, hr);
      break;
    case 'leao':
      _lionBack(canvas, hr);
      break;
    case 'vaca':
      _cowBack(canvas, hr);
      break;
    case 'coelho':
      _rabbitBack(canvas, hr, body);
      break;
    case 'peixe':
      _fishBack(canvas, hr, body, dark);
      break;
    case 'dragao_animal':
      _dragonBack(canvas, hr);
      break;
    case 'raposa':
      _foxBack(canvas, hr, body);
      break;
  }
}

void renderAnimalFront(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) {
  switch (skinId) {
    case 'gato':
      _catFront(canvas, hr, t, body, dark);
      break;
    case 'cachorro':
      _dogFront(canvas, hr, t, body, dark);
      break;
    case 'leao':
      _lionFront(canvas, hr, t, body, dark);
      break;
    case 'vaca':
      _cowFront(canvas, hr, t, body, dark);
      break;
    case 'coelho':
      _rabbitFront(canvas, hr, t, body, dark);
      break;
    case 'peixe':
      _fishFront(canvas, hr, t, body, dark);
      break;
    case 'dragao_animal':
      _dragonFront(canvas, hr, t, body, dark);
      break;
    case 'raposa':
      _foxFront(canvas, hr, t, body, dark);
      break;
  }
}

void renderAnimalBackLayer(
    Canvas canvas, String skinId, double hr, double t, Color body, Color dark) {
  renderAnimalBack(canvas, skinId, hr, t, body, dark);
}

// ─────────────────────────────────────────────────────────────
// GATO
// ─────────────────────────────────────────────────────────────
void _catBack(Canvas canvas, double hr, Color body) {
  // ✅ Orelhas bem para fora do oval (oval height = hr*2.2, então hr*1.1 é a borda)
  // Orelhas começam em hr*1.0 e vão até hr*2.4 — ficam claramente visíveis
  for (final s in [-1.0, 1.0]) {
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.20, s * hr * 1.0)
          ..lineTo(-hr * 0.85, s * hr * 2.40)
          ..lineTo(hr * 0.20, s * hr * 1.05)
          ..close(),
        _shadowP(0.30));
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.18, s * hr * 1.0)
          ..lineTo(-hr * 0.82, s * hr * 2.36)
          ..lineTo(hr * 0.18, s * hr * 1.04)
          ..close(),
        Paint()..color = body);
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.16, s * hr * 1.04)
          ..lineTo(-hr * 0.66, s * hr * 2.10)
          ..lineTo(hr * 0.12, s * hr * 1.08)
          ..close(),
        Paint()..color = const Color(0xFFFF80AB));
  }
}

void _catFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  for (final s in [-1.0, 1.0]) {
    _drawEye(canvas, Offset(hr * 0.16, s * hr * 0.40), hr * 0.28,
        irisColor: const Color(0xFF7DC242), slitPupil: true);
  }
  canvas.drawPath(
      Path()
        ..moveTo(hr * 0.52, -hr * 0.09)
        ..lineTo(hr * 0.66, hr * 0.10)
        ..lineTo(hr * 0.38, hr * 0.10)
        ..close(),
      Paint()..color = const Color(0xFFFF80AB));
  final wP = Paint()
    ..color = Colors.white.withValues(alpha: 0.92)
    ..strokeWidth = hr * 0.07
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawLine(
        Offset(hr * 0.46, s * hr * 0.10), Offset(hr * 1.42, s * hr * 0.02), wP);
    canvas.drawLine(
        Offset(hr * 0.46, s * hr * 0.10), Offset(hr * 1.38, s * hr * 0.30), wP);
    canvas.drawLine(Offset(hr * 0.46, s * hr * 0.10),
        Offset(hr * 1.36, s * hr * -0.20), wP);
    canvas.drawCircle(Offset(hr * 0.52, s * hr * 0.55), hr * 0.18,
        Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.40));
  }
  final mP = Paint()
    ..color = _darken(body, 0.22)
    ..strokeWidth = hr * 0.09
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(
      Offset(hr * 0.52, hr * 0.11), Offset(hr * 0.47, hr * 0.28), mP);
  canvas.drawLine(
      Offset(hr * 0.47, hr * 0.28), Offset(hr * 0.58, hr * 0.20), mP);
  canvas.drawLine(
      Offset(hr * 0.58, hr * 0.20), Offset(hr * 0.69, hr * 0.28), mP);
  canvas.drawLine(
      Offset(hr * 0.69, hr * 0.28), Offset(hr * 0.65, hr * 0.11), mP);
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

// ─────────────────────────────────────────────────────────────
// CACHORRO
// ─────────────────────────────────────────────────────────────
void _dogBack(Canvas canvas, double hr) {
  // Orelhas caídas bem para fora (oval height = hr*2.4, borda = hr*1.2)
  // Orelhas em hr*1.15 a hr*2.0 — ficam visíveis
  for (final s in [-1.0, 1.0]) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.30, s * hr * 1.60),
            width: hr * 0.90,
            height: hr * 1.20),
        _shadowP(0.22));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.28, s * hr * 1.58),
            width: hr * 0.88,
            height: hr * 1.18),
        Paint()..color = const Color(0xFFA0522D));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.28, s * hr * 1.58),
            width: hr * 0.55,
            height: hr * 0.82),
        Paint()..color = const Color(0xFFCD853F));
  }
}

void _dogFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.54, hr * 0.08),
          width: hr * 1.15,
          height: hr * 0.90),
      Paint()..color = const Color(0xFFD2A679));
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.80, -hr * 0.12),
          width: hr * 0.48,
          height: hr * 0.32),
      Paint()..color = const Color(0xFF1A1A1A));
  canvas.drawCircle(Offset(hr * 0.73, -hr * 0.16), hr * 0.10,
      Paint()..color = Colors.white.withValues(alpha: 0.65));
  for (final s in [-1.0, 1.0]) {
    _drawEye(canvas, Offset(hr * 0.12, s * hr * 0.44), hr * 0.30,
        irisColor: const Color(0xFF8B4513));
  }
  final browP = Paint()
    ..color = const Color(0xFF8B4513)
    ..strokeWidth = hr * 0.14
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawLine(Offset(hr * -0.05, s * hr * 0.22),
        Offset(hr * 0.34, s * hr * 0.18), browP);
  }
  final lick = sin(t * 3) * 0.28 + 0.72;
  canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center:
                  Offset(hr * (0.80 + lick * 0.18), hr * (0.38 + lick * 0.10)),
              width: hr * 0.40,
              height: hr * (0.58 + lick * 0.16)),
          const Radius.circular(10)),
      Paint()..color = const Color(0xFFFF6B8A));
}

// ─────────────────────────────────────────────────────────────
// LEÃO
// ─────────────────────────────────────────────────────────────
void _lionBack(Canvas canvas, double hr) {
  // Juba bem além do oval (oval = hr*2.6 x hr*2.6 aprox)
  final maneColors = [
    const Color(0xFF6D3E00),
    const Color(0xFF8B5E0A),
    const Color(0xFFA07212)
  ];
  for (int ring = 2; ring >= 0; ring--) {
    final count = 12 + ring * 5;
    for (int i = 0; i < count; i++) {
      final a = (i / count) * pi * 2;
      final dist = hr * (1.40 + ring * 0.30); // ✅ começa além do oval
      final len = hr * (0.60 + ring * 0.22);
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

void _lionFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.44, hr * 0.08),
          width: hr * 1.35,
          height: hr * 1.05),
      Paint()..color = const Color(0xFFE8C87A));
  canvas.drawPath(
      Path()
        ..moveTo(hr * 0.64, -hr * 0.16)
        ..lineTo(hr * 0.83, hr * 0.14)
        ..lineTo(hr * 0.45, hr * 0.14)
        ..close(),
      Paint()..color = const Color(0xFFD2691E));
  for (final s in [-1.0, 1.0]) {
    _drawEye(canvas, Offset(hr * 0.12, s * hr * 0.46), hr * 0.30,
        irisColor: const Color(0xFFFFB300));
  }
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.56, hr * 0.28),
          width: hr * 0.95,
          height: hr * 0.68),
      0,
      pi,
      true,
      Paint()..color = const Color(0xFF8B0000));
  final tooth = Paint()..color = Colors.white;
  for (final tx in [hr * 0.28, hr * 0.68]) {
    canvas.drawPath(
        Path()
          ..moveTo(tx, hr * 0.28)
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
    canvas.drawLine(
        Offset(hr * 0.48, s * hr * 0.10), Offset(hr * 1.45, s * hr * 0.04), wP);
    canvas.drawLine(
        Offset(hr * 0.48, s * hr * 0.10), Offset(hr * 1.42, s * hr * 0.28), wP);
  }
}

// ─────────────────────────────────────────────────────────────
// VACA
// ─────────────────────────────────────────────────────────────
void _cowBack(Canvas canvas, double hr) {
  // Orelhas horizontais além da borda (oval height = hr*2.5, borda = hr*1.25)
  for (final s in [-1.0, 1.0]) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.20, s * hr * 1.45),
            width: hr * 1.30,
            height: hr * 0.65),
        _shadowP(0.20));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.18, s * hr * 1.43),
            width: hr * 1.28,
            height: hr * 0.63),
        Paint()..color = const Color(0xFFEEEEEE));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-hr * 0.18, s * hr * 1.43),
            width: hr * 0.70,
            height: hr * 0.32),
        Paint()..color = const Color(0xFFFFCDD2));
  }
}

void _cowFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(hr * 0.50, hr * 0.12),
              width: hr * 1.15,
              height: hr * 0.95),
          const Radius.circular(10)),
      Paint()..color = const Color(0xFFDDDDDD));
  for (final s in [-1.0, 1.0]) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.72, s * hr * 0.22),
            width: hr * 0.30,
            height: hr * 0.22),
        Paint()..color = const Color(0xFF9E9E9E));
    _drawEye(canvas, Offset(hr * 0.10, s * hr * 0.48), hr * 0.29,
        irisColor: const Color(0xFF5D4037));
    final lashP = Paint()
      ..color = Colors.black
      ..strokeWidth = hr * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int c = 0; c < 4; c++) {
      final lx = hr * (-0.06 + c * 0.10);
      canvas.drawLine(Offset(lx, s * hr * 0.48 - hr * 0.27 * s),
          Offset(lx - hr * 0.06, s * hr * 0.48 - hr * 0.44 * s), lashP);
    }
  }
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-hr * 0.32, -hr * 0.52),
          width: hr * 0.75,
          height: hr * 0.55),
      Paint()..color = const Color(0xFF212121).withValues(alpha: 0.55));
}

// ─────────────────────────────────────────────────────────────
// COELHO
// ─────────────────────────────────────────────────────────────
void _rabbitBack(Canvas canvas, double hr, Color body) {
  // Orelhas longas e finas — oval height = hr*2.5, borda = hr*1.25
  // Orelhas vão de hr*1.10 a hr*2.80 — bem visíveis
  for (final s in [-1.0, 1.0]) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(hr * 0.05, s * hr * 2.10),
                width: hr * 0.58,
                height: hr * 2.00),
            const Radius.circular(14)),
        _shadowP(0.22));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(hr * 0.06, s * hr * 2.08),
                width: hr * 0.56,
                height: hr * 1.98),
            const Radius.circular(13)),
        Paint()..color = body);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(hr * 0.06, s * hr * 2.08),
                width: hr * 0.28,
                height: hr * 1.48),
            const Radius.circular(9)),
        Paint()..color = const Color(0xFFFFB6C1));
  }
}

void _rabbitFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawPath(
      Path()
        ..moveTo(hr * 0.60, -hr * 0.09)
        ..lineTo(hr * 0.71, hr * 0.07)
        ..lineTo(hr * 0.49, hr * 0.07)
        ..close(),
      Paint()..color = const Color(0xFFFF85A1));
  for (final s in [-1.0, 1.0]) {
    canvas.drawCircle(Offset(hr * 0.52, s * hr * 0.44), hr * 0.24,
        Paint()..color = const Color(0xFFFFB6C1).withValues(alpha: 0.50));
    _drawEye(canvas, Offset(hr * 0.14, s * hr * 0.42), hr * 0.30,
        irisColor: const Color(0xFFFF85A1));
  }
  final mP = Paint()
    ..color = _darken(body, 0.22)
    ..strokeWidth = hr * 0.09
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  canvas.drawLine(
      Offset(hr * 0.60, hr * 0.08), Offset(hr * 0.55, hr * 0.22), mP);
  canvas.drawLine(
      Offset(hr * 0.55, hr * 0.22), Offset(hr * 0.64, hr * 0.16), mP);
  canvas.drawLine(
      Offset(hr * 0.64, hr * 0.16), Offset(hr * 0.73, hr * 0.22), mP);
  canvas.drawLine(
      Offset(hr * 0.73, hr * 0.22), Offset(hr * 0.68, hr * 0.08), mP);
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
    canvas.drawLine(
        Offset(hr * 0.46, s * hr * 0.08), Offset(hr * 1.38, s * hr * 0.02), wP);
    canvas.drawLine(
        Offset(hr * 0.46, s * hr * 0.08), Offset(hr * 1.35, s * hr * 0.24), wP);
  }
}

// ─────────────────────────────────────────────────────────────
// PEIXE
// ─────────────────────────────────────────────────────────────
void _fishBack(Canvas canvas, double hr, Color body, Color dark) {
  for (final s in [-1.0, 1.0]) {
    for (int g = 0; g < 3; g++) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(-hr * 0.12 - g * hr * 0.08, s * hr * 0.80),
            width: hr * (1.5 - g * 0.22),
            height: hr * (0.90 - g * 0.10)),
        s > 0 ? -pi * 0.12 : pi * 0.12,
        s > 0 ? pi * 0.55 : -pi * 0.55,
        false,
        Paint()
          ..color = _darken(body, 0.18 + g * 0.08).withValues(alpha: 0.75)
          ..strokeWidth = hr * (0.14 - g * 0.03)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

void _fishFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  for (final s in [-1.0, 1.0]) {
    _drawEye(canvas, Offset(hr * 0.08, s * hr * 0.42), hr * 0.34,
        irisColor: const Color(0xFF0D47A1));
  }
  final mouthOpen = (sin(t * 2) * 0.35 + 0.65).clamp(0.2, 1.0);
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.76, 0),
          width: hr * 0.58,
          height: hr * (0.48 * mouthOpen)),
      -pi * 0.5,
      pi,
      false,
      Paint()
        ..color = _darken(body, 0.28)
        ..strokeWidth = hr * 0.14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
  final scaleP = Paint()
    ..color = Colors.white.withValues(alpha: 0.25)
    ..style = PaintingStyle.stroke
    ..strokeWidth = hr * 0.08;
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(0, -hr * 0.46), width: hr * 0.65, height: hr * 0.52),
      0,
      pi,
      false,
      scaleP);
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(0, hr * 0.46), width: hr * 0.65, height: hr * 0.52),
      pi,
      pi,
      false,
      scaleP);
}

// ─────────────────────────────────────────────────────────────
// DRAGÃO ANIMAL
// ─────────────────────────────────────────────────────────────
void _dragonBack(Canvas canvas, double hr) {
  // Chifres curvos — oval = hr*2.7 x hr*2.1, borda Y = hr*1.05
  final hornP = Paint()
    ..color = const Color(0xFFFFD700)
    ..strokeWidth = hr * 0.32
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawPath(
        Path()
          ..moveTo(hr * 0.0, s * hr * 1.05)
          ..cubicTo(hr * 0.22, s * hr * 1.65, -hr * 0.50, s * hr * 2.20,
              -hr * 0.28, s * hr * 2.75),
        hornP);
    canvas.drawCircle(Offset(-hr * 0.28, s * hr * 2.75), hr * 0.18,
        Paint()..color = const Color(0xFFFFE57F));
  }
  // Crista no topo (eixo X negativo = trás da cabeça)
  final crestP = Paint()..color = const Color(0xFFFF1744);
  for (int i = 0; i < 5; i++) {
    final x = -hr * 0.35 + i * hr * 0.175;
    final h = hr *
        (0.45 +
            (i == 2
                ? 0.40
                : i == 1 || i == 3
                    ? 0.22
                    : 0.0));
    canvas.drawPath(
        Path()
          ..moveTo(x, -hr * 1.05)
          ..lineTo(x - hr * 0.09, -hr * 1.05 - h)
          ..lineTo(x + hr * 0.09, -hr * 1.05)
          ..close(),
        crestP);
  }
}

void _dragonFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  for (final s in [-1.0, 1.0]) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.78, s * hr * 0.16),
            width: hr * 0.22,
            height: hr * 0.15),
        Paint()..color = Colors.black.withValues(alpha: 0.85));
    _drawEye(canvas, Offset(hr * 0.18, s * hr * 0.44), hr * 0.30,
        irisColor: const Color(0xFFFF6D00), slitPupil: true);
  }
  final browP = Paint()
    ..color = const Color(0xFFB71C1C)
    ..strokeWidth = hr * 0.18
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  for (final s in [-1.0, 1.0]) {
    canvas.drawLine(Offset(hr * 0.02, s * hr * 0.22),
        Offset(hr * 0.38, s * hr * 0.18), browP);
  }
  final flame = sin(t * 7) * 0.42 + 0.58;
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * (0.88 + flame * 0.32), 0),
          width: hr * (0.60 * flame),
          height: hr * (0.38 * flame)),
      Paint()..color = const Color(0xFFFF6D00).withValues(alpha: 0.88));
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * (0.92 + flame * 0.32), 0),
          width: hr * (0.32 * flame),
          height: hr * (0.20 * flame)),
      Paint()..color = const Color(0xFFFFFF00).withValues(alpha: 0.82));
}

// ─────────────────────────────────────────────────────────────
// RAPOSA
// ─────────────────────────────────────────────────────────────
void _foxBack(Canvas canvas, double hr, Color body) {
  // Orelhas triangulares — oval = hr*2.6 x hr*2.1, borda Y = hr*1.05
  for (final s in [-1.0, 1.0]) {
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.35, s * hr * 1.0)
          ..lineTo(-hr * 1.10, s * hr * 2.20)
          ..lineTo(hr * 0.18, s * hr * 1.05)
          ..close(),
        _shadowP(0.22));
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.33, s * hr * 0.98)
          ..lineTo(-hr * 1.06, s * hr * 2.16)
          ..lineTo(hr * 0.16, s * hr * 1.03)
          ..close(),
        Paint()..color = body);
    canvas.drawPath(
        Path()
          ..moveTo(-hr * 0.30, s * hr * 1.02)
          ..lineTo(-hr * 0.88, s * hr * 1.95)
          ..lineTo(hr * 0.10, s * hr * 1.06)
          ..close(),
        Paint()..color = const Color(0xFF1A1A1A));
  }
}

void _foxFront(Canvas canvas, double hr, double t, Color body, Color dark) {
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.54, hr * 0.06),
          width: hr * 1.25,
          height: hr * 0.84),
      Paint()..color = Colors.white);
  canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.82, -hr * 0.08),
          width: hr * 0.30,
          height: hr * 0.22),
      Paint()..color = const Color(0xFF1A1A1A));
  canvas.drawCircle(Offset(hr * 0.75, -hr * 0.11), hr * 0.09,
      Paint()..color = Colors.white.withValues(alpha: 0.65));
  for (final s in [-1.0, 1.0]) {
    _drawEye(canvas, Offset(hr * 0.12, s * hr * 0.44), hr * 0.28,
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
    canvas.drawLine(
        Offset(hr * 0.48, s * hr * 0.09), Offset(hr * 1.42, s * hr * 0.03), wP);
    canvas.drawLine(
        Offset(hr * 0.48, s * hr * 0.09), Offset(hr * 1.40, s * hr * 0.27), wP);
    canvas.drawLine(Offset(hr * 0.48, s * hr * 0.09),
        Offset(hr * 1.38, s * hr * -0.16), wP);
  }
  canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.62, hr * 0.30),
          width: hr * 0.78,
          height: hr * 0.52),
      0,
      pi,
      false,
      Paint()
        ..color = _darken(body, 0.22)
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

// ─────────────────────────────────────────────────────────────
// Funções legadas mantidas para compatibilidade com bot_renderer
// ─────────────────────────────────────────────────────────────
void drawCatHead(Canvas canvas, double hr, double t, Color body, Color dark) {
  _catBack(canvas, hr, body);
  _catFront(canvas, hr, t, body, dark);
}

void drawDogHead(Canvas canvas, double hr, double t, Color body, Color dark) {
  _dogBack(canvas, hr);
  _dogFront(canvas, hr, t, body, dark);
}

void drawLionHead(Canvas canvas, double hr, double t, Color body, Color dark) {
  _lionBack(canvas, hr);
  _lionFront(canvas, hr, t, body, dark);
}

void drawCowHead(Canvas canvas, double hr, double t, Color body, Color dark) {
  _cowBack(canvas, hr);
  _cowFront(canvas, hr, t, body, dark);
}

void drawRabbitHead(
    Canvas canvas, double hr, double t, Color body, Color dark) {
  _rabbitBack(canvas, hr, body);
  _rabbitFront(canvas, hr, t, body, dark);
}

void drawFishHead(Canvas canvas, double hr, double t, Color body, Color dark) {
  _fishBack(canvas, hr, body, dark);
  _fishFront(canvas, hr, t, body, dark);
}

void drawDragonAnimalHead(
    Canvas canvas, double hr, double t, Color body, Color dark) {
  _dragonBack(canvas, hr);
  _dragonFront(canvas, hr, t, body, dark);
}

void drawFoxHead(Canvas canvas, double hr, double t, Color body, Color dark) {
  _foxBack(canvas, hr, body);
  _foxFront(canvas, hr, t, body, dark);
}
