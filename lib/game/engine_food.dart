// lib/game/engine_food.dart
import 'dart:math';
import 'dart:ui' show Color;
import 'engine_zone.dart';
import '../components/food.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';
import 'package:flame/components.dart';

extension EngineFood on SnakeEngine {
  // ── Limite dinâmico de comida baseado na área da zona ────────
  int get _maxFoodAllowed {
    if (!battleActive) return kCommonFoodCount;
    final zoneArea = pi * zoneRadius * zoneRadius;
    final mapArea = worldSize.x * worldSize.y;
    final ratio = (zoneArea / mapArea).clamp(0.0, 1.0);
    return (kFoodMinCount + (kCommonFoodCount - kFoodMinCount) * ratio).round();
  }

  // ── Posição dentro da zona segura (ou do mapa todo antes da zona) ──
  Vector2 _randomSafePosition() {
    if (battleActive) {
      final angle = rng.nextDouble() * pi * 2;
      final dist = sqrt(rng.nextDouble()) * (zoneRadius * 0.92);
      return Vector2(
        zoneCenter.x + cos(angle) * dist,
        zoneCenter.y + sin(angle) * dist,
      );
    }
    return Vector2(
      kWallThickness + rng.nextDouble() * (worldSize.x - kWallThickness * 2),
      kWallThickness + rng.nextDouble() * (worldSize.y - kWallThickness * 2),
    );
  }

  void spawnCommonFood(int count) {
    // ✅ Bloqueio: sem spawn nos últimos 90 segundos
    if (battleTimer <= 90) return;

    for (int i = 0; i < count; i++) {
      foods.add(Food.common(position: _randomSafePosition()));
    }
  }

  void spawnStars() {
    // ✅ REGRA: Estrelas param de nascer nos últimos 90 segundos
    if (battleTimer <= 90) return;

    final int count =
        (foods.where((f) => f.type == FoodType.common).length * 0.10)
            .ceil()
            .clamp(1, 50);
    for (int i = 0; i < count; i++) {
      foods.add(Food.star(position: _randomSafePosition()));
    }
  }

  // ── Consome uma comida (APENAS remove da lista e repõe se necessário) ──
  //
  // ✅ FIX IMPORTANTE: consumeFood NÃO chama snake.grow() aqui.
  //    O grow() é chamado diretamente por quem detecta a colisão
  //    (_checkFoodCollisions no player e no bot), evitando double-grow.
  //    Esta função é responsável APENAS por:
  //      1. Remover a comida da lista global
  //      2. Decidir se deve repor nova comida
  //
  void consumeFood(Food food, dynamic snake) {
    if (!foods.contains(food)) return;
    foods.remove(food);

    // ✅ REGRA: Nos últimos 90 segundos, NUNCA repõe comida ou estrela
    if (battleTimer <= 90) return;

    final commonCount = foods.where((f) => f.type == FoodType.common).length;

    if (food.type == FoodType.common) {
      if (commonCount < _maxFoodAllowed) {
        foods.add(Food.common(position: _randomSafePosition()));
      }
    } else if (food.type == FoodType.star) {
      Future.delayed(const Duration(seconds: 8), () {
        if (battleTimer > 90) {
          foods.add(Food.star(position: _randomSafePosition()));
        }
      });
    }
  }

  // ── Explosão de cobra (sem trava de tempo) ────────────────────
  void explodeSnake(List<Vector2> segments, Color color) {
    final int total = segments.length;
    final int count = total.clamp(8, 60);
    final int step = (total / count).ceil().clamp(1, 999);

    for (int i = 0; i < total; i += step) {
      final offset = Vector2(
        (rng.nextDouble() - 0.5) * 40,
        (rng.nextDouble() - 0.5) * 40,
      );
      final pos = segments[i].clone() + offset;

      if (battleActive) {
        final distSq = pos.distanceToSquared(zoneCenter);
        if (distSq > zoneRadius * zoneRadius) continue;
      }

      foods.add(Food.botMass(position: pos, segmentColor: color));
    }
  }

  // ── Atrai comida para o player ────────────────────────────────
  void attractFoodToPlayer({double dt = 0.016}) {
    if (!player.isAlive || player.segments.isEmpty) return;
    attractTimer += dt;
    if (attractTimer < 0.05) return;
    attractTimer = 0;

    final Vector2 head = player.headPosition;
    const double attractRadius = 130.0;
    const double attractRadiusSq = attractRadius * attractRadius;
    const double speed = 200.0;

    for (final food in foods) {
      if (food.type != FoodType.common && food.type != FoodType.botMass) {
        continue;
      }

      final dx = head.x - food.position.x;
      final dy = head.y - food.position.y;
      final sq = dx * dx + dy * dy;
      if (sq < attractRadiusSq && sq > 1.0) {
        final dist = sqrt(sq);
        final force = (1.0 - dist / attractRadius) * speed;
        food.position.x += (dx / dist) * force * 0.05;
        food.position.y += (dy / dist) * force * 0.05;
      }
    }
  }

  void updateFoods(double dt) {
    // For-in simples para atualizar as animações (pulso/rotação)
    for (final food in foods) {
      food.update(dt);
    }
  }
}
