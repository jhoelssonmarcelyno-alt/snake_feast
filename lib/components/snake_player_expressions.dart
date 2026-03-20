// lib/components/snake_player_expressions.dart
// Mixin com todas as expressões faciais animadas do player.
import 'dart:math' show sin, pi;
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, Color;

mixin PlayerExpressions {
  // Subclasse deve expor skin e paints necessários
  Color get skinBodyColor;
  Color get skinBodyColorDark;
  Color get skinAccentColor;
  String get skinId;

  Paint get eyeWhite;
  Paint get eyePupil;

  void renderExpression(Canvas canvas, double hr, double t) {
    switch (skinId) {
      case 'classic':   _exprClassic(canvas, hr, t);   break;
      case 'hot':       _exprHot(canvas, hr, t);        break;
      case 'sorriso':   _exprSorriso(canvas, hr, t);    break;
      case 'veneno':    _exprVeneno(canvas, hr, t);     break;
      case 'fantasma':  _exprFantasma(canvas, hr, t);   break;
      case 'piranha':   _exprPiranha(canvas, hr, t);    break;
      case 'lava':      _exprLava(canvas, hr, t);       break;
      case 'alien':     _exprAlien(canvas, hr, t);      break;
      case 'lili':      _exprLili(canvas, hr, t);       break;
      case 'robo':      _exprRobo(canvas, hr, t);       break;
      case 'serpente':  _exprSerpente(canvas, hr, t);   break;
      default:          _defaultEyes(canvas, hr);        break;
    }
  }

  void _defaultEyes(Canvas canvas, double hr) {
    for (final ey in [-hr * 0.4, hr * 0.4]) {
      canvas.drawCircle(Offset(hr * 0.3, ey), hr * 0.27, eyeWhite);
      canvas.drawCircle(Offset(hr * 0.33, ey), hr * 0.15, eyePupil);
    }
  }

  // ── CLASSIC ─────────────────────────────────────────────────
  void _exprClassic(Canvas canvas, double hr, double t) {
    _defaultEyes(canvas, hr);
    final double ext = (sin(t * 4) * 0.5 + 0.5);
    final Paint tongue = Paint()
      ..color = const Color(0xFFFF1744)
      ..strokeWidth = hr * 0.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final double len = hr * (0.7 + ext * 0.5);
    canvas.drawLine(Offset(hr * 0.85, 0), Offset(hr * 0.85 + len, 0), tongue);
    canvas.drawLine(Offset(hr * 0.85 + len * 0.6, 0),
        Offset(hr * 0.85 + len, -hr * 0.32), tongue);
    canvas.drawLine(Offset(hr * 0.85 + len * 0.6, 0),
        Offset(hr * 0.85 + len, hr * 0.32), tongue);
  }

  // ── HOT ─────────────────────────────────────────────────────
  void _exprHot(Canvas canvas, double hr, double t) {
    final Paint brow = Paint()
      ..color = const Color(0xFF1A0000)
      ..strokeWidth = hr * 0.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(hr * 0.05, -hr * 0.62), Offset(hr * 0.52, -hr * 0.38), brow);
    canvas.drawLine(
        Offset(hr * 0.05, hr * 0.62), Offset(hr * 0.52, hr * 0.38), brow);
    for (final ey in [-hr * 0.38, hr * 0.38]) {
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.26, eyeWhite);
      canvas.drawCircle(Offset(hr * 0.27, ey), hr * 0.17,
          Paint()..color = const Color(0xFFFF1744));
      canvas.drawLine(
          Offset(hr * 0.05, ey - hr * 0.13),
          Offset(hr * 0.42, ey - hr * 0.05),
          Paint()
            ..color = const Color(0xFF1A0000)
            ..strokeWidth = hr * 0.15
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
    }
    canvas.drawLine(
        Offset(hr * 0.05, hr * 0.55), Offset(hr * 0.55, hr * 0.55), brow);
  }

  // ── SORRISO ──────────────────────────────────────────────────
  void _exprSorriso(Canvas canvas, double hr, double t) {
    final Paint eye = Paint()
      ..color = const Color(0xFF3E2000)
      ..strokeWidth = hr * 0.17
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final ey in [-hr * 0.44, hr * 0.44]) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(hr * 0.22, ey), width: hr * 0.5, height: hr * 0.5),
        pi, pi, false, eye,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.18, hr * 0.05),
          width: hr * 1.3, height: hr * 1.1),
      0.0, pi, true,
      Paint()..color = const Color(0xFF1A0E00),
    );
    final teethPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(-hr * 0.22 + i * hr * 0.28, hr * 0.04, hr * 0.22, hr * 0.28),
        teethPaint,
      );
    }
    final double blush = 0.18 + sin(t * 2) * 0.02;
    for (final cy in [-hr * 0.55, hr * 0.55]) {
      canvas.drawCircle(Offset(hr * 0.55, cy), hr * blush,
          Paint()..color = const Color(0x40FF5080));
    }
  }

  // ── VENENO ───────────────────────────────────────────────────
  void _exprVeneno(Canvas canvas, double hr, double t) {
    final Paint x = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = hr * 0.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final ey in [-hr * 0.4, hr * 0.4]) {
      canvas.drawCircle(Offset(hr * 0.25, ey), hr * 0.27,
          Paint()..color = const Color(0xFF1F1F1F));
      canvas.drawLine(Offset(hr * 0.1, ey - hr * 0.16),
          Offset(hr * 0.4, ey + hr * 0.16), x);
      canvas.drawLine(Offset(hr * 0.4, ey - hr * 0.16),
          Offset(hr * 0.1, ey + hr * 0.16), x);
    }
    final double sway = sin(t * 3) * hr * 0.08;
    final Paint tongue = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = hr * 0.18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(hr * 0.22, hr * 0.45),
        Offset(hr * 0.22 + sway, hr * 0.85), tongue);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.22, hr * 0.62),
          width: hr * 0.7, height: hr * 0.4),
      0, pi, false,
      Paint()
        ..color = const Color(0xFF00E676)
        ..strokeWidth = hr * 0.15
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── FANTASMA ─────────────────────────────────────────────────
  void _exprFantasma(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.4, hr * 0.4]) {
      canvas.drawCircle(Offset(hr * 0.22, ey), hr * 0.32,
          Paint()..color = const Color(0xFF111111));
      canvas.drawCircle(Offset(hr * 0.14, ey - hr * 0.12), hr * 0.12,
          Paint()..color = const Color(0x99C8E6FF));
      canvas.drawCircle(Offset(hr * 0.3, ey + hr * 0.08), hr * 0.07,
          Paint()..color = const Color(0x66C8E6FF));
    }
    final double mouthR = hr * 0.24 + sin(t * 5) * hr * 0.02;
    canvas.drawCircle(Offset(hr * 0.32, hr * 0.45), mouthR,
        Paint()..color = const Color(0xFF111111));
    canvas.drawCircle(Offset(hr * 0.32, hr * 0.45), mouthR,
        Paint()
          ..color = const Color(0x44FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  // ── PIRANHA ──────────────────────────────────────────────────
  void _exprPiranha(Canvas canvas, double hr, double t) {
    for (final ey in [-hr * 0.46, hr * 0.46]) {
      canvas.drawCircle(Offset(hr * 0.2, ey), hr * 0.26, eyeWhite);
      canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.17,
          Paint()..color = const Color(0xFF1B5E20));
      canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.09, eyePupil);
    }
    final Paint brow = Paint()
      ..color = const Color(0xFF0D1A08)
      ..strokeWidth = hr * 0.16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(hr * 0.02, -hr * 0.65), Offset(hr * 0.48, -hr * 0.38), brow);
    canvas.drawLine(
        Offset(hr * 0.02, hr * 0.65), Offset(hr * 0.48, hr * 0.38), brow);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.1, 0), width: hr * 1.6, height: hr * 1.6),
      -0.3, pi + 0.6, true,
      Paint()..color = const Color(0xFF0D1A08),
    );
    final t1 = Paint()..color = Colors.white;
    final t2 = Paint()..color = const Color(0xFFCCFF80);
    for (int i = 0; i < 4; i++) {
      final tx = -hr * 0.38 + i * hr * 0.26;
      canvas.drawPath(
          Path()..moveTo(tx, 0)..lineTo(tx + hr * 0.13, -hr * 0.3)
              ..lineTo(tx + hr * 0.26, 0)..close(), t1);
    }
    for (int i = 0; i < 3; i++) {
      final tx = -hr * 0.25 + i * hr * 0.26;
      canvas.drawPath(
          Path()..moveTo(tx, 0)..lineTo(tx + hr * 0.13, hr * 0.26)
              ..lineTo(tx + hr * 0.26, 0)..close(), t2);
    }
  }

  // ── LAVA ─────────────────────────────────────────────────────
  void _exprLava(Canvas canvas, double hr, double t) {
    final scar = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = hr * 0.13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(-hr * 0.05, -hr * 0.72), Offset(hr * 0.05, hr * 0.72), scar);
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(Offset(-hr * 0.22, i * hr * 0.26),
          Offset(hr * 0.22, i * hr * 0.26), scar);
    }
    canvas.drawCircle(Offset(hr * 0.28, 0), hr * 0.34, eyeWhite);
    canvas.drawCircle(Offset(hr * 0.3, 0), hr * 0.22,
        Paint()..color = const Color(0xFFFF3D00));
    canvas.drawCircle(Offset(hr * 0.3, 0), hr * 0.1, eyePupil);
    final double lid = hr * 0.2 + sin(t * 0.8) * hr * 0.1;
    canvas.drawLine(
        Offset(hr * 0.06, -lid), Offset(hr * 0.52, -lid),
        Paint()
          ..color = skinBodyColorDark
          ..strokeWidth = hr * 0.2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    final brow = Paint()
      ..color = const Color(0xFF2A0800)
      ..strokeWidth = hr * 0.16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(-hr * 0.05, -hr * 0.48), Offset(hr * 0.55, -hr * 0.34), brow);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.22, hr * 0.7),
          width: hr * 0.7, height: hr * 0.4),
      0, pi, false,
      Paint()
        ..color = const Color(0xFF2A0800)
        ..strokeWidth = hr * 0.15
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── ALIEN ────────────────────────────────────────────────────
  void _exprAlien(Canvas canvas, double hr, double t) {
    final lens = Paint()..color = const Color(0xE0000000);
    final ring = Paint()
      ..color = skinAccentColor.withOpacity(0.9)
      ..strokeWidth = hr * 0.14
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(hr * 0.2, -hr * 0.38), hr * 0.34, lens);
    canvas.drawCircle(Offset(hr * 0.2, -hr * 0.38), hr * 0.34, ring);
    canvas.drawCircle(Offset(hr * 0.22, hr * 0.38), hr * 0.2, lens);
    canvas.drawCircle(Offset(hr * 0.22, hr * 0.38), hr * 0.2, ring);
    final double wobble = sin(t * 4) * hr * 0.12;
    final Paint ant = Paint()
      ..color = skinAccentColor
      ..strokeWidth = hr * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -hr), Offset(wobble, -hr * 1.6), ant);
    canvas.drawCircle(Offset(wobble, -hr * 1.65), hr * 0.14,
        Paint()..color = skinAccentColor);
    final smile = Paint()
      ..color = const Color(0xFF1A2A00)
      ..strokeWidth = hr * 0.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.3, hr * 0.22),
          width: hr * 0.65, height: hr * 0.5),
      pi * 0.1, pi * 0.8, false, smile,
    );
  }

  // ── LILI ─────────────────────────────────────────────────────
  void _exprLili(Canvas canvas, double hr, double t) {
    final bool piscando = (t % (pi * 2)) > pi * 1.8;
    for (final ey in [-hr * 0.42, hr * 0.42]) {
      if (piscando) {
        canvas.drawLine(
          Offset(hr * 0.08, ey), Offset(hr * 0.38, ey),
          Paint()
            ..color = skinBodyColorDark
            ..strokeWidth = hr * 0.22
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawCircle(Offset(hr * 0.2, ey), hr * 0.3, eyeWhite);
        canvas.drawCircle(Offset(hr * 0.24, ey), hr * 0.2, eyePupil);
        canvas.drawCircle(Offset(hr * 0.16, ey - hr * 0.1), hr * 0.1, eyeWhite);
      }
    }
    for (final cy in [-hr * 0.62, hr * 0.62]) {
      canvas.drawCircle(Offset(hr * 0.55, cy), hr * 0.22,
          Paint()..color = const Color(0x55FF5080));
    }
    final smile = Paint()
      ..color = const Color(0xFF880E4F)
      ..strokeWidth = hr * 0.14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(hr * 0.28, hr * 0.18),
          width: hr * 0.6, height: hr * 0.5),
      0.1, pi - 0.2, false, smile,
    );
  }

  // ── ROBO ─────────────────────────────────────────────────────
  void _exprRobo(Canvas canvas, double hr, double t) {
    final dark = Paint()..color = const Color(0xFF1A1A1A);
    final led0 = Paint()..color = const Color(0xFF00E5FF);
    final led1 = Paint()..color = const Color(0xFFF44336);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hr * -0.05, -hr * 0.65, hr * 0.75, hr * 1.2),
        const Radius.circular(4),
      ),
      dark,
    );
    final bool blink = (t % (pi * 2)) > pi * 1.85;
    for (int i = 0; i < 2; i++) {
      final ey = i == 0 ? -hr * 0.38 : hr * 0.38;
      if (blink) {
        canvas.drawRect(
          Rect.fromLTWH(hr * 0.08, ey - hr * 0.04, hr * 0.34, hr * 0.08),
          i == 0 ? led0 : led1,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(hr * 0.06, ey - hr * 0.2, hr * 0.38, hr * 0.38),
          i == 0 ? led0 : led1,
        );
      }
    }
    final mouthLeds = [1, 0, 0, 0, 1];
    final mouthBot = [0, 1, 1, 1, 0];
    for (int i = 0; i < 5; i++) {
      if (mouthLeds[i] == 1)
        canvas.drawRect(
            Rect.fromLTWH(hr * 0.02 + i * hr * 0.13, hr * 0.32, hr * 0.1, hr * 0.12), led0);
      if (mouthBot[i] == 1)
        canvas.drawRect(
            Rect.fromLTWH(hr * 0.02 + i * hr * 0.13, hr * 0.45, hr * 0.1, hr * 0.12), led0);
    }
    final ant = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = hr * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -hr), Offset(0, -hr * 1.52), ant);
    canvas.drawCircle(Offset(0, -hr * 1.58), hr * 0.11, led1);
  }

  // ── SERPENTE ─────────────────────────────────────────────────
  void _exprSerpente(Canvas canvas, double hr, double t) {
    final brow = Paint()
      ..color = const Color(0xFF1A3300)
      ..strokeWidth = hr * 0.22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(Path()
      ..moveTo(-hr * 0.35, -hr * 0.55)
      ..quadraticBezierTo(hr * 0.05, -hr * 0.72, hr * 0.42, -hr * 0.50), brow);
    canvas.drawPath(Path()
      ..moveTo(-hr * 0.35, hr * 0.55)
      ..quadraticBezierTo(hr * 0.05, hr * 0.72, hr * 0.42, hr * 0.50), brow);
    for (final ey in [-hr * 0.35, hr * 0.35]) {
      canvas.drawOval(
          Rect.fromCenter(center: Offset(hr * 0.12, ey), width: hr * 0.55, height: hr * 0.38),
          Paint()..color = const Color(0xFFFFEEEE));
      canvas.drawCircle(Offset(hr * 0.18, ey), hr * 0.22,
          Paint()..color = const Color(0xFFCC0000));
      canvas.drawOval(
          Rect.fromCenter(center: Offset(hr * 0.20, ey), width: hr * 0.08, height: hr * 0.20),
          Paint()..color = Colors.black);
      canvas.drawCircle(Offset(hr * 0.13, ey - hr * 0.08), hr * 0.07,
          Paint()..color = Colors.white.withOpacity(0.8));
    }
    canvas.drawCircle(Offset(hr * 0.72, -hr * 0.1), hr * 0.07,
        Paint()..color = const Color(0xFF1A3300));
    canvas.drawCircle(Offset(hr * 0.72, hr * 0.1), hr * 0.07,
        Paint()..color = const Color(0xFF1A3300));
    canvas.drawPath(
        Path()
          ..moveTo(hr * 0.2, -hr * 0.15)
          ..quadraticBezierTo(hr * 1.1, 0, hr * 0.2, hr * 0.15)
          ..close(),
        Paint()..color = const Color(0xFF8B0000));
    final tw = Paint()..color = Colors.white;
    for (int i = 0; i < 4; i++) {
      final tx = hr * (0.3 + i * 0.18);
      canvas.drawPath(
          Path()..moveTo(tx, -hr * 0.14)..lineTo(tx + hr * 0.08, -hr * 0.38)
              ..lineTo(tx + hr * 0.16, -hr * 0.14)..close(), tw);
    }
    for (int i = 0; i < 3; i++) {
      final tx = hr * (0.38 + i * 0.18);
      canvas.drawPath(
          Path()..moveTo(tx, hr * 0.14)..lineTo(tx + hr * 0.08, hr * 0.32)
              ..lineTo(tx + hr * 0.16, hr * 0.14)..close(),
          Paint()..color = const Color(0xFFDDDDCC));
    }
    final ext = sin(t * 4) * 0.3 + 0.7;
    final tg = Paint()
      ..color = const Color(0xFFFF1744)
      ..strokeWidth = hr * 0.14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(hr * 0.9, 0), Offset(hr * (0.9 + 0.5 * ext), 0), tg);
    final tip = Offset(hr * (0.9 + 0.5 * ext), 0);
    canvas.drawLine(tip, Offset(tip.dx + hr * 0.22 * ext, -hr * 0.18 * ext), tg);
    canvas.drawLine(tip, Offset(tip.dx + hr * 0.22 * ext, hr * 0.18 * ext), tg);
  }
}
