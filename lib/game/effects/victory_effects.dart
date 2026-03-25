import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class VictoryEffects {
  static void showBooyah(FlameGame engine) {
    final textPaint = TextPaint(
      style: TextStyle(
        color: const Color(0xFFFFFF00),
        fontSize: 80,
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

    final text = TextComponent(
      text: 'BOOYAH!',
      textRenderer: textPaint,
      position: engine.size / 2,
      anchor: Anchor.center,
    )..priority = 110;

    engine.add(text);

    Future.delayed(const Duration(seconds: 3), () {
      if (text.isMounted) text.removeFromParent();
    });
  }

  static void spawnFireworks(FlameGame engine) {
    final rng = Random();

    for (int i = 0; i < 15; i++) {
      Future.delayed(Duration(milliseconds: rng.nextInt(1500)), () {
        if (!engine.isAttached) return;

        final position = Vector2(
          rng.nextDouble() * engine.size.x,
          rng.nextDouble() * engine.size.y,
        );

        final color = Colors.primaries[rng.nextInt(Colors.primaries.length)];

        engine.add(
          ParticleSystemComponent(
            particle: _firework(position, color),
          )..priority = 100,
        );
      });
    }
  }

  static Particle _firework(Vector2 pos, Color color) {
    final rng = Random();

    return Particle.generate(
      count: 100,
      lifespan: 2.5,
      generator: (_) {
        final speed = Vector2(
          (rng.nextDouble() - 0.5) * 600,
          (rng.nextDouble() - 0.5) * 600,
        );

        return AcceleratedParticle(
          position: pos.clone(),
          speed: speed,
          acceleration: Vector2(0, 250),
          child: ComputedParticle(
            renderer: (canvas, p) {
              final paint = Paint()
                ..color = color.withValues(alpha: 1 - p.progress);

              canvas.drawCircle(
                Offset.zero,
                4 * (1 - p.progress),
                paint,
              );
            },
          ),
        );
      },
    );
  }
}
