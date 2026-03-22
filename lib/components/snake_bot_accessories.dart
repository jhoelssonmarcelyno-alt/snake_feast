// lib/components/snake_bot_accessories.dart
// Mixins com os acessórios visuais de cada personalidade de bot.
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, Color;

mixin BotAccessoryRenderer {
  double get accTimer;

  void renderAccessoryForPersonality(
      BotPersonalityType personality, Canvas canvas, Offset h, double r) {
    switch (personality) {
      case BotPersonalityType.superHero:
        _accSuperHero(canvas, h, r);
        break;
      case BotPersonalityType.clown:
        _accClown(canvas, h, r);
        break;
      case BotPersonalityType.samurai:
        _accSamurai(canvas, h, r);
        break;
      case BotPersonalityType.witch:
        _accWitch(canvas, h, r);
        break;
      case BotPersonalityType.detective:
        _accDetective(canvas, h, r);
        break;
      case BotPersonalityType.alien:
        _accAlien(canvas, h, r);
        break;
      case BotPersonalityType.ghost:
        _accGhost(canvas, h, r);
        break;
      case BotPersonalityType.robot:
        _accRobot(canvas, h, r);
        break;
      case BotPersonalityType.viking:
        _accViking(canvas, h, r);
        break;
      case BotPersonalityType.police:
        _accPolice(canvas, h, r);
        break;
      case BotPersonalityType.chef:
        _accChef(canvas, h, r);
        break;
      case BotPersonalityType.vampire:
        _accVampire(canvas, h, r);
        break;
    }
  }

  // ── SUPER-HERÓI ───────────────────────────────────────────────
  void _accSuperHero(Canvas canvas, Offset h, double r) {
    final mask = Paint()..color = const Color(0xFFFF1744);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(h.dx + r * 0.2, h.dy),
                width: r * 0.9,
                height: r * 0.35),
            const Radius.circular(4)),
        mask);
    _drawStar(canvas, Offset(h.dx + r * 0.2, h.dy), r * 0.18,
        Paint()..color = const Color(0xFFFFD600));
    final cape = Paint()..color = const Color(0xFFFF1744).withValues(alpha: 0.8);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx - r * 0.8, h.dy - r * 0.4)
          ..lineTo(h.dx - r * 1.6, h.dy + r * 0.6)
          ..lineTo(h.dx - r * 0.4, h.dy + r * 0.2)
          ..close(),
        cape);
  }

  // ── PALHAÇO ───────────────────────────────────────────────────
  void _accClown(Canvas canvas, Offset h, double r) {
    final hat = Paint()..color = const Color(0xFFE040FB);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx + r * 0.2, h.dy - r * 2.0)
          ..lineTo(h.dx - r * 0.4, h.dy - r * 0.8)
          ..lineTo(h.dx + r * 0.8, h.dy - r * 0.8)
          ..close(),
        hat);
    canvas.drawCircle(Offset(h.dx + r * 0.2, h.dy - r * 2.0), r * 0.18,
        Paint()..color = const Color(0xFFFFD600));
    canvas.drawCircle(Offset(h.dx + r * 0.55, h.dy), r * 0.22,
        Paint()..color = const Color(0xFFFF1744));
    canvas.drawCircle(Offset(h.dx + r * 0.1, h.dy - r * 1.3), r * 0.12,
        Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(Offset(h.dx + r * 0.45, h.dy - r * 1.1), r * 0.1,
        Paint()..color = const Color(0xFF69F0AE));
  }

  // ── SAMURAI ───────────────────────────────────────────────────
  void _accSamurai(Canvas canvas, Offset h, double r) {
    final kabuto = Paint()..color = const Color(0xFF37474F);
    final accent = Paint()..color = const Color(0xFFFF5252);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(h.dx, h.dy - r * 0.3),
            width: r * 2.2,
            height: r * 1.6),
        pi,
        pi,
        true,
        kabuto);
    canvas.drawRect(
        Rect.fromLTWH(h.dx - r * 1.2, h.dy - r * 0.5, r * 2.4, r * 0.25),
        Paint()..color = const Color(0xFF263238));
    canvas.drawRect(
        Rect.fromLTWH(h.dx - r * 0.08, h.dy - r * 1.8, r * 0.16, r * 0.9),
        accent);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(h.dx, h.dy - r * 1.8),
            width: r * 0.5,
            height: r * 0.4),
        pi,
        pi,
        true,
        accent);
  }

  // ── BRUXA ─────────────────────────────────────────────────────
  void _accWitch(Canvas canvas, Offset h, double r) {
    final hat = Paint()..color = const Color(0xFF1A1A1A);
    final brim = Paint()..color = const Color(0xFF2A2A2A);
    final accent = Paint()..color = const Color(0xFF9C27B0);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(h.dx + r * 0.1, h.dy - r * 0.75),
            width: r * 2.2,
            height: r * 0.45),
        brim);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx + r * 0.1, h.dy - r * 2.2)
          ..lineTo(h.dx - r * 0.5, h.dy - r * 0.75)
          ..lineTo(h.dx + r * 0.7, h.dy - r * 0.75)
          ..close(),
        hat);
    canvas.drawRect(
        Rect.fromLTWH(h.dx - r * 0.4, h.dy - r * 1.05, r * 0.9, r * 0.2),
        accent);
    final star = Paint()..color = const Color(0xFFFFD600);
    canvas.drawCircle(Offset(h.dx + r * 1.0, h.dy - r * 0.5), r * 0.1, star);
    canvas.drawCircle(Offset(h.dx + r * 1.2, h.dy - r * 0.2), r * 0.08, star);
    canvas.drawCircle(Offset(h.dx + r * 0.9, h.dy), r * 0.06, star);
  }

  // ── DETETIVE ──────────────────────────────────────────────────
  void _accDetective(Canvas canvas, Offset h, double r) {
    final hat = Paint()..color = const Color(0xFF4E342E);
    final band = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(h.dx + r * 0.1, h.dy - r * 0.8),
            width: r * 2.4,
            height: r * 0.4),
        hat);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(h.dx - r * 0.55, h.dy - r * 1.85, r * 1.3, r * 1.1),
            const Radius.circular(8)),
        hat);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(h.dx + r * 0.1, h.dy - r * 1.85),
            width: r * 0.6,
            height: r * 0.2),
        Paint()..color = const Color(0xFF3E2723));
    canvas.drawRect(
        Rect.fromLTWH(h.dx - r * 0.55, h.dy - r * 0.97, r * 1.3, r * 0.18),
        band);
  }

  // ── ALIEN ─────────────────────────────────────────────────────
  void _accAlien(Canvas canvas, Offset h, double r) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(h.dx + r * 0.1, h.dy - r * 0.2),
            width: r * 1.1,
            height: r * 0.7),
        Paint()..color = Colors.black);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(h.dx + r * 0.0, h.dy - r * 0.22),
            width: r * 0.55,
            height: r * 0.35),
        Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.8));
    final ant = Paint()
      ..color = const Color(0xFF76FF03)
      ..strokeWidth = r * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(h.dx - r * 0.2, h.dy - r),
        Offset(h.dx - r * 0.5, h.dy - r * 1.8), ant);
    canvas.drawLine(Offset(h.dx + r * 0.3, h.dy - r),
        Offset(h.dx + r * 0.6, h.dy - r * 1.8), ant);
    canvas.drawCircle(Offset(h.dx - r * 0.5, h.dy - r * 1.8), r * 0.15,
        Paint()..color = const Color(0xFF76FF03));
    canvas.drawCircle(Offset(h.dx + r * 0.6, h.dy - r * 1.8), r * 0.15,
        Paint()..color = const Color(0xFF76FF03));
  }

  // ── FANTASMA ──────────────────────────────────────────────────
  void _accGhost(Canvas canvas, Offset h, double r) {
    final halo = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.2;
    final float = sin(accTimer * 3) * r * 0.1;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(h.dx, h.dy - r * 1.4 + float),
            width: r * 1.4,
            height: r * 0.45),
        halo);
    final ghost = Paint()..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx - r * 0.7, h.dy + r * 0.5)
          ..quadraticBezierTo(
              h.dx - r * 0.5, h.dy + r * 1.1, h.dx - r * 0.2, h.dy + r * 0.7)
          ..quadraticBezierTo(
              h.dx, h.dy + r * 1.1, h.dx + r * 0.2, h.dy + r * 0.7)
          ..quadraticBezierTo(
              h.dx + r * 0.5, h.dy + r * 1.1, h.dx + r * 0.7, h.dy + r * 0.5),
        ghost);
  }

  // ── ROBÔ ──────────────────────────────────────────────────────
  void _accRobot(Canvas canvas, Offset h, double r) {
    final metal = Paint()..color = const Color(0xFF607D8B);
    final led = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawLine(
        Offset(h.dx, h.dy - r),
        Offset(h.dx, h.dy - r * 1.7),
        Paint()
          ..color = metal.color
          ..strokeWidth = r * 0.15
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    final blink = (sin(accTimer * 6) > 0);
    canvas.drawCircle(
        Offset(h.dx, h.dy - r * 1.7),
        r * 0.18,
        Paint()
          ..color = blink ? const Color(0xFFFF5252) : const Color(0xFF37474F));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(h.dx + r * 0.2, h.dy),
                width: r * 0.9,
                height: r * 0.5),
            const Radius.circular(3)),
        Paint()..color = Colors.black.withValues(alpha: 0.7));
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(h.dx + r * 0.2, h.dy),
            width: r * 0.6,
            height: r * 0.15),
        led..color = led.color.withValues(alpha: blink ? 1.0 : 0.4));
  }

  // ── VIKING ────────────────────────────────────────────────────
  void _accViking(Canvas canvas, Offset h, double r) {
    final helm = Paint()..color = const Color(0xFF757575);
    final horn = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(h.dx, h.dy - r * 0.2),
            width: r * 2.0,
            height: r * 1.4),
        pi,
        pi,
        true,
        helm);
    canvas.drawRect(
        Rect.fromLTWH(h.dx - r * 1.0, h.dy - r * 0.35, r * 2.0, r * 0.25),
        Paint()..color = const Color(0xFF616161));
    canvas.drawPath(
        Path()
          ..moveTo(h.dx - r * 1.0, h.dy - r * 0.3)
          ..quadraticBezierTo(
              h.dx - r * 1.6, h.dy - r * 1.2, h.dx - r * 1.1, h.dy - r * 1.5)
          ..quadraticBezierTo(
              h.dx - r * 0.9, h.dy - r * 0.8, h.dx - r * 0.7, h.dy - r * 0.3),
        horn);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx + r * 1.0, h.dy - r * 0.3)
          ..quadraticBezierTo(
              h.dx + r * 1.6, h.dy - r * 1.2, h.dx + r * 1.1, h.dy - r * 1.5)
          ..quadraticBezierTo(
              h.dx + r * 0.9, h.dy - r * 0.8, h.dx + r * 0.7, h.dy - r * 0.3),
        horn);
  }

  // ── POLICIAL ──────────────────────────────────────────────────
  void _accPolice(Canvas canvas, Offset h, double r) {
    final blue = Paint()..color = const Color(0xFF1565C0);
    final dark = Paint()..color = const Color(0xFF0D47A1);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(h.dx + r * 0.3, h.dy - r * 0.75),
            width: r * 2.0,
            height: r * 0.35),
        dark);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(h.dx - r * 0.55, h.dy - r * 1.5, r * 1.3, r * 0.8),
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8)),
        blue);
    canvas.drawRect(
        Rect.fromLTWH(h.dx - r * 0.55, h.dy - r * 0.85, r * 1.3, r * 0.15),
        Paint()..color = Colors.white);
    _drawStar(canvas, Offset(h.dx + r * 0.1, h.dy - r * 1.1), r * 0.22,
        Paint()..color = const Color(0xFFFFD600));
  }

  // ── CHEF ──────────────────────────────────────────────────────
  void _accChef(Canvas canvas, Offset h, double r) {
    final white = Paint()..color = Colors.white;
    final gray = Paint()..color = const Color(0xFFE0E0E0);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(h.dx - r * 0.55, h.dy - r * 0.85, r * 1.3, r * 0.15),
            const Radius.circular(2)),
        gray);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(h.dx - r * 0.45, h.dy - r * 2.0, r * 1.1, r * 1.2),
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20)),
        white);
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
          Offset(h.dx - r * 0.2 + i * r * 0.3, h.dy - r * 0.95),
          Offset(h.dx - r * 0.2 + i * r * 0.3, h.dy - r * 1.9),
          Paint()
            ..color = gray.color
            ..strokeWidth = r * 0.06
            ..style = PaintingStyle.stroke);
    }
  }

  // ── VAMPIRO ───────────────────────────────────────────────────
  void _accVampire(Canvas canvas, Offset h, double r) {
    final cape = Paint()..color = const Color(0xFF1A1A2E).withValues(alpha: 0.9);
    final red = Paint()..color = const Color(0xFFB71C1C);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx - r * 0.9, h.dy - r * 0.5)
          ..lineTo(h.dx - r * 1.8, h.dy + r * 1.0)
          ..lineTo(h.dx - r * 0.3, h.dy + r * 0.3)
          ..close(),
        cape);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx + r * 0.5, h.dy - r * 0.5)
          ..lineTo(h.dx + r * 1.4, h.dy + r * 1.0)
          ..lineTo(h.dx + r * 0.1, h.dy + r * 0.3)
          ..close(),
        cape);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx - r * 0.8, h.dy - r * 0.5)
          ..lineTo(h.dx, h.dy - r * 0.1)
          ..lineTo(h.dx + r * 0.5, h.dy - r * 0.5),
        cape
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.3
          ..strokeCap = StrokeCap.round);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx + r * 0.28, h.dy + r * 0.35)
          ..lineTo(h.dx + r * 0.32, h.dy + r * 0.6)
          ..lineTo(h.dx + r * 0.38, h.dy + r * 0.35),
        Paint()..color = Colors.white);
    canvas.drawPath(
        Path()
          ..moveTo(h.dx + r * 0.45, h.dy + r * 0.35)
          ..lineTo(h.dx + r * 0.49, h.dy + r * 0.58)
          ..lineTo(h.dx + r * 0.55, h.dy + r * 0.35),
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(h.dx + r * 0.15, h.dy - r * 0.38), r * 0.14, red);
    canvas.drawCircle(Offset(h.dx + r * 0.45, h.dy - r * 0.38), r * 0.14, red);
  }

  // ── Helper: estrela ───────────────────────────────────────────
  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final double rad = i.isEven ? r : r * 0.45;
      final double a = (i * pi / 5) - pi / 2;
      final p = Offset(center.dx + cos(a) * rad, center.dy + sin(a) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// Enum público usado pelo mixin e pelo SnakeBot.
enum BotPersonalityType {
  superHero,
  clown,
  samurai,
  witch,
  detective,
  alien,
  ghost,
  robot,
  viking,
  police,
  chef,
  vampire,
}
