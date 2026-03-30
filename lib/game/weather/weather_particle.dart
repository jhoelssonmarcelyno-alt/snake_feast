// lib/game/weather/weather_particle.dart
import 'dart:ui';
import 'dart:math';

class WeatherParticle {
  double x, y;
  double vx, vy;
  double size;
  double alpha;
  double life;
  double maxLife;
  double angle;
  double spin;

  WeatherParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.alpha,
    required this.life,
    required this.maxLife,
    this.angle = 0,
    this.spin = 0,
  });
}
