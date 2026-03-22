// lib/components/food.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' show Colors, Color, HSVColor, RadialGradient, Rect;
import '../utils/constants.dart';
import 'package:flame/components.dart';

enum FoodType { common, botMass, boostMass, star }

class Food {
  final FoodType type;
  final int value;
  final Color color;
  final double glowRadius;
  final double radius;
  Vector2 position;
  double _pulse = 0.0;
  double _starRot = 0.0; // rotação da estrela

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
    _starRot = _rng.nextDouble() * pi * 2;
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

  factory Food.star({required Vector2 position}) {
    return Food._(
      position: position,
      type: FoodType.star,
      value: kFoodStarValue,
      color: const Color(0xFFFFD700),
      glowRadius: 14.0,
      radius: kFoodStarRadius,
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
      {required Vector2 position,
      required Color segmentColor}) = Food.botMass;

  void update(double dt) {
    _pulse = (_pulse + dt * 3.5) % (pi * 2);
    if (type == FoodType.star) {
      _starRot = (_starRot + dt * 1.8) % (pi * 2);
    }
  }

  void render(Canvas canvas, double camX, double camY) {
    final double sx = position.x - camX;
    final double sy = position.y - camY;
    final Offset center = Offset(sx, sy);

    if (type == FoodType.star) {
      _renderStar(canvas, center);
      return;
    }

    if (glowRadius > 0) {
      final double alpha = (0.25 + 0.20 * sin(_pulse)).clamp(0.0, 1.0);
      canvas.drawCircle(center, radius + glowRadius * 0.5,
          Paint()..color = color.withValues(alpha: alpha));
    }

    // Sombra
    canvas.drawCircle(center + const Offset(1, 1.5), radius,
        Paint()..color = Colors.black.withValues(alpha: 0.25));

    // Corpo
    canvas.drawCircle(center, radius, Paint()..color = color);

    // Anel interno escuro
    canvas.drawCircle(
        center,
        radius * 0.82,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.18);

    // Highlight
    canvas.drawCircle(
      center + Offset(-radius * 0.28, -radius * 0.28),
      radius * 0.38,
      Paint()
        ..color = Colors.white
            .withValues(alpha: type == FoodType.common ? 0.45 : 0.60),
    );
  }

  void _renderStar(Canvas canvas, Offset center) {
    final double pulse = 0.9 + 0.1 * sin(_pulse * 2);
    final double r = radius * pulse;

    // Glow pulsante
    final glowAlpha = (0.3 + 0.25 * sin(_pulse)).clamp(0.0, 1.0);
    canvas.drawCircle(
        center,
        r + glowRadius * 0.6,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: glowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Sombra
    canvas.save();
    canvas.translate(center.dx + 1.5, center.dy + 2);
    canvas.rotate(_starRot);
    _drawStarPath(canvas, r, Paint()..color = Colors.black.withValues(alpha: 0.3));
    canvas.restore();

    // Corpo da estrela
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_starRot);

    // Gradiente dourado
    final grad = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFFFF176), Color(0xFFFFD700), Color(0xFFF57F17)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    _drawStarPath(canvas, r, grad);

    // Borda
    _drawStarPath(
        canvas,
        r,
        Paint()
          ..color = const Color(0xFFFF8F00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Highlight
    canvas.drawCircle(
        Offset(-r * 0.25, -r * 0.25),
        r * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.7));

    canvas.restore();
  }

  void _drawStarPath(Canvas canvas, double r, Paint paint) {
    final path = Path();
    const int points = 5;
    final double inner = r * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final double rad = i.isEven ? r : inner;
      final double angle = (i * pi / points) - pi / 2;
      final p = Offset(cos(angle) * rad, sin(angle) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void respawn({required Vector2 worldSize}) {
    position = Vector2(
      _rng.nextDouble() * worldSize.x,
      _rng.nextDouble() * worldSize.y,
    );
    _pulse = _rng.nextDouble() * pi * 2;
    _starRot = _rng.nextDouble() * pi * 2;
  }

  bool get isSnakeMass =>
      type == FoodType.botMass || type == FoodType.boostMass;
}
