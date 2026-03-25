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
    // ✅ Bloqueio inicial (caso o jogo comece/reinicie em tempo avançado)
    if (battleTimer <= 60) return;

    for (int i = 0; i < count; i++) {
      foods.add(Food.common(position: _randomSafePosition()));
    }
  }

  void spawnStars() {
    // ✅ REGRA: Estrelas param de nascer após 1 minuto
    if (battleTimer <= 60) return;

    final int count =
        (foods.where((f) => f.type == FoodType.common).length * 0.10)
            .ceil()
            .clamp(1, 50);
    for (int i = 0; i < count; i++) {
      foods.add(Food.star(position: _randomSafePosition()));
    }
  }

  // ── Consome uma comida e repõe apenas se dentro do limite e tempo ────
  void consumeFood(Food food, dynamic snake) {
    if (!foods.contains(food)) return;
    foods.remove(food);

    // ✅ REGRA: Se faltar 1 minuto ou menos, NUNCA repõe comida ou estrela
    if (battleTimer <= 60) return;

    final commonCount = foods.where((f) => f.type == FoodType.common).length;

    if (food.type == FoodType.common) {
      if (commonCount < _maxFoodAllowed) {
        foods.add(Food.common(position: _randomSafePosition()));
      }
    } else if (food.type == FoodType.star) {
      Future.delayed(const Duration(seconds: 8), () {
        // Double check no tempo após o delay do Future
        if (battleTimer > 60) {
          foods.add(Food.star(position: _randomSafePosition()));
        }
      });
    }
  }

  // ── Explosão de cobra — CONTINUA FUNCIONANDO (SEM TRAVA DE TEMPO) ──
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

      // ✅ Aqui não tem trava: as cobras ainda deixam massa ao morrer
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
      // ✅ O ímã continua funcionando para massa de bot também se você quiser,
      // mas aqui está filtrado para 'common'. Para atrair tudo, remova a linha abaixo:
      if (food.type != FoodType.common && food.type != FoodType.botMass)
        continue;

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
    for (final food in foods) {
      food.update(dt);
    }
  }
}
