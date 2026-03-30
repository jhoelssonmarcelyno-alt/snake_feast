// lib/game/weather/weather_spawner.dart
import 'dart:math';
import 'dart:ui';
import 'weather_types.dart';
import 'weather_particle.dart';

class WeatherSpawner {
  final Random _rng = Random();
  
  WeatherParticle spawn(WeatherType type, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case WeatherType.rain:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: -10,
          vx: -1.5 + _rng.nextDouble() * 1.0,
          vy: 400 + _rng.nextDouble() * 200,
          size: 1.2 + _rng.nextDouble() * 0.8,
          alpha: 0.35 + _rng.nextDouble() * 0.3,
          life: 1,
          maxLife: 1,
        );

      case WeatherType.snow:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: -10,
          vx: -20 + _rng.nextDouble() * 40,
          vy: 30 + _rng.nextDouble() * 50,
          size: 2 + _rng.nextDouble() * 4,
          alpha: 0.6 + _rng.nextDouble() * 0.3,
          life: 1,
          maxLife: 1,
          spin: (_rng.nextDouble() - 0.5) * 0.5,
        );

      case WeatherType.fog:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: _rng.nextDouble() * h,
          vx: 5 + _rng.nextDouble() * 15,
          vy: -3 + _rng.nextDouble() * 6,
          size: 80 + _rng.nextDouble() * 120,
          alpha: 0,
          life: 1,
          maxLife: 1,
        );

      case WeatherType.leaves:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: -10,
          vx: -30 + _rng.nextDouble() * 60,
          vy: 40 + _rng.nextDouble() * 60,
          size: 5 + _rng.nextDouble() * 6,
          alpha: 0.55 + _rng.nextDouble() * 0.3,
          life: 1,
          maxLife: 1,
          angle: _rng.nextDouble() * pi * 2,
          spin: (_rng.nextDouble() - 0.5) * 4,
        );

      case WeatherType.embers:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: h + 10,
          vx: -30 + _rng.nextDouble() * 60,
          vy: -(60 + _rng.nextDouble() * 120),
          size: 2 + _rng.nextDouble() * 3,
          alpha: 0.7 + _rng.nextDouble() * 0.3,
          life: 1,
          maxLife: 1,
          spin: (_rng.nextDouble() - 0.5) * 3,
        );

      case WeatherType.sand:
        return WeatherParticle(
          x: -10,
          y: h * 0.3 + _rng.nextDouble() * h * 0.7,
          vx: 80 + _rng.nextDouble() * 100,
          vy: -10 + _rng.nextDouble() * 20,
          size: 1 + _rng.nextDouble() * 2,
          alpha: 0.2 + _rng.nextDouble() * 0.3,
          life: 1,
          maxLife: 1,
        );

      case WeatherType.stars:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: -10,
          vx: -10 + _rng.nextDouble() * 20,
          vy: 20 + _rng.nextDouble() * 40,
          size: 1.5 + _rng.nextDouble() * 2,
          alpha: 0,
          life: 1,
          maxLife: 1,
          spin: _rng.nextDouble() * 2,
        );

      case WeatherType.bubbles:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: h + 10,
          vx: -15 + _rng.nextDouble() * 30,
          vy: -(30 + _rng.nextDouble() * 60),
          size: 4 + _rng.nextDouble() * 12,
          alpha: 0.15 + _rng.nextDouble() * 0.2,
          life: 1,
          maxLife: 1,
          spin: (_rng.nextDouble() - 0.5) * 0.5,
        );

      case WeatherType.sparks:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: _rng.nextDouble() * h,
          vx: -60 + _rng.nextDouble() * 120,
          vy: -60 + _rng.nextDouble() * 120,
          size: 1.5 + _rng.nextDouble() * 2,
          alpha: 0.8 + _rng.nextDouble() * 0.2,
          life: 1,
          maxLife: 0.3,
        );

      case WeatherType.petals:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: -10,
          vx: -20 + _rng.nextDouble() * 40,
          vy: 25 + _rng.nextDouble() * 35,
          size: 4 + _rng.nextDouble() * 5,
          alpha: 0.5 + _rng.nextDouble() * 0.3,
          life: 1,
          maxLife: 1,
          angle: _rng.nextDouble() * pi * 2,
          spin: (_rng.nextDouble() - 0.5) * 3,
        );

      case WeatherType.crystals:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: -10,
          vx: -10 + _rng.nextDouble() * 20,
          vy: 20 + _rng.nextDouble() * 50,
          size: 3 + _rng.nextDouble() * 5,
          alpha: 0.4 + _rng.nextDouble() * 0.4,
          life: 1,
          maxLife: 1,
          angle: _rng.nextDouble() * pi,
          spin: (_rng.nextDouble() - 0.5) * 1.5,
        );

      case WeatherType.dust:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: -10,
          vx: -15 + _rng.nextDouble() * 30,
          vy: 15 + _rng.nextDouble() * 30,
          size: 2 + _rng.nextDouble() * 4,
          alpha: 0.15 + _rng.nextDouble() * 0.2,
          life: 1,
          maxLife: 1,
          spin: (_rng.nextDouble() - 0.5) * 1.0,
        );

      case WeatherType.electricity:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: _rng.nextDouble() * h,
          vx: 0,
          vy: 0,
          size: 2 + _rng.nextDouble() * 3,
          alpha: 0,
          life: 1,
          maxLife: 0.4,
        );

      case WeatherType.divine:
        return WeatherParticle(
          x: _rng.nextDouble() * w,
          y: -10,
          vx: -5 + _rng.nextDouble() * 10,
          vy: 15 + _rng.nextDouble() * 25,
          size: 3 + _rng.nextDouble() * 5,
          alpha: 0,
          life: 1,
          maxLife: 1,
          spin: _rng.nextDouble() * 2,
        );

      case WeatherType.none:
        return WeatherParticle(
          x: 0,
          y: 0,
          vx: 0,
          vy: 0,
          size: 0,
          alpha: 0,
          life: 0,
          maxLife: 1,
        );
    }
  }
}
