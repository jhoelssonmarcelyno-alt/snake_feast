import 'dart:math';
import 'dart:ui' show Color;
import '../components/food.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';
import 'package:flame/components.dart';

extension EngineFood on SnakeEngine {
  /// Busca o componente de zona no jogo (CircleComponent ou ZoneComponent)
  /// Isso evita o erro de "Undefined name"
  CircleComponent? get _findZone =>
      children.whereType<CircleComponent>().firstOrNull;

  Vector2 _getRandomPositionInZone() {
    final zone = _findZone;
    // Se não achar a zona, usa o tamanho do mapa como segurança
    if (zone == null) {
      return Vector2(
        kWallThickness + rng.nextDouble() * (worldSize.x - kWallThickness * 2),
        kWallThickness + rng.nextDouble() * (worldSize.y - kWallThickness * 2),
      );
    }

    final zoneCenter = zone.position;
    final zoneRadius = zone.radius * 0.95;
    final angle = rng.nextDouble() * pi * 2;
    final distance = sqrt(rng.nextDouble()) * zoneRadius;

    return Vector2(
      zoneCenter.x + cos(angle) * distance,
      zoneCenter.y + sin(angle) * distance,
    );
  }

  void spawnCommonFood(int count) {
    for (int i = 0; i < count; i++) {
      foods.add(Food.common(
        position: _getRandomPositionInZone(),
      ));
    }
  }

  void spawnStars() {
    final int count =
        (foods.where((f) => f.type == FoodType.common).length * 0.10)
            .ceil()
            .clamp(1, 50);
    for (int i = 0; i < count; i++) {
      foods.add(Food.star(
        position: _getRandomPositionInZone(),
      ));
    }
  }

  void consumeFood(Food food, dynamic snake) {
    if (!foods.contains(food)) return;
    foods.remove(food);

    if (food.type == FoodType.common) {
      foods.add(Food.common(
        position: _getRandomPositionInZone(),
      ));
    } else if (food.type == FoodType.star) {
      Future.delayed(const Duration(seconds: 8), () {
        foods.add(Food.star(
          position: _getRandomPositionInZone(),
        ));
      });
    }
  }

  void explodeSnake(List<Vector2> segments, Color color) {
    final int total = segments.length;
    final int count = total.clamp(8, 60);
    final int step = (total / count).ceil().clamp(1, 999);
    final zone = _findZone;

    for (int i = 0; i < total; i += step) {
      final offset = Vector2(
        (rng.nextDouble() - 0.5) * 40,
        (rng.nextDouble() - 0.5) * 40,
      );

      final pos = segments[i].clone() + offset;

      // Se a zona existir, checa se a explosão está dentro
      if (zone != null) {
        if (pos.distanceToSquared(zone.position) >
            (zone.radius * zone.radius)) {
          continue; // Pula essa partícula se estiver fora
        }
      }

      foods.add(Food.botMass(
        position: pos,
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
    final zone = _findZone;

    foods.removeWhere((food) {
      // Se a zona existir, remove o que estiver fora
      if (zone != null) {
        final distSq = food.position.distanceToSquared(zone.position);
        if (distSq > (zone.radius * zone.radius)) {
          // Garante a destruição do componente visual
          if (food is Component) {
            (food as Component).removeFromParent();
          }
          return true;
        }
      }

      food.update(dt);
      return false;
    });
  }
}
