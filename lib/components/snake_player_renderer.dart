// lib/components/snake_player_renderer.dart
// Mixin com render do corpo, cabeça, nome e coroa do player.
import 'dart:math' show atan2;
import 'dart:ui';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart'
    show Colors, Color, TextPainter;
import '../game/snake_engine.dart';
import '../utils/constants.dart';
import 'snake_player_expressions.dart';

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

  void renderPlayer(Canvas canvas) {
    if (!isAlive || segments.isEmpty) return;

    final Vector2 cam = engine.cameraOffset;
    final double sw = engine.size.x;
    final double sh = engine.size.y;
    final double hr = headRadius;

    for (int i = segments.length - 1; i >= 1; i--) {
      final double sx = segments[i].x - cam.x;
      final double sy = segments[i].y - cam.y;
      if (sx < -20 || sx > sw + 20 || sy < -20 || sy > sh + 20) continue;
      final double t = 1.0 - (i / segments.length);
      final double r = _segmentRadius(i, hr);

      bodyPaint.color = skinBodyColorDark.withOpacity(0.5);
      canvas.drawCircle(Offset(sx + 1.5, sy + 1.5), r, bodyPaint);

      bodyPaint.color = Color.lerp(skinBodyColorDark, skinBodyColor, t)!;
      canvas.drawCircle(Offset(sx, sy), r, bodyPaint);

      highlightPaint.color = Colors.white.withOpacity(0.18 * t);
      canvas.drawCircle(
          Offset(sx - r * 0.28, sy - r * 0.28), r * 0.42, highlightPaint);

      if (isBoosting && i % 3 == 0) {
        canvas.drawCircle(Offset(sx, sy), r + 2, boostGlowPaint);
      }
    }

    final double hx = segments.first.x - cam.x;
    final double hy = segments.first.y - cam.y;
    if (hx > -hr && hx < sw + hr && hy > -hr && hy < sh + hr) {
      _renderHead(canvas, Offset(hx, hy), hr);
      _renderName(canvas, Offset(hx, hy), hr);
    }
  }

  void _renderHead(Canvas canvas, Offset pos, double hr) {
    final Vector2 dir = segments.length >= 2
        ? (segments[0] - segments[1])
        : Vector2(1, 0);
    final double angle = atan2(dir.y, dir.x);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    canvas.drawCircle(const Offset(2, 3), hr, shadowPaint);
    if (isBoosting) canvas.drawCircle(Offset.zero, hr + 4, boostGlowPaint);

    headPaint.color = skinBodyColor;
    canvas.drawCircle(Offset.zero, hr, headPaint);
    canvas.drawCircle(Offset.zero, hr, accentRingPaint);

    renderExpression(canvas, hr, tongueTimer); // PlayerExpressions

    canvas.drawCircle(
        Offset(-hr * 0.25, -hr * 0.25), hr * 0.32, highlightPaint);
    canvas.restore();
  }

  void _renderName(Canvas canvas, Offset headPos, double hr) {
    namePainter.paint(canvas,
        Offset(headPos.dx - namePainter.width / 2, headPos.dy - hr - 20));
    if (engine.leader == this) {
      _drawCrown(canvas, Offset(headPos.dx, headPos.dy - hr - 28), hr);
    }
  }

  void _drawCrown(Canvas canvas, Offset pos, double hr) {
    final Paint gold = Paint()..color = const Color(0xFFFFD600);
    final Paint outline = Paint()
      ..color = const Color(0xFFAA8800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final double w = hr * 1.4;
    final double h = hr * 0.7;
    final double x = pos.dx - w / 2;
    final double y = pos.dy - h;
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
    final double taper = 1.0 - (index / segments.length) * 0.04;
    return (hr * taper).clamp(hr * 0.94, hr);
  }
}
