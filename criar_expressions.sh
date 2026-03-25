#!/bin/bash
# Script de refatoração do PlayerExpressions - Serpent Strike
# Rodar no Git Bash na raiz do projeto:
# bash criar_expressions.sh

PROJECT="/f/Documentos/PROJETOS/serpent_strike"
DIR="$PROJECT/lib/components/expressions"

echo "📁 Criando pasta $DIR..."
mkdir -p "$DIR"

# ─────────────────────────────────────────────────────────────
# 1. expressions_eyes.dart
# ─────────────────────────────────────────────────────────────
cat > "$DIR/expressions_eyes.dart" << 'DART'
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
DART

echo "✅ expressions_eyes.dart criado"

# ─────────────────────────────────────────────────────────────
# 2. expressions_mouth.dart
# ─────────────────────────────────────────────────────────────
cat > "$DIR/expressions_mouth.dart" << 'DART'
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
DART

echo "✅ expressions_mouth.dart criado"

# ─────────────────────────────────────────────────────────────
# 3. expressions_skins.dart
# ─────────────────────────────────────────────────────────────
cat > "$DIR/expressions_skins.dart" << 'DART'
// lib/components/expressions/expressions_skins.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, Color;
import 'expressions_eyes.dart';
import 'expressions_mouth.dart';

