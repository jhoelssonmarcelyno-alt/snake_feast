// lib/game/win/win_effects.dart
import 'dart:async' as async;
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart'
    show Colors, Color, FontWeight, FontStyle, Shadow, Offset, TextStyle;
import '../snake_engine.dart';

void showBooyahText(SnakeEngine engine) {
  final textPaint = TextPaint(
    style: TextStyle(
      color: const Color(0xFFFFFF00),
      fontSize: 80.0,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      shadows: [
        Shadow(
          color: const Color(0xFFFF8C00).withAlpha(200),
          offset: const Offset(4, 4),
          blurRadius: 10,
        ),
      ],
    ),
  );

  final booyah = TextComponent(
    text: 'BOOYAH!',
    textRenderer: textPaint,
    position: engine.size / 2,
    anchor: Anchor.center,
  )..priority = 110;

  engine.add(booyah);
  async.Future.delayed(const Duration(seconds: 3), () {
    if (booyah.isMounted) booyah.removeFromParent();
  });
}

void spawnVictoryFireworks(SnakeEngine engine) {
  final rng = Random();
  for (int i = 0; i < 15; i++) {
    async.Future.delayed(Duration(milliseconds: rng.nextInt(1500)), () {
      if (!engine.isAttached) return;
      final position = Vector2(
        rng.nextDouble() * engine.size.x,
        rng.nextDouble() * engine.size.y,
      );
      final color = Colors.primaries[rng.nextInt(Colors.primaries.length)];
      engine.add(
        ParticleSystemComponent(
          particle: _createFireworkParticle(position, color, rng),
        )..priority = 100,
      );
    });
  }
}

Particle _createFireworkParticle(Vector2 position, Color color, Random rng) {
  return Particle.generate(
    count: 100,
    lifespan: 2.5,
    generator: (i) {
      final speed = Vector2(
        (rng.nextDouble() - 0.5) * 600,
        (rng.nextDouble() - 0.5) * 600,
      );
      return AcceleratedParticle(
        position: position.clone(),
        speed: speed,
        acceleration: Vector2(0, 250),
        child: ComputedParticle(
          renderer: (canvas, particle) {
            canvas.drawCircle(
              Offset.zero,
              4.0 * (1.0 - particle.progress),
              Paint()
                ..color = color.withValues(alpha: 1.0 - particle.progress)
                ..style = PaintingStyle.fill,
            );
          },
        ),
      );
    },
  );
}
