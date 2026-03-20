// lib/components/food.dart
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Color, HSVColor;
import '../utils/constants.dart';

enum FoodType { common, botMass, boostMass }

// ─── Food agora é só um objeto de dados, sem Component ────────
// O render é feito diretamente no engine_render.dart
class Food {
  final FoodType type;
  final int value;
  final Color color;
  final double glowRadius;
  final double radius;

  Vector2 position;

  double _pulse = 0.0;
  static final Random _rng = Random();

  Food._({
    required this.position,
    required this.type,
    required this.value,
    required this.color,
    required this.glowRadius,
    required this.radius,
  }) {
    _pulse = _rng.nextDouble() * pi * 2;
  }

  factory Food.common({required Vector2 position}) {
    final double hue = _rng.nextDouble() * 360;
    return Food._(
      position: position,
      type: FoodType.common,
      value: kFoodCommonValue,
      color: HSVColor.fromAHSV(1.0, hue, 0.85, 1.0).toColor(),
      glowRadius: 0.0,
      radius: kFoodCommonRadius,
    );
  }

  factory Food.botMass(
      {required Vector2 position, required Color segmentColor}) {
    return Food._(
      position: position,
      type: FoodType.botMass,
      value: kFoodBotMassValue,
      color: segmentColor,
      glowRadius: kFoodMassGlowRadius,
      radius: kFoodMassRadius,
    );
  }

  factory Food.boostMass(
      {required Vector2 position, required Color segmentColor}) {
    return Food._(
      position: position,
      type: FoodType.boostMass,
      value: kFoodBoostMassValue,
      color: segmentColor,
      glowRadius: kFoodMassGlowRadius * 0.6,
      radius: kFoodMassRadius * 0.85,
    );
  }

  factory Food.snakeMass(
      {required Vector2 position, required Color segmentColor}) = Food.botMass;

  void update(double dt) {
    if (type != FoodType.common) {
      _pulse = (_pulse + dt * 3.5) % (pi * 2);
    }
  }

  void render(Canvas canvas, double camX, double camY) {
    final double sx = position.x - camX;
    final double sy = position.y - camY;

    final Offset center = Offset(sx, sy);

    if (glowRadius > 0) {
      final double alpha = (0.25 + 0.20 * sin(_pulse)).clamp(0.0, 1.0);
      canvas.drawCircle(center, radius + glowRadius * 0.5,
          Paint()..color = color.withOpacity(alpha));
    }

    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawCircle(
      center + const Offset(-1.5, -1.5),
      radius * 0.38,
      Paint()
        ..color =
            Colors.white.withOpacity(type == FoodType.common ? 0.35 : 0.55),
    );
  }

  void respawn({required Vector2 worldSize}) {
    position = Vector2(
      _rng.nextDouble() * worldSize.x,
      _rng.nextDouble() * worldSize.y,
    );
    _pulse = _rng.nextDouble() * pi * 2;
  }

  bool get isSnakeMass => type != FoodType.common;
}