void renderSkinExpression(
  Canvas canvas,
  String skinId,
  double hr,
  double t,
  Paint eyeWhite,
  Paint eyePupil,
  Color bodyColor,
  Color bodyColorDark,
  Color accentColor,
) {
  switch (skinId) {
    case 'classic':
      drawEyesNormal(canvas, hr, eyeWhite, eyePupil, bodyColorDark);
      drawTongue(canvas, hr, t);
    case 'hot':
      drawEyesAngry(canvas, hr, eyeWhite, eyePupil, bodyColorDark);
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFFFF1744));
      final flame = Paint()
        ..color = const Color(0xFFFF6D00).withValues(alpha: 0.8)
        ..strokeWidth = hr * 0.18
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (final fx in [-0.3, 0.0, 0.3]) {
        final flicker = sin(t * 8 + fx * 10) * 0.3 + 0.7;
        canvas.drawLine(
            Offset(hr * fx, -hr * 0.92),
            Offset(
                hr * fx + hr * 0.1 * sin(t * 6), -hr * (1.3 + 0.3 * flicker)),
            flame);
      }
      drawTongue(canvas, hr, t, color: const Color(0xFFFF6D00));
    case 'sorriso':
      drawEyesHappy(canvas, hr, bodyColorDark);
      drawSmile(canvas, hr, bodyColorDark);
      for (final s in [-1.0, 1.0]) {
        canvas.drawCircle(Offset(hr * 0.55, s * hr * 0.62), hr * 0.20,
            Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55));
      }
      drawTongue(canvas, hr, t, color: const Color(0xFFE91E63), speed: 2);
    case 'veneno':
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
    case 'fantasma':
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
    case 'piranha':
      for (final ey in [-hr * 0.44, hr * 0.44]) {
        canvas.drawCircle(Offset(hr * 0.20, ey), hr * 0.27, eyeWhite);
        canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.16,
            Paint()..color = const Color(0xFF1B5E20));
        canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.09, eyePupil);
      }
      drawEyesAngry(canvas, hr, eyeWhite, eyePupil, bodyColorDark);
      canvas.drawArc(
          Rect.fromCenter(
              center: Offset(hr * 0.12, -hr * 0.05),
              width: hr * 1.7,
              height: hr * 1.6),
          -0.25,
          pi + 0.5,
          true,
          Paint()..color = bodyColorDark);
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
    case 'lava':
      final crack = Paint()
        ..color = const Color(0xFFFF6D00).withValues(alpha: 0.7)
        ..strokeWidth = hr * 0.09
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(-hr * 0.05, -hr * 0.70),
          Offset(hr * 0.05, hr * 0.70), crack);
      canvas.drawLine(Offset(-hr * 0.22, -hr * 0.28),
          Offset(hr * 0.22, -hr * 0.28), crack);
      canvas.drawCircle(Offset(hr * 0.28, 0), hr * 0.36, eyeWhite);
      canvas.drawCircle(Offset(hr * 0.30, 0), hr * 0.24,
          Paint()..color = const Color(0xFFFF3D00));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * 0.30, 0),
              width: hr * 0.12,
              height: hr * 0.26),
          eyePupil);
      canvas.drawLine(
          Offset(hr * 0.06, -hr * 0.32),
          Offset(hr * 0.52, -hr * 0.32),
          Paint()
            ..color = bodyColorDark
            ..strokeWidth = hr * 0.20
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
      drawFrown(canvas, hr, bodyColorDark);
    case 'alien':
      final lens = Paint()..color = const Color(0xE0000000);
      final ring = Paint()
        ..color = accentColor.withValues(alpha: 0.9)
        ..strokeWidth = hr * 0.14
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(hr * 0.20, -hr * 0.38), hr * 0.34, lens);
      canvas.drawCircle(Offset(hr * 0.20, -hr * 0.38), hr * 0.34, ring);
      canvas.drawCircle(Offset(hr * 0.22, hr * 0.40), hr * 0.20, lens);
      canvas.drawCircle(Offset(hr * 0.22, hr * 0.40), hr * 0.20, ring);
      final wobble = sin(t * 3) * hr * 0.12;
      final ant = Paint()
        ..color = accentColor
        ..strokeWidth = hr * 0.10
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, -hr * 0.95), Offset(wobble, -hr * 1.55), ant);
      canvas.drawCircle(Offset(wobble, -hr * 1.60), hr * 0.14,
          Paint()..color = accentColor);
    case 'lili':
      final bool blink = (t % (pi * 2)) > pi * 1.80;
      for (final ey in [-hr * 0.42, hr * 0.42]) {
        if (blink) {
          canvas.drawLine(
              Offset(hr * 0.08, ey),
              Offset(hr * 0.38, ey),
              Paint()
                ..color = bodyColorDark
                ..strokeWidth = hr * 0.22
                ..strokeCap = StrokeCap.round
                ..style = PaintingStyle.stroke);
        } else {
          canvas.drawCircle(Offset(hr * 0.20, ey), hr * 0.28, eyeWhite);
          canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.16,
              Paint()..color = Colors.black);
          canvas.drawCircle(Offset(hr * 0.14, ey - hr * 0.10), hr * 0.08,
              Paint()..color = Colors.white);
        }
      }
      for (final s in [-1.0, 1.0]) {
        canvas.drawCircle(Offset(hr * 0.55, s * hr * 0.60), hr * 0.20,
            Paint()..color = const Color(0x55FF5080));
      }
      drawSmile(canvas, hr, bodyColorDark);
    case 'robo':
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
    case 'serpente':
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
      drawTongue(canvas, hr, t, color: const Color(0xFFFF1744), speed: 5);
    case 'dragao':
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
      drawEyesAngry(canvas, hr, eyeWhite, eyePupil, bodyColorDark);
      final flicker = sin(t * 7) * 0.3 + 0.7;
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * (0.85 + flicker * 0.3), 0),
              width: hr * (0.7 * flicker),
              height: hr * (0.4 * flicker)),
          Paint()..color = const Color(0xFFFF6D00).withValues(alpha: 0.85));
    case 'galaxia':
      for (final ey in [-hr * 0.40, hr * 0.40]) {
        canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.30,
            Paint()..color = const Color(0xFF1A0050));
        canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.20,
            Paint()..color = accentColor.withValues(alpha: 0.8));
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
            ..color = accentColor.withValues(alpha: 0.12 + aura * 0.08)
            ..style = PaintingStyle.stroke
            ..strokeWidth = hr * 0.08);
    case 'neon':
      final glow = sin(t * 5) * 0.5 + 0.5;
      for (final ey in [-hr * 0.42, hr * 0.42]) {
        canvas.drawCircle(
            Offset(hr * 0.22, ey),
            hr * (0.32 + glow * 0.06),
            Paint()
              ..color = accentColor.withValues(alpha: 0.25 + glow * 0.15));
        canvas.drawCircle(
            Offset(hr * 0.22, ey), hr * 0.26, Paint()..color = Colors.black);
        canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.18,
            Paint()..color = accentColor.withValues(alpha: 0.8 + glow * 0.2));
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(hr * 0.22, ey),
                width: hr * 0.10,
                height: hr * 0.22),
            eyePupil);
      }
    case 'ouro':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFFFFD700));
      drawSmile(canvas, hr, bodyColorDark);
      final shine = sin(t * 4) * 0.5 + 0.5;
      canvas.drawCircle(
          Offset(hr * 0.45, -hr * 0.60),
          hr * (0.08 + shine * 0.05),
          Paint()
            ..color =
                const Color(0xFFFFFF00).withValues(alpha: 0.7 + shine * 0.3));
    case 'verde':
      drawEyesNormal(canvas, hr, eyeWhite, eyePupil, bodyColorDark);
      drawTongue(canvas, hr, t, color: const Color(0xFF1B5E20));
    case 'roxo':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFF7B1FA2));
      canvas.drawLine(
          Offset(hr * 0.08, hr * 0.45),
          Offset(hr * 0.48, hr * 0.45),
          Paint()
            ..color = bodyColorDark
            ..strokeWidth = hr * 0.13
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
    case 'laranja':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFFE65100));
      drawSmile(canvas, hr, bodyColorDark);
      drawTongue(canvas, hr, t, color: const Color(0xFFBF360C), speed: 3);
    case 'rosa':
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
          drawEyesRound(
              canvas, hr, eyeWhite, eyePupil, const Color(0xFFE91E63));
        }
      }
      drawSmile(canvas, hr, bodyColorDark);
    case 'azul':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFF0D47A1));
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(hr * 0.28, hr * 0.40),
            width: hr * 0.60,
            height: hr * 0.35),
        0,
        pi,
        false,
        Paint()
          ..color = bodyColorDark.withValues(alpha: 0.7)
          ..strokeWidth = hr * 0.11
          ..style = PaintingStyle.stroke,
      );
    case 'gelo':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFF1565C0));
      final breath = sin(t * 2) * 0.5 + 0.5;
      for (int b = 0; b < 3; b++) {
        canvas.drawCircle(
          Offset(hr * (1.05 + b * 0.22), hr * 0.10 * sin(t + b)),
          hr * (0.08 + breath * 0.04),
          Paint()
            ..color =
                const Color(0xFF82B1FF).withValues(alpha: 0.4 - b * 0.12),
        );
      }
    case 'coral':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFFBF360C));
      drawSmile(canvas, hr, bodyColorDark);
      drawTongue(canvas, hr, t, color: const Color(0xFF7F0000), speed: 3);
    case 'cinza':
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
            Paint()..color = bodyColor);
      }
      drawFrown(canvas, hr, bodyColorDark);
    case 'marrom':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFF4E342E));
      canvas.drawLine(
          Offset(hr * 0.10, hr * 0.42),
          Offset(hr * 0.46, hr * 0.42),
          Paint()
            ..color = bodyColorDark
            ..strokeWidth = hr * 0.12
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
    case 'indigo':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFF283593));
      final lightning = Paint()
        ..color = accentColor.withValues(alpha: 0.7)
        ..strokeWidth = hr * 0.09
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (final s in [-1.0, 1.0]) {
        if (sin(t * 6 + s * 2) > 0.3) {
          canvas.drawLine(Offset(hr * 0.22, s * hr * 0.55),
              Offset(hr * 0.42, s * hr * 0.85), lightning);
        }
      }
    case 'esmeralda':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFF00695C));
      drawSmile(canvas, hr, bodyColorDark);
      final shine = sin(t * 4) * 0.5 + 0.5;
      canvas.drawCircle(
          Offset(hr * 0.60, -hr * 0.65),
          hr * (0.07 + shine * 0.05),
          Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.8));
    case 'cristal':
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
    case 'vulcao':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFFFF3D00));
      drawEyesAngry(canvas, hr, eyeWhite, eyePupil, bodyColorDark);
      final erupt = sin(t * 6) * 0.5 + 0.5;
      for (final s in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hr * (0.22 + s * 0.32),
                  -hr * (0.75 + erupt * 0.2)),
              width: hr * 0.15,
              height: hr * (0.25 + erupt * 0.15)),
          Paint()..color = const Color(0xFFFF6D00).withValues(alpha: 0.8),
        );
      }
      drawFrown(canvas, hr, bodyColorDark);
    case 'oceano':
      drawEyesRound(canvas, hr, eyeWhite, eyePupil, const Color(0xFF01579B));
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
          ..color = bodyColorDark
          ..strokeWidth = hr * 0.12
          ..style = PaintingStyle.stroke,
      );
    case 'aurora':
      for (final ey in [-hr * 0.40, hr * 0.40]) {
        final glow = sin(t * 3 + ey) * 0.5 + 0.5;
        canvas.drawCircle(Offset(hr * 0.22, ey), hr * (0.35 + glow * 0.06),
            Paint()..color = accentColor.withValues(alpha: 0.20));
        canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.28, eyeWhite);
        canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.18,
            Paint()..color = const Color(0xFF18FFFF).withValues(alpha: 0.9));
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(hr * 0.24, ey),
                width: hr * 0.10,
                height: hr * 0.22),
            eyePupil);
      }
      final magic = sin(t * 4) * 0.5 + 0.5;
      canvas.drawCircle(
          Offset(hr * 0.80, -hr * 0.70),
          hr * (0.07 + magic * 0.06),
          Paint()
            ..color = accentColor.withValues(alpha: 0.7 + magic * 0.3));
    default:
      drawEyesNormal(canvas, hr, eyeWhite, eyePupil, bodyColorDark);
  }
}
DART

