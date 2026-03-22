// lib/ui/main_menu/painters/snake_preview_painter.dart
// VERSÃO ATUALIZADA — preview de skins animais no menu principal
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../components/animal_skins.dart';

const _kAnimalSkinIds = {
  'gato',
  'cachorro',
  'leao',
  'vaca',
  'coelho',
  'peixe',
  'dragao_animal',
  'raposa',
};

class SnakePreviewPainter extends CustomPainter {
  final SnakeSkin skin;
  final double t;

  SnakePreviewPainter({required this.skin, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final double H = size.height;
    final double W = size.width;
    const int N = 22;
    const double SP = 8.5;
    const double amp = 14;
    const double bodyR = 6.5;
    const double headR = 11;
    final double startX = 10;
    final bool isAnimal = _kAnimalSkinIds.contains(skin.id);

    // Gera posições dos segmentos
    final List<Offset> segs = [];
    for (int i = 0; i < N; i++) {
      final double phase = t - (N - 1 - i) * 0.32;
      segs.add(Offset(startX + i * SP, H / 2 + sin(phase) * amp));
    }

    // ── CAUDA DIFERENCIADA ─────────────────────────────────────
    final Offset tailPos = segs.first;
    final Offset tailDir =
        segs.length > 1 ? (segs.first - segs[1]) : const Offset(-1, 0);
    final double tailAngle = atan2(tailDir.dy, tailDir.dx);

    if (isAnimal) {
      renderAnimalTail(canvas, skin.id, tailPos, tailAngle, bodyR);
    } else {
      _drawSnakeTailPreview(canvas, tailPos, tailAngle, bodyR, skin.bodyColor,
          skin.bodyColorDark);
    }

    // ── CORPO ──────────────────────────────────────────────────
    for (int i = 0; i < N - 1; i++) {
      final double progress = i / N;
      final double taper = 1.0 - progress * 0.18;
      final double r = (bodyR * taper).clamp(bodyR * 0.70, bodyR);
      final double mix = i / N;
      final Color base = Color.lerp(skin.bodyColorDark, skin.bodyColor, mix)!;
      final Color ventral = _lighten(base, 0.35);

      // Sombra
      canvas.drawCircle(segs[i] + Offset(r * 0.15, r * 0.20), r * 0.90,
          Paint()..color = Colors.black.withValues(alpha: 0.24));

      // Ventre com gradiente 3D
      final vPaint = Paint()
        ..shader = ui.Gradient.radial(
          segs[i] + Offset(-r * 0.30, -r * 0.42),
          r * 2.2,
          [ventral, base, skin.bodyColorDark],
          [0.0, 0.52, 1.0],
        );
      canvas.drawCircle(segs[i], r, vPaint);

      // Padrão
      if (isAnimal) {
        _drawAnimalBodyPattern(
            canvas, segs[i], r, mix, skin.id, skin.bodyColorDark);
      } else {
        _drawScalePattern(canvas, segs[i], r, mix, skin.bodyColorDark);
      }

      // Borda separação
      canvas.drawCircle(
          segs[i],
          r * 0.91,
          Paint()
            ..color = skin.bodyColorDark.withValues(alpha: 0.38)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.14);

      // Highlight 3D
      final sPaint = Paint()
        ..shader = ui.Gradient.radial(
          segs[i] + Offset(-r * 0.42, -r * 0.42),
          r * 0.75,
          [
            Colors.white.withValues(alpha: 0.52 * (1 - progress)),
            Colors.white.withValues(alpha: 0.0)
          ],
        );
      canvas.drawCircle(segs[i], r, sPaint);
    }

    // ── CABEÇA ─────────────────────────────────────────────────
    final Offset h = segs.last;
    final Offset hDir = segs.length >= 2
        ? (segs.last - segs[segs.length - 2])
        : const Offset(1, 0);
    final double headAngle = atan2(hDir.dy, hDir.dx);

    canvas.save();
    canvas.translate(h.dx, h.dy);
    canvas.rotate(headAngle);

    // Sombra
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(2, 2.5),
          width: headR * 2.4,
          height: headR * 2.0),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );

