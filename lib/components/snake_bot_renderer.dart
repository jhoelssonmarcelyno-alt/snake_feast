// lib/components/snake_bot_renderer.dart
// Mixin com render do corpo, cabeça, nome e coroa do bot.
// Usa nomes públicos para os Paints (campos privados _ não cruzam arquivos em Dart).
import 'dart:math' show pi, cos, sin;
import 'dart:ui';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart'
    show Colors, Color, TextPainter;
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

  // Nomes públicos — sem underscore para cruzar arquivos
  Paint get botBodyPaint;
  Paint get botShadowPaint;
  Paint get botHighlightPaint;
  Paint get botEyeWhite;
  Paint get botEyePupil;
  Paint get botBoostGlowPaint;
  Paint get botHeadPaint;

  void renderBot(Canvas canvas) {
    if (!isAlive || segments.isEmpty) return;

    final Vector2 cam = engine.cameraOffset;
    final double sw = engine.size.x;
    final double sh = engine.size.y;
    final double hr = headRadius;

    final double hx0 = segments.first.x - cam.x;
    final double hy0 = segments.first.y - cam.y;
    final double maxExtent = segments.length * kBotSegmentSpacing;
    if (hx0 < -(maxExtent + hr) ||
        hx0 > sw + maxExtent + hr ||
        hy0 < -(maxExtent + hr) ||
        hy0 > sh + maxExtent + hr) return;

    for (int i = segments.length - 1; i >= 1; i--) {
      final double sx = segments[i].x - cam.x;
      final double sy = segments[i].y - cam.y;
      if (sx < -20 || sx > sw + 20 || sy < -20 || sy > sh + 20) continue;
      final double t = 1.0 - (i / segments.length);
      final double r = _segmentRadius(i, hr);

      botBodyPaint.color = bodyColorDark.withOpacity(0.45);
      canvas.drawCircle(Offset(sx + 1.5, sy + 1.5), r, botBodyPaint);
      botBodyPaint.color = Color.lerp(bodyColorDark, bodyColor, t)!;
      canvas.drawCircle(Offset(sx, sy), r, botBodyPaint);
      botHighlightPaint.color = Colors.white.withOpacity(0.18 * t);
      canvas.drawCircle(
          Offset(sx - r * 0.28, sy - r * 0.28), r * 0.42, botHighlightPaint);
      if (isBoosting && i % 3 == 0)
        canvas.drawCircle(Offset(sx, sy), r + 2, botBoostGlowPaint);
    }

    final double hx = segments.first.x - cam.x;
    final double hy = segments.first.y - cam.y;
    if (hx > -hr && hx < sw + hr && hy > -hr && hy < sh + hr) {
      renderHead(canvas, Offset(hx, hy), hr);
      renderName(canvas, Offset(hx, hy), hr);
    }
  }

  void renderHead(Canvas canvas, Offset pos, double hr);

  void renderEyes(Canvas canvas, Offset pos, double hr) {
    for (final ey in [pos.dy - hr * 0.38, pos.dy + hr * 0.38]) {
      canvas.drawCircle(Offset(pos.dx + hr * 0.22, ey), hr * 0.26, botEyeWhite);
      canvas.drawCircle(Offset(pos.dx + hr * 0.26, ey), hr * 0.15, botEyePupil);
    }
  }

  void renderName(Canvas canvas, Offset headPos, double hr) {
    final double nx = headPos.dx - namePainter.width / 2;
    final double ny = headPos.dy - hr - 18;
    namePainter.paint(canvas, Offset(nx, ny));
    if (engine.leader == this) {
      _drawCrown(canvas, Offset(headPos.dx, headPos.dy - hr - 26), hr);
    }
  }

  void _drawCrown(Canvas canvas, Offset pos, double hr) {
    final gold = Paint()..color = const Color(0xFFFFD600);
    final outline = Paint()
      ..color = const Color(0xFFAA8800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final double w = hr * 1.4;
    final double hh = hr * 0.7;
    final double x = pos.dx - w / 2;
    final double y = pos.dy - hh;
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

  double _segmentRadius(int index, double hr) {
    final double taper = 1.0 - (index / segments.length) * 0.04;
    return (hr * taper).clamp(hr * 0.94, hr);
  }
}
