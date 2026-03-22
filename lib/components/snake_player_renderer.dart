// lib/components/snake_player_renderer.dart
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart'
    show
        Colors,
        Color,
        TextPainter,
        HSVColor,
        RadialGradient,
        LinearGradient,
        Alignment;
import '../game/snake_engine.dart';
import 'snake_player_expressions.dart';
import 'animal_skins.dart';

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

mixin PlayerRenderer on PlayerExpressions {
  SnakeEngine get engine;
  List<Vector2> get segments;
  bool get isAlive;
  bool get isBoosting;
  double get headRadius;
  double get tongueTimer;
  Paint get bodyPaint;
  Paint get headPaint;
  Paint get shadowPaint;
  Paint get highlightPaint;
  Paint get boostGlowPaint;
  Paint get accentRingPaint;
  TextPainter get namePainter;

  final Paint _scalePaint = Paint()..style = PaintingStyle.stroke;
  final Paint _ventPaint = Paint();
  final Paint _shimmerPaint = Paint();
  final Paint _rimPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _patternPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _glowPaint = Paint();
  final Paint _tailPaint = Paint();

  void renderPlayer(Canvas canvas) {
    if (!isAlive || segments.isEmpty) return;
    final Vector2 cam = engine.cameraOffset;
    final double sw = engine.size.x;
    final double sh = engine.size.y;
    final double hr = headRadius;
    final bool isAnimal = _kAnimalSkinIds.contains(skinId);

    _renderTail(canvas, cam, sw, sh, hr, isAnimal);

    for (int i = segments.length - 1; i >= 1; i--) {
      final double sx = segments[i].x - cam.x;
      final double sy = segments[i].y - cam.y;
      if (sx < -30 || sx > sw + 30 || sy < -30 || sy > sh + 30) continue;
      final double t = 1.0 - (i / segments.length);
      final double r = _segmentRadius(i, hr);
      _drawSegment(canvas, Offset(sx, sy), r, t, i, isAnimal);
      if (isBoosting && i % 3 == 0) {
        _glowPaint.color = skinAccentColor.withValues(alpha: 0.28);
        canvas.drawCircle(Offset(sx, sy), r + 4, _glowPaint);
      }
    }

    final double hx = segments.first.x - cam.x;
    final double hy = segments.first.y - cam.y;
    if (hx > -hr * 3 && hx < sw + hr * 3 && hy > -hr * 3 && hy < sh + hr * 3) {
      _renderHead(canvas, Offset(hx, hy), hr, isAnimal);
      _renderName(canvas, Offset(hx, hy), hr);
    }
  }

  void _renderTail(Canvas canvas, Vector2 cam, double sw, double sh, double hr,
      bool isAnimal) {
    if (segments.length < 3) return;
    final last = segments.last;
    final prev = segments[segments.length - 2];
    final sx = last.x - cam.x;
    final sy = last.y - cam.y;
    if (sx < -60 || sx > sw + 60 || sy < -60 || sy > sh + 60) return;
    final dir = (last - prev);
    final angle = dir.length2 > 0 ? atan2(dir.y, dir.x) : 0.0;
    final tailR = _segmentRadius(segments.length - 1, hr);
    if (isAnimal) {
      renderAnimalTail(canvas, skinId, Offset(sx, sy), angle, tailR);
    } else {
      _drawSnakeTail(canvas, Offset(sx, sy), angle, tailR);
    }
  }

  void _drawSnakeTail(Canvas canvas, Offset pos, double angle, double r) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    final tailLen = r * 2.8;
    final path = Path()
      ..moveTo(0, -r * 0.82)
      ..cubicTo(r * 0.3, -r * 0.5, tailLen * 0.6, -r * 0.25, tailLen, 0)
      ..cubicTo(tailLen * 0.6, r * 0.25, r * 0.3, r * 0.5, 0, r * 0.82)
      ..close();
    _tailPaint.shader = LinearGradient(
      colors: [
        skinBodyColor,
        skinBodyColorDark,
        skinBodyColorDark.withValues(alpha: 0.0)
      ],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(Rect.fromLTWH(0, -r, tailLen, r * 2));
    canvas.drawPath(path, _tailPaint);
    _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.35);
    _scalePaint.strokeWidth = r * 0.10;
    for (int i = 1; i <= 3; i++) {
      final tx = tailLen * (i / 4.0);
      final tr = r * (1.0 - i * 0.22);
      canvas.drawArc(Rect.fromCircle(center: Offset(tx, 0), radius: tr * 0.7),
          pi * 0.2, pi * 0.6, false, _scalePaint);
    }
    _shimmerPaint.shader = RadialGradient(
      center: const Alignment(-0.5, -0.5),
      radius: 0.65,
      colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0.0)],
    ).createShader(Rect.fromLTWH(0, -r, tailLen * 0.6, r * 2));
    canvas.drawPath(path, _shimmerPaint);
    canvas.restore();
  }

  void _drawSegment(
      Canvas canvas, Offset pos, double r, double t, int idx, bool isAnimal) {
    bodyPaint.color = Colors.black.withValues(alpha: 0.26);
    canvas.drawCircle(pos + Offset(r * 0.16, r * 0.20), r * 0.92, bodyPaint);
    final Color base = Color.lerp(skinBodyColorDark, skinBodyColor, t)!;
    final Color ventral = _lighten(base, 0.38);
    _ventPaint.shader = RadialGradient(
      center: const Alignment(-0.30, -0.42),
      radius: 1.0,
      colors: [ventral, base, skinBodyColorDark],
      stops: const [0.0, 0.52, 1.0],
    ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, _ventPaint);
    if (!isAnimal) {
      _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.32);
      _scalePaint.strokeWidth = r * 0.12;
      _scalePaint.strokeCap = StrokeCap.round;
      canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, r * 0.10), radius: r * 0.72),
          pi * 0.18,
          pi * 0.64,
          false,
          _scalePaint);
      _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.18);
      _scalePaint.strokeWidth = r * 0.08;
      canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, r * 0.04), radius: r * 0.44),
          pi * 0.22,
          pi * 0.56,
          false,
          _scalePaint);
    } else {
      _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.28);
      _scalePaint.strokeWidth = r * 0.10;
      _scalePaint.strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: pos, radius: r * 0.68), pi * 0.18,
          pi * 0.64, false, _scalePaint);
      if (skinId == 'vaca' && (pos.dx.toInt() + pos.dy.toInt()) % 3 == 0) {
        canvas.drawOval(
          Rect.fromCenter(
              center: pos + Offset(r * 0.2, -r * 0.1),
              width: r * 0.9,
              height: r * 0.7),
          Paint()..color = const Color(0xFF212121).withValues(alpha: 0.55),
        );
      }
    }
    _rimPaint.color = skinBodyColorDark.withValues(alpha: 0.42);
    _rimPaint.strokeWidth = r * 0.14;
    canvas.drawCircle(pos, r * 0.91, _rimPaint);
    _shimmerPaint.shader = RadialGradient(
      center: const Alignment(-0.45, -0.45),
      radius: 0.65,
      colors: [
        Colors.white.withValues(alpha: 0.55 * t),
        Colors.white.withValues(alpha: 0.0)
      ],
    ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, _shimmerPaint);
    if (isBoosting && t > 0.6) {
      canvas.drawCircle(
          pos,
          r,
          Paint()
            ..color = skinAccentColor.withValues(alpha: 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.22);
    }
  }

  void _renderHead(Canvas canvas, Offset pos, double hr, bool isAnimal) {
    final Vector2 dir = segments.length >= 2
        ? (segments[0] - segments[1]).normalized()
        : Vector2(1, 0);
    final double angle = atan2(dir.y, dir.x);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // Sombra projetada
    bodyPaint.color = Colors.black.withValues(alpha: 0.30);
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(2, 3), width: hr * 2.4, height: hr * 2.0),
      bodyPaint,
    );

    // Glow de boost
    if (isBoosting) {
      _glowPaint.color = skinAccentColor.withValues(alpha: 0.40);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hr * 3.0, height: hr * 2.6),
        _glowPaint,
      );
    }

    final shape = headShape();
    final double hw = hr * shape.$1;
    final double hh = hr * shape.$2;

    if (isAnimal) {
      // ✅ Passo 1: orelhas/chifres/juba ATRÁS do oval
      renderAnimalBackLayer(
          canvas, skinId, hr, tongueTimer, skinBodyColor, skinBodyColorDark);

      // ✅ Passo 2: oval base com gradiente por cima das orelhas
      final headGrad = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.30, -0.40),
          radius: 1.0,
          colors: [
            _lighten(skinBodyColor, 0.42),
            skinBodyColor,
            skinBodyColorDark
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(
            Rect.fromCenter(center: Offset.zero, width: hw, height: hh));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
        headGrad,
      );

      // ✅ Passo 3: highlight
      _shimmerPaint.shader = RadialGradient(
        center: const Alignment(-0.40, -0.50),
        radius: 0.60,
        colors: [Colors.white.withValues(alpha: 0.48), Colors.white.withValues(alpha: 0.0)],
      ).createShader(
          Rect.fromCenter(center: Offset.zero, width: hw, height: hh));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
        _shimmerPaint,
      );

      // ✅ Passo 4: features (olhos, nariz, boca) NA FRENTE do oval
      renderExpression(canvas, hr, tongueTimer);
    } else {
      // Pipeline original para cobras normais
      final headGrad = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.30, -0.40),
          radius: 1.0,
          colors: [
            _lighten(skinBodyColor, 0.42),
            skinBodyColor,
            skinBodyColorDark
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(
            Rect.fromCenter(center: Offset.zero, width: hw, height: hh));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
        headGrad,
      );
      _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.22);
      _scalePaint.strokeWidth = hr * 0.10;
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset.zero, width: hw * 0.70, height: hh * 0.68),
        pi * 0.20,
        pi * 0.60,
        false,
        _scalePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hw * 0.36, 0), width: hh * 0.46, height: hh * 0.44),
        Paint()..color = _darken(skinBodyColor, 0.14),
      );
      final Paint nostril = Paint()
        ..color = skinBodyColorDark.withValues(alpha: 0.80);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hw * 0.44, -hh * 0.13),
            width: hr * 0.14,
            height: hr * 0.09),
        nostril,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hw * 0.44, hh * 0.13),
            width: hr * 0.14,
            height: hr * 0.09),
        nostril,
      );
      _shimmerPaint.shader = RadialGradient(
        center: const Alignment(-0.40, -0.50),
        radius: 0.60,
        colors: [Colors.white.withValues(alpha: 0.52), Colors.white.withValues(alpha: 0.0)],
      ).createShader(
          Rect.fromCenter(center: Offset.zero, width: hw, height: hh));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
        _shimmerPaint,
      );
      renderExpression(canvas, hr, tongueTimer);
    }

    canvas.restore();
  }

  void _renderName(Canvas canvas, Offset headPos, double hr) {
    namePainter.paint(canvas,
        Offset(headPos.dx - namePainter.width / 2, headPos.dy - hr - 22));
    if (engine.leader == this) {
      _drawCrown(canvas, Offset(headPos.dx, headPos.dy - hr - 30), hr);
    }
  }

  void _drawCrown(Canvas canvas, Offset pos, double hr) {
    final gold = Paint()..color = const Color(0xFFFFD600);
    final outline = Paint()
      ..color = const Color(0xFFAA8800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final double w = hr * 1.4, h = hr * 0.7;
    final double x = pos.dx - w / 2, y = pos.dy - h;
    final path = Path()
      ..moveTo(x, y + h)
      ..lineTo(x, y + h * 0.3)
      ..lineTo(x + w * 0.25, y + h * 0.65)
      ..lineTo(x + w * 0.5, y)
      ..lineTo(x + w * 0.75, y + h * 0.65)
      ..lineTo(x + w, y + h * 0.3)
      ..lineTo(x + w, y + h)
      ..close();
    canvas.drawPath(path, gold);
    canvas.drawPath(path, outline);
    for (final dx in [0.0, 0.5, 1.0]) {
      canvas.drawCircle(
        Offset(x + w * dx, dx == 0.5 ? y - hr * 0.05 : y + h * 0.3),
        hr * 0.12,
        Paint()..color = const Color(0xFFFF5252),
      );
    }
  }

  double _segmentRadius(int index, double hr) {
    final double taper = 1.0 - (index / segments.length) * 0.18;
    return (hr * taper).clamp(hr * 0.70, hr);
  }

  Color _lighten(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value - amount).clamp(0.0, 1.0)).toColor();
  }
}