echo "✅ expressions_skins.dart criado"

# ─────────────────────────────────────────────────────────────
# 4. expressions_animal.dart
# ─────────────────────────────────────────────────────────────
cat > "$DIR/expressions_animal.dart" << 'DART'
// lib/components/expressions/expressions_animal.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Color;
import '../animal_skins.dart';

const _animalSkins = {
  'gato', 'cachorro', 'leao', 'vaca', 'coelho',
  'peixe', 'dragao_animal', 'raposa',
};

bool isAnimalSkin(String skinId) => _animalSkins.contains(skinId);

void renderAnimalBackLayer(
  Canvas canvas,
  String skinId,
  double hr,
  double t,
  Color bodyColor,
  Color bodyColorDark,
) {
  renderAnimalBackLayer(canvas, skinId, hr, t, bodyColor, bodyColorDark);
}

void renderAnimalFrontLayer(
  Canvas canvas,
  String skinId,
  double hr,
  double t,
  Color bodyColor,
  Color bodyColorDark,
) {
  renderAnimalFront(canvas, skinId, hr, t, bodyColor, bodyColorDark);
}
DART

echo "✅ expressions_animal.dart criado"

# ─────────────────────────────────────────────────────────────
# 5. expressions_mixin.dart — orquestrador principal
# ─────────────────────────────────────────────────────────────
cat > "$DIR/expressions_mixin.dart" << 'DART'
// lib/components/expressions/expressions_mixin.dart
import 'dart:ui';
import 'package:flutter/material.dart' show Color;
import '../animal_skins.dart';
import 'expressions_animal.dart';
import 'expressions_skins.dart';

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
    return switch (skinId) {
      'classic'      => (2.2, 1.9),
      'hot'          => (2.4, 1.7),
      'sorriso'      => (2.0, 2.2),
      'veneno'       => (2.6, 1.6),
      'fantasma'     => (1.9, 2.1),
      'piranha'      => (2.8, 1.5),
      'lava'         => (2.3, 1.8),
      'alien'        => (2.0, 2.3),
      'lili'         => (2.1, 2.0),
      'robo'         => (2.4, 2.0),
      'serpente'     => (2.7, 1.6),
      'dragao'       => (2.5, 1.8),
      'galaxia'      => (2.1, 2.1),
      'neon'         => (2.3, 1.7),
      'ouro'         => (2.2, 2.0),
      _              => (2.2, 1.9),
    };
  }

  void renderAnimalBack(Canvas canvas, double hr, double t) {
    renderAnimalBackLayer(
        canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
  }

  void renderExpression(Canvas canvas, double hr, double t) {
    if (isAnimalSkin(skinId)) {
      renderAnimalFrontLayer(
          canvas, skinId, hr, t, skinBodyColor, skinBodyColorDark);
      return;
    }
    renderSkinExpression(
      canvas,
      skinId,
      hr,
      t,
      eyeWhite,
      eyePupil,
      skinBodyColor,
      skinBodyColorDark,
      skinAccentColor,
    );
  }
}
DART

echo "✅ expressions_mixin.dart criado"

# ─────────────────────────────────────────────────────────────
# Resumo final
# ─────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo "✅ Refatoração concluída!"
echo "Arquivos criados em: $DIR"
echo ""
echo "⚠️  Lembre de:"
echo "  1. Atualizar o import nos arquivos que usavam snake_player_expressions.dart:"
echo "     import 'expressions/expressions_mixin.dart';"
echo "  2. Deletar o arquivo antigo:"
echo "     lib/components/snake_player_expressions.dart"
echo "════════════════════════════════════════"
