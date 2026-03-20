// lib/game/engine_food.dart
import 'dart:math';
import 'dart:ui' show Color;
import 'package:flame/components.dart';
import '../components/food.dart';
import '../utils/constants.dart';
import 'snake_engine.dart';

extension EngineFood on SnakeEngine {
  void spawnCommonFood(int count) {
    for (int i = 0; i < count; i++) {
      foods.add(Food.common(
        position: Vector2(
          kWallThickness +
              rng.nextDouble() * (worldSize.x - kWallThickness * 2),
          kWallThickness +
              rng.nextDouble() * (worldSize.y - kWallThickness * 2),
        ),
      ));
    }
  }

  void consumeFood(Food food, dynamic snake) {
    if (!foods.contains(food)) return;
    foods.remove(food);
    if (food.type == FoodType.common) {
      foods.add(Food.common(
        position: Vector2(
          kWallThickness +
              rng.nextDouble() * (worldSize.x - kWallThickness * 2),
          kWallThickness +
              rng.nextDouble() * (worldSize.y - kWallThickness * 2),
        ),
      ));
    }
  }

  void explodeSnake(List<Vector2> segments, Color color) {
    final int total = segments.length;
    final int count = total.clamp(8, 60);
    final int step = (total / count).ceil().clamp(1, 999);
    for (int i = 0; i < total; i += step) {
      final offset = Vector2(
        (rng.nextDouble() - 0.5) * 40,
        (rng.nextDouble() - 0.5) * 40,
      );
      foods.add(Food.botMass(
        position: segments[i].clone() + offset,
        segmentColor: color,
      ));
    }
  }

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
      if (food.type != FoodType.common) continue;
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