    // Glow de acento
    final glowR = ui.Gradient.radial(const Offset(0, 0), headR * 2.4,
        [skin.bodyColor.withValues(alpha: 0.22), skin.bodyColor.withValues(alpha: 0)]);
    canvas.drawCircle(Offset.zero, headR * 2.4, Paint()..shader = glowR);

    // Forma da cabeça
    final (hwMult, hhMult) = _headShapeForSkin(skin.id);
    final double hw = headR * hwMult;
    final double hh = headR * hhMult;

    final headGrad = Paint()
      ..shader = ui.Gradient.radial(
        Offset(-headR * 0.30, -headR * 0.40),
        hw * 0.9,
        [_lighten(skin.bodyColor, 0.40), skin.bodyColor, skin.bodyColorDark],
        [0.0, 0.50, 1.0],
      );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
      headGrad,
    );

    // Focinho + narinas (só cobra)
    if (!isAnimal) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hw * 0.36, 0), width: hh * 0.44, height: hh * 0.44),
        Paint()..color = _darken(skin.bodyColor, 0.14),
      );
      final nost = Paint()..color = skin.bodyColorDark.withValues(alpha: 0.80);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hw * 0.44, -hh * 0.13),
              width: headR * 0.14,
              height: headR * 0.09),
          nost);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(hw * 0.44, hh * 0.13),
              width: headR * 0.14,
              height: headR * 0.09),
          nost);
    }

    // Highlight
    final shimmer = Paint()
      ..shader = ui.Gradient.radial(
        Offset(-headR * 0.40, -headR * 0.50),
        hw * 0.62,
        [Colors.white.withValues(alpha: 0.52), Colors.white.withValues(alpha: 0.0)],
      );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
      shimmer,
    );

    // Expressão
    _drawExpression(canvas, headR, t, isAnimal);

    canvas.restore();
  }

  // ── Expressões preview ───────────────────────────────────────
  void _drawExpression(Canvas canvas, double r, double t, bool isAnimal) {
    if (isAnimal) {
      _drawAnimalExpression(canvas, r, t);
      return;
    }

    switch (skin.id) {
      case 'classic':
        _defaultEyes(canvas, r);
        _tonguePreview(canvas, r, t);
        break;
      case 'hot':
        _angryEyes(canvas, r);
        break;
      case 'sorriso':
        _happyEyes(canvas, r);
        _smilePreview(canvas, r);
        break;
      case 'veneno':
        _xEyes(canvas, r);
        break;
      case 'fantasma':
        _ghostEyes(canvas, r);
        break;
      case 'piranha':
        _piranhaExpression(canvas, r);
        break;
      case 'lava':
        _lavaExpression(canvas, r);
        break;
      case 'alien':
        _alienExpression(canvas, r, t);
        break;
      case 'lili':
        _liliExpression(canvas, r, t);
        break;
      case 'robo':
        _roboExpression(canvas, r, t);
        break;
      case 'serpente':
        _serpenteExpression(canvas, r, t);
        break;
      default:
        _defaultEyes(canvas, r);
    }
  }

  void _drawAnimalExpression(Canvas canvas, double r, double t) {
    switch (skin.id) {
      case 'gato':
        drawCatHead(canvas, r, t, skin.bodyColor, skin.bodyColorDark);
        break;
      case 'cachorro':
        drawDogHead(canvas, r, t, skin.bodyColor, skin.bodyColorDark);
        break;
      case 'leao':
        drawLionHead(canvas, r, t, skin.bodyColor, skin.bodyColorDark);
        break;
      case 'vaca':
        drawCowHead(canvas, r, t, skin.bodyColor, skin.bodyColorDark);
        break;
      case 'coelho':
        drawRabbitHead(canvas, r, t, skin.bodyColor, skin.bodyColorDark);
        break;
      case 'peixe':
        drawFishHead(canvas, r, t, skin.bodyColor, skin.bodyColorDark);
        break;
      case 'dragao_animal':
        drawDragonAnimalHead(canvas, r, t, skin.bodyColor, skin.bodyColorDark);
        break;
      case 'raposa':
        drawFoxHead(canvas, r, t, skin.bodyColor, skin.bodyColorDark);
        break;
    }
  }

  // ── Cauda preview (cobra) ─────────────────────────────────────
  void _drawSnakeTailPreview(Canvas canvas, Offset pos, double angle, double r,
      Color bodyColor, Color bodyColorDark) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final tailLen = r * 2.5;
    final path = Path()
      ..moveTo(0, -r * 0.80)
      ..cubicTo(r * 0.25, -r * 0.5, tailLen * 0.6, -r * 0.22, tailLen, 0)
      ..cubicTo(tailLen * 0.6, r * 0.22, r * 0.25, r * 0.5, 0, r * 0.80)
      ..close();

    final tailPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(tailLen, 0),
        [bodyColor, bodyColorDark, bodyColorDark.withValues(alpha: 0.0)],
        [0.0, 0.60, 1.0],
      );
    canvas.drawPath(path, tailPaint);

    // Escamas
    final sc = Paint()
      ..color = bodyColorDark.withValues(alpha: 0.30)
      ..strokeWidth = r * 0.10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i <= 3; i++) {
      final tx = tailLen * (i / 4.0);
      final tr = r * (1.0 - i * 0.20);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(tx, 0), radius: tr * 0.68),
        pi * 0.20,
        pi * 0.60,
        false,
        sc,
      );
    }
    canvas.restore();
  }

  // ── Body pattern helpers ─────────────────────────────────────
  void _drawScalePattern(
      Canvas canvas, Offset pos, double r, double mix, Color dark) {
    final sc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    sc.color = dark.withValues(alpha: 0.30);
    sc.strokeWidth = r * 0.12;
    canvas.drawArc(
      Rect.fromCircle(center: pos + Offset(0, r * 0.10), radius: r * 0.72),
      pi * 0.18,
      pi * 0.64,
      false,
      sc,
    );
    sc.color = dark.withValues(alpha: 0.16);
    sc.strokeWidth = r * 0.08;
    canvas.drawArc(
      Rect.fromCircle(center: pos + Offset(0, r * 0.04), radius: r * 0.44),
      pi * 0.22,
      pi * 0.56,
      false,
      sc,
    );
  }

  void _drawAnimalBodyPattern(
      Canvas canvas, Offset pos, double r, double mix, String id, Color dark) {
    switch (id) {
      case 'vaca':
        if ((pos.dx.toInt() + pos.dy.toInt()) % 4 == 0) {
          canvas.drawOval(
            Rect.fromCenter(
                center: pos + Offset(r * 0.15, -r * 0.10),
                width: r * 0.85,
                height: r * 0.65),
            Paint()..color = const Color(0xFF212121).withValues(alpha: 0.50),
          );
        }
        break;
      case 'peixe':
        final sp = Paint()
          ..color = Colors.white.withValues(alpha: 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.08;
        canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, r * 0.15), radius: r * 0.65),
          pi * 0.20,
          pi * 0.60,
          false,
          sp,
        );
        break;
      default:
        _drawScalePattern(canvas, pos, r, mix, dark);
    }
  }

  // ── Expressões preview clássicas ─────────────────────────────
  void _defaultEyes(Canvas canvas, double r) {
    for (final ey in [-r * 0.42, r * 0.42]) {
      canvas.drawCircle(
          Offset(r * 0.28, ey), r * 0.27, Paint()..color = Colors.white);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(r * 0.32, ey), width: r * 0.12, height: r * 0.24),
        Paint()..color = Colors.black,
      );
      canvas.drawCircle(Offset(r * 0.22, ey - r * 0.10), r * 0.08,
          Paint()..color = Colors.white.withValues(alpha: 0.80));
    }
  }

  void _tonguePreview(Canvas canvas, double r, double t) {
    final ext = sin(t * 4) * 0.5 + 0.5;
    final p = Paint()
      ..color = const Color(0xFFFF1744)
      ..strokeWidth = r * 0.13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final double len = r * (0.6 + ext * 0.5);
    canvas.drawLine(Offset(r, 0), Offset(r + len, 0), p);
    canvas.drawLine(Offset(r + len * 0.60, 0), Offset(r + len, -r * 0.28), p);
    canvas.drawLine(Offset(r + len * 0.60, 0), Offset(r + len, r * 0.28), p);
  }

  void _angryEyes(Canvas canvas, double r) {
    final brow = Paint()
      ..color = skin.bodyColorDark
      ..strokeWidth = r * 0.18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final s in [-1.0, 1.0]) {
      final ey = s * r * 0.42;
      canvas.drawLine(Offset(r * 0.10, ey - s * r * 0.20),
          Offset(r * 0.48, ey - s * r * 0.08), brow);
      canvas.drawCircle(
          Offset(r * 0.28, ey), r * 0.26, Paint()..color = Colors.white);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(r * 0.32, ey), width: r * 0.12, height: r * 0.24),
        Paint()..color = const Color(0xFFFF1744),
      );
    }
  }

  void _happyEyes(Canvas canvas, double r) {
    final ep = Paint()
      ..color = skin.bodyColorDark
      ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final ey in [-r * 0.44, r * 0.44]) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(r * 0.28, ey), width: r * 0.50, height: r * 0.44),
        pi,
        pi,
        false,
        ep,
      );
    }
  }

  void _smilePreview(Canvas canvas, double r) {
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(r * 0.32, r * 0.12), width: r * 1.0, height: r * 0.72),
      0.0,
      pi,
      false,
      Paint()
        ..color = skin.bodyColorDark
        ..strokeWidth = r * 0.12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _xEyes(Canvas canvas, double r) {
    final xp = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = r * 0.18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final ey in [-r * 0.42, r * 0.42]) {
      canvas.drawCircle(
          Offset(r * 0.28, ey), r * 0.26, Paint()..color = Colors.black);
      canvas.drawLine(
          Offset(r * 0.14, ey - r * 0.14), Offset(r * 0.42, ey + r * 0.14), xp);
      canvas.drawLine(
          Offset(r * 0.42, ey - r * 0.14), Offset(r * 0.14, ey + r * 0.14), xp);
    }
  }

  void _ghostEyes(Canvas canvas, double r) {
    for (final ey in [-r * 0.40, r * 0.40]) {
      canvas.drawCircle(
          Offset(r * 0.28, ey), r * 0.30, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(r * 0.20, ey - r * 0.10), r * 0.12,
          Paint()..color = const Color(0x99C8E6FF));
    }
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(r * 0.32, r * 0.40),
          width: r * 0.50,
          height: r * 0.38),
      Paint()..color = Colors.black,
    );
  }

  void _piranhaExpression(Canvas canvas, double r) {
    _angryEyes(canvas, r);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(r * 0.14, -r * 0.06),
          width: r * 1.55,
          height: r * 1.45),
      -0.25,
      pi + 0.5,
      true,
      Paint()..color = skin.bodyColorDark,
    );
    for (int i = 0; i < 3; i++) {
      final tx = r * (-0.36 + i * 0.26);
      canvas.drawPath(
          Path()
            ..moveTo(tx, -r * 0.04)
            ..lineTo(tx + r * 0.13, -r * 0.30)
            ..lineTo(tx + r * 0.26, -r * 0.04)
            ..close(),
          Paint()..color = Colors.white);
    }
  }

  void _lavaExpression(Canvas canvas, double r) {
    canvas.drawCircle(
        Offset(r * 0.30, 0), r * 0.34, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(r * 0.32, 0), r * 0.22,
        Paint()..color = const Color(0xFFFF3D00));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(r * 0.32, 0), width: r * 0.10, height: r * 0.24),
      Paint()..color = Colors.black,
    );
    canvas.drawLine(
        Offset(r * 0.08, -r * 0.30),
        Offset(r * 0.52, -r * 0.30),
        Paint()
          ..color = skin.bodyColorDark
          ..strokeWidth = r * 0.18
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  void _alienExpression(Canvas canvas, double r, double t) {
    final ring = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.9)
      ..strokeWidth = r * 0.14
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
        Offset(r * 0.20, -r * 0.36), r * 0.32, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r * 0.20, -r * 0.36), r * 0.32, ring);
    canvas.drawCircle(
        Offset(r * 0.22, r * 0.36), r * 0.20, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(r * 0.22, r * 0.36), r * 0.20, ring);
    final wobble = sin(t * 3) * r * 0.10;
    final ant = Paint()
      ..color = skin.accentColor
      ..strokeWidth = r * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -r * 0.95), Offset(wobble, -r * 1.52), ant);
    canvas.drawCircle(
        Offset(wobble, -r * 1.56), r * 0.13, Paint()..color = skin.accentColor);
  }

  void _liliExpression(Canvas canvas, double r, double t) {
    final bool blink = (t % (pi * 2)) > pi * 1.80;
    for (final ey in [-r * 0.42, r * 0.42]) {
      if (blink) {
        canvas.drawLine(
            Offset(r * 0.10, ey),
            Offset(r * 0.42, ey),
            Paint()
              ..color = skin.bodyColorDark
              ..strokeWidth = r * 0.20
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke);
      } else {
        canvas.drawCircle(
            Offset(r * 0.24, ey), r * 0.27, Paint()..color = Colors.white);
        canvas.drawCircle(
            Offset(r * 0.28, ey), r * 0.16, Paint()..color = Colors.black);
        canvas.drawCircle(Offset(r * 0.18, ey - r * 0.10), r * 0.08,
            Paint()..color = Colors.white);
      }
    }
    for (final s in [-1.0, 1.0]) {
      canvas.drawCircle(Offset(r * 0.60, s * r * 0.58), r * 0.18,
          Paint()..color = const Color(0x55FF5080));
    }
  }

  void _roboExpression(Canvas canvas, double r, double t) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-r * 0.04, -r * 0.62, r * 0.72, r * 1.15),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1A1A1A),
    );
    final bool blink = (t % (pi * 2)) > pi * 1.85;
    for (int i = 0; i < 2; i++) {
      final ey = i == 0 ? -r * 0.36 : r * 0.36;
      canvas.drawRect(
        Rect.fromLTWH(r * 0.08, ey - (blink ? r * 0.04 : r * 0.18), r * 0.34,
            blink ? r * 0.08 : r * 0.34),
        Paint()
          ..color = i == 0 ? const Color(0xFF00E5FF) : const Color(0xFFF44336),
      );
    }
  }

  void _serpenteExpression(Canvas canvas, double r, double t) {
    for (final ey in [-r * 0.36, r * 0.36]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(r * 0.14, ey), width: r * 0.50, height: r * 0.34),
        Paint()..color = const Color(0xFFFFEEEE),
      );
      canvas.drawCircle(Offset(r * 0.20, ey), r * 0.20,
          Paint()..color = const Color(0xFFCC0000));
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(r * 0.22, ey), width: r * 0.08, height: r * 0.18),
        Paint()..color = Colors.black,
      );
    }
    _tonguePreview(canvas, r, t);
  }

  // ── Forma da cabeça por skin ──────────────────────────────────
  (double, double) _headShapeForSkin(String id) {
    switch (id) {
      case 'gato':
        return (2.0, 2.2);
      case 'cachorro':
        return (2.2, 2.3);
      case 'leao':
        return (2.6, 2.5);
      case 'vaca':
        return (2.3, 2.4);
      case 'coelho':
        return (1.9, 2.4);
      case 'peixe':
        return (2.4, 1.8);
      case 'dragao_animal':
        return (2.6, 2.0);
      case 'raposa':
        return (2.5, 2.0);
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
      default:
        return (2.2, 1.9);
    }
  }

  // ── Utilitários ──────────────────────────────────────────────
  Color _lighten(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant SnakePreviewPainter old) =>
      old.t != t || old.skin.id != skin.id;
}
