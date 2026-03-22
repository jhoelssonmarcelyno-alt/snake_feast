// lib/components/snake_player_expressions.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, Color;
import 'animal_skins.dart';

mixin PlayerExpressions {
  Color get skinBodyColor;
  Color get skinBodyColorDark;
  Color get skinAccentColor;
  String get skinId;
  Paint get eyeWhite;
  Paint get eyePupil;

  (double, double) headShape() {
    final animalShape = animalHeadShape(skinId);
    if (animalShape != (2.2, 1.9)) return animalShape;
    switch (skinId) {
      case 'classic':
        return (2.2, 1.9);
      case 'hot':
        return (2.4, 1.7);
      case 'sorriso':
        return (2.0, 2.2);
      case 'veneno':
        return (2.6, 1.6);
      case 'fantasma':
        return (1.9, 2.1);
      case 'piranha':
        return (2.8, 1.5);
      case 'lava':
        return (2.3, 1.8);
      case 'alien':
        return (2.0, 2.3);
      case 'lili':
        return (2.1, 2.0);
      case 'robo':
        return (2.4, 2.0);
      case 'serpente':
        return (2.7, 1.6);
      case 'dragao':
        return (2.5, 1.8);
      case 'galaxia':
        return (2.1, 2.1);
      case 'neon':
        return (2.3, 1.7);
      case 'ouro':
        return (2.2, 2.0);
      default:
        return (2.2, 1.9);
    }
  }

  // ✅ Renderiza partes traseiras (orelhas, chifres, juba) ANTES do oval base
  void renderAnimalBack(Canvas canvas, double hr, double t) {
    renderAnimalBackLayer(
        canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
  }

  void renderExpression(Canvas canvas, double hr, double t) {
    switch (skinId) {
      case 'gato':
        renderAnimalFront(
            canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
        return;
      case 'cachorro':
        renderAnimalFront(
            canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
        return;
      case 'leao':
        renderAnimalFront(
            canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
        return;
      case 'vaca':
        renderAnimalFront(
            canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
        return;
      case 'coelho':
        renderAnimalFront(
            canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
        return;
      case 'peixe':
        renderAnimalFront(
            canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
        return;
      case 'dragao_animal':
        renderAnimalFront(
            canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
        return;
      case 'raposa':
        renderAnimalFront(
            canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
        return;
    }
    switch (skinId) {
      case 'classic':
        _exprClassic(canvas, hr, t);
        break;
      case 'hot':
        _exprHot(canvas, hr, t);
        break;
      case 'sorriso':
        _exprSorriso(canvas, hr, t);
        break;
      case 'veneno':
        _exprVeneno(canvas, hr, t);
        break;
      case 'fantasma':
        _exprFantasma(canvas, hr, t);
        break;
      case 'piranha':
        _exprPiranha(canvas, hr, t);
        break;
      case 'lava':
        _exprLava(canvas, hr, t);
        break;
      case 'alien':
        _exprAlien(canvas, hr, t);
        break;
      case 'lili':
        _exprLili(canvas, hr, t);
        break;
      case 'robo':
        _exprRobo(canvas, hr, t);
        break;
      case 'serpente':
        _exprSerpente(canvas, hr, t);
        break;
      case 'dragao':
        _exprDragao(canvas, hr, t);
        break;
      case 'galaxia':
        _exprGalaxia(canvas, hr, t);
        break;
      case 'neon':
        _exprNeon(canvas, hr, t);
        break;
      case 'ouro':
        _exprOuro(canvas, hr, t);
        break;
      case 'verde':
        _exprVerde(canvas, hr, t);
        break;
      case 'roxo':
        _exprRoxo(canvas, hr, t);
        break;
      case 'laranja':
        _exprLaranja(canvas, hr, t);
        break;
      case 'rosa':
        _exprRosa(canvas, hr, t);
        break;
      case 'azul':
        _exprAzul(canvas, hr, t);
        break;
      case 'gelo':
        _exprGelo(canvas, hr, t);
        break;
      case 'coral':
        _exprCoral(canvas, hr, t);
        break;
      case 'cinza':
        _exprCinza(canvas, hr, t);
        break;
      case 'marrom':
        _exprMarrom(canvas, hr, t);
        break;
      case 'indigo':
        _exprIndigo(canvas, hr, t);
        break;
      case 'esmeralda':
        _exprEsmeralda(canvas, hr, t);
        break;
      case 'cristal':
        _exprCristal(canvas, hr, t);
        break;
      case 'vulcao':
        _exprVulcao(canvas, hr, t);
        break;
      case 'oceano':
        _exprOceano(canvas, hr, t);
        break;
      case 'aurora':
        _exprAurora(canvas, hr, t);
        break;
      default:
        _eyesNormal(canvas, hr);
        break;
    }
  }

  void _eyesNormal(Canvas canvas, double hr) {
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

  void _eyesAngry(Canvas canvas, double hr) {
    final brow = Paint()
      ..color = skinBodyColorDark
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

  void _eyesHappy(Canvas canvas, double hr) {
    final ep = Paint()
      ..color = skinBodyColorDark
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

  void _eyesRound(Canvas canvas, double hr, Color irisColor) {
    for (final ey in [-hr * 0.40, hr * 0.40]) {
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.30, eyeWhite);
      canvas.drawCircle(
          Offset(hr * 0.26, ey), hr * 0.18, Paint()..color = irisColor);
      canvas.drawCircle(Offset(hr * 0.26, ey), hr * 0.09, eyePupil);
      canvas.drawCircle(Offset(hr * 0.18, ey - hr * 0.12), hr * 0.08,
          Paint()..color = Colors.white.withValues(alpha: 0.90));
    }
  }

  void _tongue(Canvas canvas, double hr, double t,
      {Color color = const Color(0xFFFF1744), double speed = 4}) {
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

  void _smile(Canvas canvas, double hr) {
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.3, hr * 0.10),
          width: hr * 1.1,
          height: hr * 0.8),
      0.0,
      pi,
      false,
      Paint()
        ..color = skinBodyColorDark
        ..strokeWidth = hr * 0.14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _frown(Canvas canvas, double hr) {
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.3, hr * 0.55),
          width: hr * 0.9,
          height: hr * 0.6),
      pi,
      pi,
      false,
      Paint()
        ..color = skinBodyColorDark
        ..strokeWidth = hr * 0.14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _exprClassic(Canvas canvas, double hr, double t) {
    _eyesNormal(canvas, hr);
    _tongue(canvas, hr, t);
  }

  void _exprHot(Canvas canvas, double hr, double t) {
    _eyesAngry(canvas, hr);
    _eyesRound(canvas, hr, const Color(0xFFFF1744));
    final flame = Paint()
      ..color = const Color(0xFFFF6D00).withValues(alpha: 0.8)
      ..strokeWidth = hr * 0.18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final fx in [-0.3, 0.0, 0.3]) {
      final flicker = sin(t * 8 + fx * 10) * 0.3 + 0.7;
      canvas.drawLine(
          Offset(hr * fx, -hr * 0.92),
          Offset(hr * fx + hr * 0.1 * sin(t * 6), -hr * (1.3 + 0.3 * flicker)),
          flame);
    }
    _tongue(canvas, hr, t, color: const Color(0xFFFF6D00));
  }

  void _exprSorriso(Canvas canvas, double hr, double t) {
    _eyesHappy(canvas, hr);
    _smile(canvas, hr);
    for (final s in [-1.0, 1.0]) {
      canvas.drawCircle(Offset(hr * 0.55, s * hr * 0.62), hr * 0.20,
          Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55));
    }
    _tongue(canvas, hr, t, color: const Color(0xFFE91E63), speed: 2);
  }

  void _exprVeneno(Canvas canvas, double hr, double t) {
    final xp = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = hr * 0.20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final ey in [-hr * 0.42, hr * 0.42]) {
      canvas.drawCircle(
          Offset(hr * 0.22, ey), hr * 0.26, Paint()..color = Colors.black);
      canvas.drawLine(Offset(hr * 0.09, ey - hr * 0.16),
          Offset(hr * 0.35, ey + hr * 0.16), xp);
      canvas.drawLine(Offset(hr * 0.35, ey - hr * 0.16),
          Offset(hr * 0.09, ey + hr * 0.16), xp);
    }
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(hr * 0.28, hr * 0.55),
            width: hr * 1.0,
            height: hr * 0.55),
        pi * 0.1,
        pi * 0.8,
        true,
        Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.8));
    final drop = sin(t * 3) * 0.5 + 0.5;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.28, hr * (0.82 + drop * 0.3)),
            width: hr * 0.18,
            height: hr * (0.22 + drop * 0.1)),
        Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.7));
  }

  void _exprFantasma(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.40, hr * 0.40]) {
      canvas.drawCircle(
          Offset(hr * 0.22, ey), hr * 0.30, Paint()..color = Colors.black);
      if ((t % (pi * 2)) <= pi * 1.75) {
        canvas.drawCircle(Offset(hr * 0.16, ey - hr * 0.10), hr * 0.12,
            Paint()..color = const Color(0x99C8E6FF));
        canvas.drawCircle(Offset(hr * 0.28, ey + hr * 0.08), hr * 0.07,
            Paint()..color = const Color(0x66C8E6FF));
      }
    }
    final float = sin(t * 2) * hr * 0.04;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.30, hr * 0.42 + float),
            width: hr * 0.55,
            height: hr * 0.42),
        Paint()..color = Colors.black);
  }

  void _exprPiranha(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.44, hr * 0.44]) {
      canvas.drawCircle(Offset(hr * 0.20, ey), hr * 0.27, eyeWhite);
      canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.16,
          Paint()..color = const Color(0xFF1B5E20));
      canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.09, eyePupil);
    }
    _eyesAngry(canvas, hr);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(hr * 0.12, -hr * 0.05),
            width: hr * 1.7,
            height: hr * 1.6),
        -0.25,
        pi + 0.5,
        true,
        Paint()..color = skinBodyColorDark);
    final tw = Paint()..color = Colors.white;
    final tb = Paint()..color = const Color(0xFFCCFF80);
    for (int i = 0; i < 4; i++) {
      final tx = hr * (-0.42 + i * 0.28);
      canvas.drawPath(
          Path()
            ..moveTo(tx, -hr * 0.04)
            ..lineTo(tx + hr * 0.14, -hr * 0.35)
            ..lineTo(tx + hr * 0.28, -hr * 0.04)
            ..close(),
          tw);
    }
    for (int i = 0; i < 3; i++) {
      final tx = hr * (-0.28 + i * 0.28);
      canvas.drawPath(
          Path()
            ..moveTo(tx, hr * 0.04)
            ..lineTo(tx + hr * 0.14, hr * 0.28)
            ..lineTo(tx + hr * 0.28, hr * 0.04)
            ..close(),
          tb);
    }
  }

  void _exprLava(Canvas canvas, double hr, double t) {
    final crack = Paint()
      ..color = const Color(0xFFFF6D00).withValues(alpha: 0.7)
      ..strokeWidth = hr * 0.09
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(-hr * 0.05, -hr * 0.70), Offset(hr * 0.05, hr * 0.70), crack);
    canvas.drawLine(
        Offset(-hr * 0.22, -hr * 0.28), Offset(hr * 0.22, -hr * 0.28), crack);
    canvas.drawCircle(Offset(hr * 0.28, 0), hr * 0.36, eyeWhite);
    canvas.drawCircle(Offset(hr * 0.30, 0), hr * 0.24,
        Paint()..color = const Color(0xFFFF3D00));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.30, 0), width: hr * 0.12, height: hr * 0.26),
        eyePupil);
    canvas.drawLine(
        Offset(hr * 0.06, -hr * 0.32),
        Offset(hr * 0.52, -hr * 0.32),
        Paint()
          ..color = skinBodyColorDark
          ..strokeWidth = hr * 0.20
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    _frown(canvas, hr);
  }

  void _exprAlien(Canvas canvas, double hr, double t) {
    final lens = Paint()..color = const Color(0xE0000000);
    final ring = Paint()
      ..color = skinAccentColor.withValues(alpha: 0.9)
      ..strokeWidth = hr * 0.14
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(hr * 0.20, -hr * 0.38), hr * 0.34, lens);
    canvas.drawCircle(Offset(hr * 0.20, -hr * 0.38), hr * 0.34, ring);
    canvas.drawCircle(Offset(hr * 0.22, hr * 0.40), hr * 0.20, lens);
    canvas.drawCircle(Offset(hr * 0.22, hr * 0.40), hr * 0.20, ring);
    final wobble = sin(t * 3) * hr * 0.12;
    final ant = Paint()
      ..color = skinAccentColor
      ..strokeWidth = hr * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -hr * 0.95), Offset(wobble, -hr * 1.55), ant);
    canvas.drawCircle(Offset(wobble, -hr * 1.60), hr * 0.14,
        Paint()..color = skinAccentColor);
  }

  void _exprLili(Canvas canvas, double hr, double t) {
    final bool blink = (t % (pi * 2)) > pi * 1.80;
    for (final ey in [-hr * 0.42, hr * 0.42]) {
      if (blink) {
        canvas.drawLine(
            Offset(hr * 0.08, ey),
            Offset(hr * 0.38, ey),
            Paint()
              ..color = skinBodyColorDark
              ..strokeWidth = hr * 0.22
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke);
      } else {
        canvas.drawCircle(Offset(hr * 0.20, ey), hr * 0.28, eyeWhite);
        canvas.drawCircle(
            Offset(hr * 0.24, ey), hr * 0.16, Paint()..color = Colors.black);
        canvas.drawCircle(Offset(hr * 0.14, ey - hr * 0.10), hr * 0.08,
            Paint()..color = Colors.white);
      }
    }
    for (final s in [-1.0, 1.0]) {
      canvas.drawCircle(Offset(hr * 0.55, s * hr * 0.60), hr * 0.20,
          Paint()..color = const Color(0x55FF5080));
    }
    _smile(canvas, hr);
  }

  void _exprRobo(Canvas canvas, double hr, double t) {
    final dark = Paint()..color = const Color(0xFF1A1A1A);
    final led0 = Paint()..color = const Color(0xFF00E5FF);
    final led1 = Paint()..color = const Color(0xFFF44336);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(-hr * 0.05, -hr * 0.65, hr * 0.76, hr * 1.20),
            const Radius.circular(4)),
        dark);
    final bool blink = (t % (pi * 2)) > pi * 1.85;
    for (int i = 0; i < 2; i++) {
      final ey = i == 0 ? -hr * 0.38 : hr * 0.38;
      if (blink) {
        canvas.drawRect(
            Rect.fromLTWH(hr * 0.08, ey - hr * 0.04, hr * 0.34, hr * 0.08),
            i == 0 ? led0 : led1);
      } else {
        canvas.drawRect(
            Rect.fromLTWH(hr * 0.06, ey - hr * 0.20, hr * 0.38, hr * 0.38),
            i == 0 ? led0 : led1);
      }
    }
    canvas.drawLine(
        Offset(0, -hr * 0.95),
        Offset(0, -hr * 1.55),
        Paint()
          ..color = const Color(0xFF78909C)
          ..strokeWidth = hr * 0.10
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(0, -hr * 1.60), hr * 0.13, led1);
  }

  void _exprSerpente(Canvas canvas, double hr, double t) {
    final brow = Paint()
      ..color = const Color(0xFF1A3300)
      ..strokeWidth = hr * 0.20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final s in [-1.0, 1.0]) {
      canvas.drawPath(
          Path()
            ..moveTo(hr * -0.35, s * hr * 0.52)
            ..quadraticBezierTo(
                hr * 0.05, s * hr * 0.70, hr * 0.42, s * hr * 0.48),
          brow);
    }
    for (final ey in [-hr * 0.38, hr * 0.38]) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.12, ey),
              width: hr * 0.54,
              height: hr * 0.36),
          Paint()..color = const Color(0xFFFFEEEE));
      canvas.drawCircle(Offset(hr * 0.18, ey), hr * 0.22,
          Paint()..color = const Color(0xFFCC0000));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.20, ey),
              width: hr * 0.08,
              height: hr * 0.20),
          eyePupil);
    }
    _tongue(canvas, hr, t, color: const Color(0xFFFF1744), speed: 5);
  }

  void _exprDragao(Canvas canvas, double hr, double t) {
    for (final s in [-1.0, 1.0]) {
      canvas.drawPath(
          Path()
            ..moveTo(s * hr * 0.10, -hr * 0.88)
            ..lineTo(s * hr * 0.32, -hr * 1.45)
            ..lineTo(s * hr * 0.22, -hr * 0.85)
            ..close(),
          Paint()..color = const Color(0xFF7F0000));
    }
    for (final ey in [-hr * 0.42, hr * 0.42]) {
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.28,
          Paint()..color = const Color(0xFFFF6D00));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.24, ey),
              width: hr * 0.12,
              height: hr * 0.26),
          eyePupil);
    }
    _eyesAngry(canvas, hr);
    final flicker = sin(t * 7) * 0.3 + 0.7;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * (0.85 + flicker * 0.3), 0),
            width: hr * (0.7 * flicker),
            height: hr * (0.4 * flicker)),
        Paint()..color = const Color(0xFFFF6D00).withValues(alpha: 0.85));
  }

  void _exprGalaxia(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.40, hr * 0.40]) {
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.30,
          Paint()..color = const Color(0xFF1A0050));
      canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.20,
          Paint()..color = skinAccentColor.withValues(alpha: 0.8));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.24, ey),
              width: hr * 0.10,
              height: hr * 0.22),
          eyePupil);
      canvas.drawCircle(Offset(hr * 0.14, ey - hr * 0.12), hr * 0.07,
          Paint()..color = Colors.white.withValues(alpha: 0.90));
    }
    final aura = sin(t * 3) * 0.5 + 0.5;
    canvas.drawCircle(
        Offset(hr * 0.20, 0),
        hr * (0.85 + aura * 0.15),
        Paint()
          ..color = skinAccentColor.withValues(alpha: 0.12 + aura * 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = hr * 0.08);
  }

  void _exprNeon(Canvas canvas, double hr, double t) {
    final glow = sin(t * 5) * 0.5 + 0.5;
    for (final ey in [-hr * 0.42, hr * 0.42]) {
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * (0.32 + glow * 0.06),
          Paint()..color = skinAccentColor.withValues(alpha: 0.25 + glow * 0.15));
      canvas.drawCircle(
          Offset(hr * 0.22, ey), hr * 0.26, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.18,
          Paint()..color = skinAccentColor.withValues(alpha: 0.8 + glow * 0.2));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.22, ey),
              width: hr * 0.10,
              height: hr * 0.22),
          eyePupil);
    }
  }

  void _exprOuro(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFFFFD700));
    _smile(canvas, hr);
    final shine = sin(t * 4) * 0.5 + 0.5;
    canvas.drawCircle(
        Offset(hr * 0.45, -hr * 0.60),
        hr * (0.08 + shine * 0.05),
        Paint()
          ..color = const Color(0xFFFFFF00).withValues(alpha: 0.7 + shine * 0.3));
  }

  void _exprVerde(Canvas canvas, double hr, double t) {
    _eyesNormal(canvas, hr);
    _tongue(canvas, hr, t, color: const Color(0xFF1B5E20));
  }

  void _exprRoxo(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFF7B1FA2));
    canvas.drawLine(
        Offset(hr * 0.08, hr * 0.45),
        Offset(hr * 0.48, hr * 0.45),
        Paint()
          ..color = skinBodyColorDark
          ..strokeWidth = hr * 0.13
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  void _exprLaranja(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFFE65100));
    _smile(canvas, hr);
    _tongue(canvas, hr, t, color: const Color(0xFFBF360C), speed: 3);
  }

  void _exprRosa(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.42, hr * 0.42]) {
      if ((t % (pi * 2)) > pi * 1.85) {
        canvas.drawLine(
            Offset(hr * 0.08, ey),
            Offset(hr * 0.38, ey),
            Paint()
              ..color = const Color(0xFFE91E63)
              ..strokeWidth = hr * 0.22
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke);
      } else {
        _eyesRound(canvas, hr, const Color(0xFFE91E63));
      }
    }
    _smile(canvas, hr);
  }

  void _exprAzul(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFF0D47A1));
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.28, hr * 0.40),
          width: hr * 0.60,
          height: hr * 0.35),
      0,
      pi,
      false,
      Paint()
        ..color = skinBodyColorDark.withValues(alpha: 0.7)
        ..strokeWidth = hr * 0.11
        ..style = PaintingStyle.stroke,
    );
  }

  void _exprGelo(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFF1565C0));
    final breath = sin(t * 2) * 0.5 + 0.5;
    for (int b = 0; b < 3; b++) {
      canvas.drawCircle(
        Offset(hr * (1.05 + b * 0.22), hr * 0.10 * sin(t + b)),
        hr * (0.08 + breath * 0.04),
        Paint()..color = const Color(0xFF82B1FF).withValues(alpha: 0.4 - b * 0.12),
      );
    }
  }

  void _exprCoral(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFFBF360C));
    _smile(canvas, hr);
    _tongue(canvas, hr, t, color: const Color(0xFF7F0000), speed: 3);
  }

  void _exprCinza(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.42, hr * 0.42]) {
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.28, eyeWhite);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.24, ey),
              width: hr * 0.14,
              height: hr * 0.28),
          eyePupil);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.22, ey - hr * 0.14),
              width: hr * 0.56,
              height: hr * 0.28),
          Paint()..color = skinBodyColor);
    }
    _frown(canvas, hr);
  }

  void _exprMarrom(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFF4E342E));
    canvas.drawLine(
        Offset(hr * 0.10, hr * 0.42),
        Offset(hr * 0.46, hr * 0.42),
        Paint()
          ..color = skinBodyColorDark
          ..strokeWidth = hr * 0.12
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  void _exprIndigo(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFF283593));
    final lightning = Paint()
      ..color = skinAccentColor.withValues(alpha: 0.7)
      ..strokeWidth = hr * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final s in [-1.0, 1.0]) {
      if (sin(t * 6 + s * 2) > 0.3) {
        canvas.drawLine(Offset(hr * 0.22, s * hr * 0.55),
            Offset(hr * 0.42, s * hr * 0.85), lightning);
      }
    }
  }

  void _exprEsmeralda(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFF00695C));
    _smile(canvas, hr);
    final shine = sin(t * 4) * 0.5 + 0.5;
    canvas.drawCircle(Offset(hr * 0.60, -hr * 0.65), hr * (0.07 + shine * 0.05),
        Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.8));
  }

  void _exprCristal(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.40, hr * 0.40]) {
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.30,
          Paint()..color = Colors.white.withValues(alpha: 0.15));
      canvas.drawCircle(
          Offset(hr * 0.22, ey),
          hr * 0.30,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = hr * 0.09);
      canvas.drawCircle(Offset(hr * 0.26, ey), hr * 0.18,
          Paint()..color = Colors.white.withValues(alpha: 0.3));
      canvas.drawCircle(Offset(hr * 0.14, ey - hr * 0.14), hr * 0.09,
          Paint()..color = Colors.white.withValues(alpha: 0.90));
    }
  }

  void _exprVulcao(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFFFF3D00));
    _eyesAngry(canvas, hr);
    final erupt = sin(t * 6) * 0.5 + 0.5;
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * (0.22 + s * 0.32), -hr * (0.75 + erupt * 0.2)),
            width: hr * 0.15,
            height: hr * (0.25 + erupt * 0.15)),
        Paint()..color = const Color(0xFFFF6D00).withValues(alpha: 0.8),
      );
    }
    _frown(canvas, hr);
  }

  void _exprOceano(Canvas canvas, double hr, double t) {
    _eyesRound(canvas, hr, const Color(0xFF01579B));
    final wave = Paint()
      ..color = const Color(0xFF80D8FF).withValues(alpha: 0.6)
      ..strokeWidth = hr * 0.10
      ..style = PaintingStyle.stroke;
    for (int w = 0; w < 2; w++) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(hr * 1.10, hr * (0.10 + w * 0.18)),
            width: hr * 0.35,
            height: hr * 0.22),
        0,
        pi,
        false,
        wave,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.28, hr * 0.42),
          width: hr * 0.70,
          height: hr * 0.45),
      0,
      pi,
      false,
      Paint()
        ..color = skinBodyColorDark
        ..strokeWidth = hr * 0.12
        ..style = PaintingStyle.stroke,
    );
  }

  void _exprAurora(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.40, hr * 0.40]) {
      final glow = sin(t * 3 + ey) * 0.5 + 0.5;
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * (0.35 + glow * 0.06),
          Paint()..color = skinAccentColor.withValues(alpha: 0.20));
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.28, eyeWhite);
      canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.18,
          Paint()..color = const Color(0xFF18FFFF).withValues(alpha: 0.9));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.24, ey),
              width: hr * 0.10,
              height: hr * 0.22),
          eyePupil);
    }
    final magic = sin(t * 4) * 0.5 + 0.5;
    canvas.drawCircle(Offset(hr * 0.80, -hr * 0.70), hr * (0.07 + magic * 0.06),
        Paint()..color = skinAccentColor.withValues(alpha: 0.7 + magic * 0.3));
  }
}
