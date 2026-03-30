// lib/game/engine_zone_effects.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'weather/weather_types.dart';
import 'snake_engine.dart';

class ZoneEffect {
  final String name;
  final Color color;
  final Color edgeColor;
  final double pulseSpeed;
  final double particleDensity;
  final void Function(Canvas, Offset, double, double) renderEffect;

  const ZoneEffect({
    required this.name,
    required this.color,
    required this.edgeColor,
    this.pulseSpeed = 4.0,
    this.particleDensity = 1.0,
    required this.renderEffect,
  });
}

class ZoneEffectManager {
  static final Map<WeatherType, ZoneEffect> _effects = {};
  static final Random _rng = Random();
  static List<_ZoneParticle> _particles = [];

  static void init() {
    _registerEffects();
  }

  static void _registerEffects() {
    // ── LAVA / FOGO ─────────────────────────────────────────────
    _effects[WeatherType.embers] = ZoneEffect(
      name: 'Lava',
      color: const Color(0xAAFF4500),
      edgeColor: const Color(0xFFFF6600),
      pulseSpeed: 5.0,
      particleDensity: 2.0,
      renderEffect: (canvas, center, radius, progress) {
        // Ondas de calor
        final heatWave = Paint()
          ..color = const Color(0x44FF6600)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
        canvas.drawCircle(center, radius + 10, heatWave);

        // Bordas em chamas
        for (int i = 0; i < 8; i++) {
          final angle = i * pi * 2 / 8 + _rng.nextDouble() * 0.5;
          final x = center.dx + cos(angle) * radius;
          final y = center.dy + sin(angle) * radius;

          final flame = Paint()
            ..color = const Color(0xFFFF8800)
                .withOpacity(0.6 + _rng.nextDouble() * 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawCircle(Offset(x, y), 12 + _rng.nextDouble() * 8, flame);
        }
      },
    );

    // ── GELO CONGELANTE ─────────────────────────────────────────
    _effects[WeatherType.snow] = ZoneEffect(
      name: 'Gelo Congelante',
      color: const Color(0xAA88CCFF),
      edgeColor: const Color(0xFFAAEEFF),
      pulseSpeed: 2.0,
      particleDensity: 1.5,
      renderEffect: (canvas, center, radius, progress) {
        // Cristais de gelo
        final icePaint = Paint()
          ..color = const Color(0x88CCFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        for (int i = 0; i < 12; i++) {
          final angle = i * pi * 2 / 12 + _rng.nextDouble() * 0.3;
          final x = center.dx + cos(angle) * radius;
          final y = center.dy + sin(angle) * radius;

          // Desenha cristais
          final path = Path()
            ..moveTo(x, y - 8)
            ..lineTo(x + 4, y)
            ..lineTo(x, y + 8)
            ..lineTo(x - 4, y)
            ..close();
          canvas.drawPath(path, icePaint);
        }

        // Brilho congelante
        final frost = Paint()
          ..color = const Color(0x44AAFFFF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        canvas.drawCircle(center, radius + 5, frost);
      },
    );

    // ── NEBLINA / FUMAÇA ────────────────────────────────────────
    _effects[WeatherType.fog] = ZoneEffect(
      name: 'Neblina Sombria',
      color: const Color(0xAA666666),
      edgeColor: const Color(0xFFAAAAAA),
      pulseSpeed: 1.5,
      particleDensity: 3.0,
      renderEffect: (canvas, center, radius, progress) {
        // Névoa rodopiante
        for (int i = 0; i < 20; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final dist = _rng.nextDouble() * radius;
          final x = center.dx + cos(angle) * dist;
          final y = center.dy + sin(angle) * dist;

          final fogPaint = Paint()
            ..color = const Color(0x44AAAAAA)
            ..maskFilter =
                MaskFilter.blur(BlurStyle.normal, 30 + _rng.nextDouble() * 20);
          canvas.drawCircle(
              Offset(x, y), 40 + _rng.nextDouble() * 30, fogPaint);
        }
      },
    );

    // ── VENTO / TORNADO ─────────────────────────────────────────
    _effects[WeatherType.dust] = ZoneEffect(
      name: 'Vento Cortante',
      color: const Color(0x88D4A017),
      edgeColor: const Color(0xFFF5B041),
      pulseSpeed: 6.0,
      particleDensity: 2.5,
      renderEffect: (canvas, center, radius, progress) {
        // Linhas de vento
        final windPaint = Paint()
          ..color = const Color(0x88D4A017)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < 24; i++) {
          final angle = i * pi * 2 / 24;
          final startX = center.dx + cos(angle) * radius * 0.8;
          final startY = center.dy + sin(angle) * radius * 0.8;
          final endX = center.dx + cos(angle + 0.3) * radius;
          final endY = center.dy + sin(angle + 0.3) * radius;

          canvas.drawLine(
              Offset(startX, startY), Offset(endX, endY), windPaint);
        }
      },
    );

    // ── RAIOS / ELETRICIDADE ────────────────────────────────────
    _effects[WeatherType.electricity] = ZoneEffect(
      name: 'Tempestade Elétrica',
      color: const Color(0xAAFFFF00),
      edgeColor: const Color(0xFFFFFF00),
      pulseSpeed: 8.0,
      particleDensity: 2.0,
      renderEffect: (canvas, center, radius, progress) {
        // Raios ziguezague
        final lightningPaint = Paint()
          ..color = const Color(0xFFFFFF00)
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < 6; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final startX = center.dx + cos(angle) * radius;
          final startY = center.dy + sin(angle) * radius;

          var currentX = startX;
          var currentY = startY;
          final path = Path()..moveTo(currentX, currentY);

          for (int step = 0; step < 8; step++) {
            currentX += (_rng.nextDouble() - 0.5) * 20;
            currentY += (_rng.nextDouble() - 0.5) * 20;
            path.lineTo(currentX, currentY);
          }
          canvas.drawPath(path, lightningPaint);
        }
      },
    );

    // ── CHUVA / ÁGUA ────────────────────────────────────────────
    _effects[WeatherType.rain] = ZoneEffect(
      name: 'Chuva Torrencial',
      color: const Color(0xAA3399FF),
      edgeColor: const Color(0xFF66CCFF),
      pulseSpeed: 3.0,
      particleDensity: 2.0,
      renderEffect: (canvas, center, radius, progress) {
        // Gotas de chuva
        final rainPaint = Paint()
          ..color = const Color(0xCC3399FF)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        for (int i = 0; i < 60; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final dist = _rng.nextDouble() * radius;
          final x = center.dx + cos(angle) * dist;
          final y = center.dy + sin(angle) * dist;

          canvas.drawLine(
            Offset(x, y),
            Offset(x + _rng.nextDouble() * 8 - 4, y + _rng.nextDouble() * 12),
            rainPaint,
          );
        }
      },
    );

    // ── FOLHAS / NATUREZA ───────────────────────────────────────
    _effects[WeatherType.leaves] = ZoneEffect(
      name: 'Floresta Selvagem',
      color: const Color(0xAA4CAF50),
      edgeColor: const Color(0xFF8BC34A),
      pulseSpeed: 2.5,
      particleDensity: 1.5,
      renderEffect: (canvas, center, radius, progress) {
        // Vinhas e folhas
        final vinePaint = Paint()
          ..color = const Color(0xCC4CAF50)
          ..strokeWidth = 3.0;

        for (int i = 0; i < 16; i++) {
          final angle = i * pi * 2 / 16;
          final startX = center.dx + cos(angle) * radius;
          final startY = center.dy + sin(angle) * radius;
          final endX = center.dx + cos(angle + 0.5) * (radius + 20);
          final endY = center.dy + sin(angle + 0.5) * (radius + 20);

          canvas.drawLine(
              Offset(startX, startY), Offset(endX, endY), vinePaint);
        }
      },
    );

    // ── AREIA / TEMPESTADE ──────────────────────────────────────
    _effects[WeatherType.sand] = ZoneEffect(
      name: 'Tempestade de Areia',
      color: const Color(0xAAD4A017),
      edgeColor: const Color(0xFFF5B041),
      pulseSpeed: 4.0,
      particleDensity: 3.0,
      renderEffect: (canvas, center, radius, progress) {
        // Partículas de areia
        final sandPaint = Paint()
          ..color = const Color(0xCCD4A017)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        for (int i = 0; i < 80; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final dist = _rng.nextDouble() * radius;
          final x = center.dx + cos(angle) * dist;
          final y = center.dy + sin(angle) * dist;

          canvas.drawCircle(Offset(x, y), 2 + _rng.nextDouble() * 3, sandPaint);
        }
      },
    );

    // ── ESTRELAS / CÓSMICO ──────────────────────────────────────
    _effects[WeatherType.stars] = ZoneEffect(
      name: 'Vórtice Cósmico',
      color: const Color(0xAAFFFFFF),
      edgeColor: const Color(0xFFCCCCFF),
      pulseSpeed: 5.0,
      particleDensity: 2.0,
      renderEffect: (canvas, center, radius, progress) {
        // Espiral galáctica
        final starPaint = Paint()
          ..color = const Color(0xCCFFFFFF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

        for (int i = 0; i < 3; i++) {
          final startAngle = i * pi * 2 / 3;
          for (double t = 0; t <= 1; t += 0.05) {
            final angle = startAngle + t * pi * 4;
            final r = radius * t;
            final x = center.dx + cos(angle) * r;
            final y = center.dy + sin(angle) * r;
            canvas.drawCircle(Offset(x, y), 3, starPaint);
          }
        }
      },
    );

    // ── BOLHAS / SUBMARINO ──────────────────────────────────────
    _effects[WeatherType.bubbles] = ZoneEffect(
      name: 'Abismo Submarino',
      color: const Color(0xAA3399FF),
      edgeColor: const Color(0xFF66CCFF),
      pulseSpeed: 2.0,
      particleDensity: 2.5,
      renderEffect: (canvas, center, radius, progress) {
        // Bolhas ascendentes
        final bubblePaint = Paint()
          ..color = const Color(0xCC66CCFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        for (int i = 0; i < 30; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final dist = _rng.nextDouble() * radius;
          final x = center.dx + cos(angle) * dist;
          final y = center.dy + sin(angle) * dist;
          final size = 3 + _rng.nextDouble() * 8;

          canvas.drawCircle(Offset(x, y), size, bubblePaint);
          if (_rng.nextDouble() > 0.7) {
            canvas.drawCircle(Offset(x, y), size * 0.6,
                bubblePaint..style = PaintingStyle.fill);
          }
        }
      },
    );

    // ── FAÍSCAS / NEON ──────────────────────────────────────────
    _effects[WeatherType.sparks] = ZoneEffect(
      name: 'Campo de Faíscas',
      color: const Color(0xAAFF44FF),
      edgeColor: const Color(0xFFFF88FF),
      pulseSpeed: 7.0,
      particleDensity: 2.5,
      renderEffect: (canvas, center, radius, progress) {
        // Faíscas neon
        final sparkPaint = Paint()
          ..color = const Color(0xFFFF44FF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        for (int i = 0; i < 50; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final dist = _rng.nextDouble() * radius;
          final x = center.dx + cos(angle) * dist;
          final y = center.dy + sin(angle) * dist;

          canvas.drawCircle(
              Offset(x, y), 2 + _rng.nextDouble() * 4, sparkPaint);
        }
      },
    );

    // ── PÉTALAS / SONHO ─────────────────────────────────────────
    _effects[WeatherType.petals] = ZoneEffect(
      name: 'Névoa dos Sonhos',
      color: const Color(0xAAFFB7C5),
      edgeColor: const Color(0xFFFFD1DC),
      pulseSpeed: 3.0,
      particleDensity: 1.8,
      renderEffect: (canvas, center, radius, progress) {
        // Pétalas flutuantes
        final petalPaint = Paint()
          ..color = const Color(0xCCFFB7C5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        for (int i = 0; i < 25; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final dist = _rng.nextDouble() * radius;
          final x = center.dx + cos(angle) * dist;
          final y = center.dy + sin(angle) * dist;

          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: 6, height: 10),
            petalPaint,
          );
        }
      },
    );

    // ── CRISTAIS / MÁGICO ───────────────────────────────────────
    _effects[WeatherType.crystals] = ZoneEffect(
      name: 'Campo de Cristais',
      color: const Color(0xAA84FFFF),
      edgeColor: const Color(0xFFAAFFFF),
      pulseSpeed: 4.0,
      particleDensity: 1.5,
      renderEffect: (canvas, center, radius, progress) {
        // Cristais brilhantes
        final crystalPaint = Paint()
          ..color = const Color(0xCC84FFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        for (int i = 0; i < 24; i++) {
          final angle = i * pi * 2 / 24;
          final x = center.dx + cos(angle) * radius;
          final y = center.dy + sin(angle) * radius;

          final path = Path()
            ..moveTo(x, y - 8)
            ..lineTo(x + 5, y)
            ..lineTo(x, y + 8)
            ..lineTo(x - 5, y)
            ..close();
          canvas.drawPath(path, crystalPaint);
        }
      },
    );

    // ── LUZ DIVINA / CELESTIAL ──────────────────────────────────
    _effects[WeatherType.divine] = ZoneEffect(
      name: 'Luz Divina',
      color: const Color(0xAAFFF9C4),
      edgeColor: const Color(0xFFFFFFE0),
      pulseSpeed: 3.0,
      particleDensity: 2.0,
      renderEffect: (canvas, center, radius, progress) {
        // Raios de luz
        final lightPaint = Paint()
          ..color = const Color(0x44FFFFAA)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

        for (int i = 0; i < 12; i++) {
          final angle = i * pi * 2 / 12;
          final startX = center.dx + cos(angle) * radius * 0.5;
          final startY = center.dy + sin(angle) * radius * 0.5;
          final endX = center.dx + cos(angle) * (radius + 40);
          final endY = center.dy + sin(angle) * (radius + 40);

          canvas.drawLine(
              Offset(startX, startY), Offset(endX, endY), lightPaint);
        }

        // Glória
        final gloryPaint = Paint()
          ..color = const Color(0x44FFFFCC)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
        canvas.drawCircle(center, radius + 15, gloryPaint);
      },
    );

    // ── PADRÃO (NONE) ───────────────────────────────────────────
    _effects[WeatherType.none] = ZoneEffect(
      name: 'Vazio',
      color: const Color(0xAA000000),
      edgeColor: const Color(0xFF444444),
      pulseSpeed: 1.0,
      particleDensity: 0.0,
      renderEffect: (canvas, center, radius, progress) {
        // Efeito simples
        final voidPaint = Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(center, radius + 5, voidPaint);
      },
    );
  }

  static ZoneEffect? getEffect(WeatherType weather) {
    return _effects[weather];
  }

  static void renderZoneEffect(
    Canvas canvas,
    WeatherType weather,
    Offset center,
    double radius,
    double pulse,
    double progress,
  ) {
    final effect = _effects[weather];
    if (effect == null) return;

    // Desenha o efeito principal
    effect.renderEffect(canvas, center, radius, progress);

    // Desenha a borda com efeito
    final edgePaint = Paint()
      ..color = effect.edgeColor.withOpacity(0.6 + pulse * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 + pulse * 3.0;
    canvas.drawCircle(center, radius, edgePaint);

    // Desenha o pulso de energia
    final pulsePaint = Paint()
      ..color = effect.color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius + pulse * 8, pulsePaint);
  }
}

class _ZoneParticle {
  double x, y;
  double vx, vy;
  double life;
  double size;

  _ZoneParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
  });
}
