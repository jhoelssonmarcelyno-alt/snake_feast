// lib/game/weather/weather_renderer.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'weather_types.dart';
import 'weather_particle.dart';

class WeatherRenderer {
  final Random _rng = Random();
  
  void render(Canvas canvas, WeatherType type, List<WeatherParticle> particles) {
    if (type == WeatherType.none || particles.isEmpty) return;

    final paint = Paint()..isAntiAlias = false;

    for (final p in particles) {
      if (p.alpha <= 0 || p.size <= 0) continue;

      switch (type) {
        case WeatherType.rain:
          paint.color = const Color(0xFFADD8E6).withOpacity(p.alpha);
          paint.strokeWidth = p.size;
          paint.strokeCap = StrokeCap.round;
          canvas.drawLine(
            Offset(p.x, p.y),
            Offset(p.x + p.vx * 0.04, p.y + p.vy * 0.04),
            paint,
          );
          break;

        case WeatherType.snow:
          paint.color = const Color(0xFFFFFFFF).withOpacity(p.alpha);
          canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
          break;

        case WeatherType.fog:
          final fogPaint = Paint()
            ..color = const Color(0xFFCCCCCC).withOpacity(p.alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
          canvas.drawCircle(Offset(p.x, p.y), p.size, fogPaint);
          break;

        case WeatherType.leaves:
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.rotate(p.angle);
          paint.color = const Color(0xFF7CB342).withOpacity(p.alpha);
          canvas.drawOval(
            Rect.fromCenter(
                center: Offset.zero, width: p.size, height: p.size * 0.5),
            paint,
          );
          canvas.restore();
          break;

        case WeatherType.embers:
          paint.color = const Color(0xFFFF6D00).withOpacity(p.alpha);
          canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
          final glow = Paint()
            ..color = const Color(0xFFFF9100).withOpacity(p.alpha * 0.4)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 2);
          canvas.drawCircle(Offset(p.x, p.y), p.size * 1.5, glow);
          break;

        case WeatherType.sand:
          paint.color = const Color(0xFFD4A017).withOpacity(p.alpha);
          canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
          break;

        case WeatherType.stars:
          paint.color = const Color(0xFFFFFFFF).withOpacity(p.alpha);
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.rotate(p.angle);
          for (int s = 0; s < 4; s++) {
            canvas.rotate(pi / 2);
            canvas.drawLine(
              Offset(0, 0),
              Offset(0, -p.size * 2),
              paint
                ..strokeWidth = p.size * 0.5
                ..strokeCap = StrokeCap.round,
            );
          }
          canvas.restore();
          break;

        case WeatherType.bubbles:
          paint
            ..color = const Color(0xFF80DEEA).withOpacity(p.alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;
          canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
          paint.style = PaintingStyle.fill;
          break;

        case WeatherType.sparks:
          paint.color = const Color(0xFFE040FB).withOpacity(p.alpha);
          paint.strokeWidth = p.size;
          paint.strokeCap = StrokeCap.round;
          canvas.drawLine(
            Offset(p.x, p.y),
            Offset(p.x + p.vx * 0.05, p.y + p.vy * 0.05),
            paint,
          );
          break;

        case WeatherType.petals:
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.rotate(p.angle);
          paint.color = const Color(0xFFFFB7C5).withOpacity(p.alpha);
          canvas.drawOval(
            Rect.fromCenter(
                center: Offset.zero, width: p.size * 0.6, height: p.size),
            paint,
          );
          canvas.restore();
          break;

        case WeatherType.crystals:
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.rotate(p.angle);
          paint.color = const Color(0xFF84FFFF).withOpacity(p.alpha);
          final path = Path()
            ..moveTo(0, -p.size)
            ..lineTo(p.size * 0.4, 0)
            ..lineTo(0, p.size)
            ..lineTo(-p.size * 0.4, 0)
            ..close();
          canvas.drawPath(path, paint);
          canvas.restore();
          break;

        case WeatherType.dust:
          paint.color = const Color(0xFFBCAAA4).withOpacity(p.alpha);
          canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
          break;

        case WeatherType.electricity:
          if (p.alpha <= 0) break;
          paint.color = const Color(0xFFFFFF00).withOpacity(p.alpha);
          paint.strokeWidth = 1.5;
          final ex = p.x + (_rng.nextDouble() - 0.5) * 30;
          final ey = p.y + (_rng.nextDouble() - 0.5) * 30;
          final path2 = Path()..moveTo(p.x, p.y);
          final steps = 4;
          for (int s = 1; s <= steps; s++) {
            final t = s / steps;
            path2.lineTo(
              lerpDouble(p.x, ex, t)! + (_rng.nextDouble() - 0.5) * 12,
              lerpDouble(p.y, ey, t)! + (_rng.nextDouble() - 0.5) * 12,
            );
          }
          canvas.drawPath(path2, paint..style = PaintingStyle.stroke);
          paint.style = PaintingStyle.fill;
          break;

        case WeatherType.divine:
          paint.color = const Color(0xFFFFF9C4).withOpacity(p.alpha);
          final glow2 = Paint()
            ..color = const Color(0xFFFFFFFF).withOpacity(p.alpha * 0.5)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 3);
          canvas.drawCircle(Offset(p.x, p.y), p.size * 2, glow2);
          canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
          break;

        case WeatherType.none:
          break;
      }
    }
  }
}
