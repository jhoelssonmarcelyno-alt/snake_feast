// lib/components/snake_bot_renderer.dart
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart'
    show Colors, Color, TextPainter, HSVColor, RadialGradient, Alignment;
import '../game/snake_engine.dart';
import '../utils/constants.dart';

mixin BotRenderer {
  SnakeEngine get engine;
  List<Vector2> get segments;
  bool get isAlive;
  bool get isBoosting;
  double get headRadius;
  TextPainter get namePainter;
  Color get bodyColor;
  Color get bodyColorDark;

  Paint get botBodyPaint;
  Paint get botShadowPaint;
  Paint get botHighlightPaint;
  Paint get botEyeWhite;
  Paint get botEyePupil;
  Paint get botBoostGlowPaint;
  Paint get botHeadPaint;

  final Paint _bScalePaint = Paint()..style = PaintingStyle.stroke;
  final Paint _bVentPaint = Paint();
  final Paint _bShimmerPaint = Paint();
  final Paint _bRimPaint = Paint()..style = PaintingStyle.stroke;

  void renderBot(Canvas canvas) {
    if (!isAlive || segments.isEmpty) return;

    final Vector2 cam = engine.cameraOffset;
    final double sw = engine.size.x;
    final double sh = engine.size.y;
    final double hr = headRadius;

    final double hx0 = segments.first.x - cam.x;
    final double hy0 = segments.first.y - cam.y;
    final double maxE = segments.length * kBotSegmentSpacing + hr;
    if (hx0 < -(maxE) || hx0 > sw + maxE || hy0 < -(maxE) || hy0 > sh + maxE) {
      return;
    }

    for (int i = segments.length - 1; i >= 1; i--) {
      final double sx = segments[i].x - cam.x;
      final double sy = segments[i].y - cam.y;
      // Culling dinâmico: margem = raio real do segmento + folga mínima
      final double r = _segRadius(i, hr);
      final double margin = r + 2;
      if (sx < -margin || sx > sw + margin || sy < -margin || sy > sh + margin)
        continue;

      final double t = 1.0 - (i / segments.length);

      _drawSegment(canvas, Offset(sx, sy), r, t);

      if (isBoosting && i % 4 == 0) {
        canvas.drawCircle(Offset(sx, sy), r + 3, botBoostGlowPaint);
      }
    }

    final double hx = segments.first.x - cam.x;
    final double hy = segments.first.y - cam.y;
    // Margem da cabeça proporcional ao headRadius para evitar pop-in do oval
    final double headMargin = hr * 2;
    if (hx > -headMargin &&
        hx < sw + headMargin &&
        hy > -headMargin &&
        hy < sh + headMargin) {
      renderHead(canvas, Offset(hx, hy), hr);
      renderName(canvas, Offset(hx, hy), hr);
    }
  }

  void _drawSegment(Canvas canvas, Offset pos, double r, double t) {
    // Sombra
    botBodyPaint.color = Colors.black.withValues(alpha: 0.28);
    canvas.drawCircle(pos + Offset(r * 0.18, r * 0.22), r * 0.9, botBodyPaint);

    // Ventre com gradiente
    final Color base = Color.lerp(bodyColorDark, bodyColor, t)!;
    final Color ventral = _bLighten(base, 0.32);
    _bVentPaint.shader = RadialGradient(
      center: Alignment(-0.3, -0.4),
      radius: 1.0,
      colors: [ventral, base, bodyColorDark],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, _bVentPaint);

    // Escamas
    _bScalePaint.color = bodyColorDark.withValues(alpha: 0.28);
    _bScalePaint.strokeWidth = r * 0.13;
    _bScalePaint.strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: pos + Offset(0, r * 0.1), radius: r * 0.72),
      pi * 0.15,
      pi * 0.7,
      false,
      _bScalePaint,
    );
    _bScalePaint.color = bodyColorDark.withValues(alpha: 0.14);
    _bScalePaint.strokeWidth = r * 0.08;
    canvas.drawArc(
      Rect.fromCircle(center: pos + Offset(0, r * 0.05), radius: r * 0.43),
      pi * 0.2,
      pi * 0.6,
      false,
      _bScalePaint,
    );

    // Borda separação
    _bRimPaint.color = bodyColorDark.withValues(alpha: 0.42);
    _bRimPaint.strokeWidth = r * 0.16;
    canvas.drawCircle(pos, r * 0.90, _bRimPaint);

    // Highlight 3D
    _bShimmerPaint.shader = RadialGradient(
      center: Alignment(-0.45, -0.45),
      radius: 0.65,
      colors: [
        Colors.white.withValues(alpha: 0.50 * t),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, _bShimmerPaint);
  }

  void renderHead(Canvas canvas, Offset pos, double hr) {
    final Vector2 dir = segments.length >= 2
        ? (segments[0] - segments[1]).normalized()
        : Vector2(1, 0);
    final double angle = atan2(dir.y, dir.x);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // Sombra
    botBodyPaint.color = Colors.black.withValues(alpha: 0.28);
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(2, 3), width: hr * 2.3, height: hr * 1.9),
      botBodyPaint,
    );

    if (isBoosting) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hr * 2.7, height: hr * 2.3),
        botBoostGlowPaint,
      );
    }

    // Cabeça com gradiente 3D
    final Paint hGrad = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: [_bLighten(bodyColor, 0.38), bodyColor, bodyColorDark],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCenter(
          center: Offset.zero, width: hr * 2.3, height: hr * 1.9));
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: hr * 2.3, height: hr * 1.9),
      hGrad,
    );

    // Escama na cabeça
    _bScalePaint.color = bodyColorDark.withValues(alpha: 0.18);
    _bScalePaint.strokeWidth = hr * 0.09;
    canvas.drawArc(
      Rect.fromCenter(center: Offset.zero, width: hr * 1.5, height: hr * 1.1),
      pi * 0.2,
      pi * 0.6,
      false,
      _bScalePaint,
    );

    // Focinho
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(hr * 0.72, 0), width: hr * 0.82, height: hr * 0.82),
      Paint()..color = _bDarken(bodyColor, 0.12),
    );

    // Narinas
    final Paint nostril = Paint()
      ..color = bodyColorDark.withValues(alpha: 0.75);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.93, -hr * 0.21),
            width: hr * 0.13,
            height: hr * 0.09),
        nostril);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hr * 0.93, hr * 0.21),
            width: hr * 0.13,
            height: hr * 0.09),
        nostril);

    // Olhos realistas
    _drawBotEye(canvas, Offset(hr * 0.08, -hr * 0.50), hr * 0.30);
    _drawBotEye(canvas, Offset(hr * 0.08, hr * 0.50), hr * 0.30);

    // Highlight cabeça
    _bShimmerPaint.shader = RadialGradient(
      center: Alignment(-0.4, -0.5),
      radius: 0.6,
      colors: [
        Colors.white.withValues(alpha: 0.45),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCenter(
        center: Offset.zero, width: hr * 2.3, height: hr * 1.9));
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: hr * 2.3, height: hr * 1.9),
      _bShimmerPaint,
    );

    canvas.restore();
  }

  void _drawBotEye(Canvas canvas, Offset pos, double r) {
    canvas.drawCircle(pos, r, Paint()..color = Colors.white);
    final Color irisColor = _bComplementColor(bodyColor);
    canvas.drawCircle(pos, r * 0.70, Paint()..color = irisColor);
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: r * 0.26, height: r * 0.62),
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(pos + Offset(-r * 0.26, -r * 0.26), r * 0.20,
        Paint()..color = Colors.white.withValues(alpha: 0.88));
    canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.12);
  }

  // Mantido por compatibilidade com BotAccessoryRenderer
  void renderEyes(Canvas canvas, Offset pos, double hr) {
    _drawBotEye(
        canvas, Offset(pos.dx + hr * 0.10, pos.dy - hr * 0.50), hr * 0.30);
    _drawBotEye(
        canvas, Offset(pos.dx + hr * 0.10, pos.dy + hr * 0.50), hr * 0.30);
  }

  void renderName(Canvas canvas, Offset headPos, double hr) {
    final double nx = headPos.dx - namePainter.width / 2;
    final double ny = headPos.dy - hr - 18;
    namePainter.paint(canvas, Offset(nx, ny));
    if (engine.leader == this) {
      _drawBotCrown(canvas, Offset(headPos.dx, headPos.dy - hr - 26), hr);
    }
  }

  void _drawBotCrown(Canvas canvas, Offset pos, double hr) {
    final gold = Paint()..color = const Color(0xFFFFD600);
    final outline = Paint()
      ..color = const Color(0xFFAA8800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final double w = hr * 1.4, hh = hr * 0.7;
    final double x = pos.dx - w / 2, y = pos.dy - hh;
    final path = Path()
      ..moveTo(x, y + hh)
      ..lineTo(x, y + hh * 0.3)
      ..lineTo(x + w * 0.25, y + hh * 0.65)
      ..lineTo(x + w * 0.5, y)
      ..lineTo(x + w * 0.75, y + hh * 0.65)
      ..lineTo(x + w, y + hh * 0.3)
      ..lineTo(x + w, y + hh)
      ..close();
    canvas.drawPath(path, gold);
    canvas.drawPath(path, outline);
    for (final dx in [0.0, 0.5, 1.0]) {
      canvas.drawCircle(
          Offset(x + w * dx, dx == 0.5 ? y - hr * 0.05 : y + hh * 0.3),
          hr * 0.12,
          Paint()..color = const Color(0xFFFF5252));
    }
  }

  double _segRadius(int index, double hr) {
    final double taper = 1.0 - (index / segments.length) * 0.06;
    return (hr * taper).clamp(hr * 0.88, hr);
  }

  Color _bLighten(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _bDarken(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value - amount).clamp(0.0, 1.0)).toColor();
  }

  Color _bComplementColor(Color c) {
    final hsv = HSVColor.fromColor(c);
    return HSVColor.fromAHSV(1.0, (hsv.hue + 30) % 360, 0.7, 0.85).toColor();
  }
}
