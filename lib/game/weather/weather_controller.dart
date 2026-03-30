// lib/game/weather/weather_controller.dart
import 'dart:math';
import 'dart:ui';
import 'weather_types.dart';
import 'weather_particle.dart';
import 'weather_data.dart';
import 'weather_spawner.dart';
import 'weather_renderer.dart';
import '../snake_engine.dart';

class WeatherController {
  final List<WeatherParticle> _particles = [];
  final Random _rng = Random();
  final WeatherSpawner _spawner = WeatherSpawner();
  final WeatherRenderer _renderer = WeatherRenderer();

  WeatherType _currentDynamicWeather = WeatherType.none;
  double _weatherTransitionTimer = 0.0;
  bool _isDangerPhase = false;

  final SnakeEngine _engine;

  WeatherController(this._engine);

  WeatherType get currentWeather {
    if (_currentDynamicWeather != WeatherType.none) {
      return _currentDynamicWeather;
    }
    final idx = _engine.selectedWorld.clamp(0, kWorldWeather.length - 1);
    return kWorldWeather[idx];
  }

  void update(double dt) {
    _updateWeatherByZone();

    if (_weatherTransitionTimer > 0) {
      _weatherTransitionTimer -= dt;
      if (_weatherTransitionTimer <= 0) {
        _particles.clear();
      }
    }

    final type = currentWeather;
    if (type == WeatherType.none) {
      _particles.clear();
      return;
    }

    final intensityMultiplier = _isDangerPhase ? 1.5 : 1.0;
    final target =
        ((kTargetParticleCount[type] ?? 0) * intensityMultiplier).toInt();
    final screenSize = _engine.size;

    final missing = target - _particles.length;
    final toSpawn = missing.clamp(0, 8);
    for (int i = 0; i < toSpawn; i++) {
      _particles.add(_spawner.spawn(type, Size(screenSize.x, screenSize.y)));
    }

    _updateParticles(dt, type, Size(screenSize.x, screenSize.y));
  }

  void _updateParticles(double dt, WeatherType type, Size screenSize) {
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];

      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.angle += p.spin * dt;

      final progress = 1.0 - p.life;
      if (progress < 0.1) {
        p.alpha = p.alpha * (progress / 0.1);
      } else if (p.life < 0.15) {
        p.alpha *= (p.life / 0.15);
      }

      if (type == WeatherType.fog) {
        p.alpha = (0.04 + sin(p.angle) * 0.03).clamp(0.0, 0.12);
        p.angle += dt * 0.4;
      }

      if (type == WeatherType.stars || type == WeatherType.divine) {
        final t = 1.0 - p.life;
        p.alpha = (t * 4).clamp(0.0, 0.8) * (p.life * 4).clamp(0.0, 1.0);
      }

      if (type == WeatherType.electricity) {
        p.alpha = _rng.nextDouble() > 0.5 ? 0.9 : 0.0;
      }

      p.life -= dt / p.maxLife;

      final dead = p.life <= 0 ||
          p.x < -200 ||
          p.x > screenSize.width + 200 ||
          p.y < -200 ||
          p.y > screenSize.height + 200;

      if (dead) {
        _particles.removeAt(i);
      }
    }
  }

  void _updateWeatherByZone() {
    final double progress =
        1.0 - (_engine.battleTimer / SnakeEngine.kTotalGameTime);
    final bool isDangerZoneActive = _engine.battleActive;
    final baseWeather =
        kWorldWeather[_engine.selectedWorld.clamp(0, kWorldWeather.length - 1)];

    if (isDangerZoneActive) {
      _isDangerPhase = true;

      if (progress < 0.3) {
        _setDynamicWeather(_getDangerWeather(baseWeather), intensity: 0.7);
      } else if (progress < 0.6) {
        _setDynamicWeather(_getDangerWeather(baseWeather), intensity: 0.9);
      } else if (progress < 0.85) {
        _setDynamicWeather(WeatherType.electricity, intensity: 1.0);
      } else {
        _setDynamicWeather(WeatherType.divine, intensity: 1.2);
      }
    } else {
      _isDangerPhase = false;

      if (progress < 0.2) {
        _setDynamicWeather(baseWeather, intensity: 0.3);
      } else if (progress < 0.4) {
        _setDynamicWeather(baseWeather, intensity: 0.5);
      } else if (progress < 0.6) {
        _setDynamicWeather(baseWeather, intensity: 0.7);
      } else if (progress < 0.8) {
        _setDynamicWeather(_getDangerWeather(baseWeather), intensity: 0.8);
      } else {
        _setDynamicWeather(WeatherType.electricity, intensity: 0.9);
      }
    }
  }

  WeatherType _getDangerWeather(WeatherType baseWeather) {
    switch (baseWeather) {
      case WeatherType.rain:
        return WeatherType.electricity;
      case WeatherType.snow:
        return WeatherType.stars;
      case WeatherType.fog:
        return WeatherType.electricity;
      case WeatherType.leaves:
        return WeatherType.embers;
      case WeatherType.embers:
        return WeatherType.electricity;
      case WeatherType.sand:
        return WeatherType.electricity;
      case WeatherType.stars:
        return WeatherType.divine;
      case WeatherType.bubbles:
        return WeatherType.electricity;
      case WeatherType.sparks:
        return WeatherType.electricity;
      case WeatherType.petals:
        return WeatherType.embers;
      case WeatherType.crystals:
        return WeatherType.electricity;
      case WeatherType.dust:
        return WeatherType.electricity;
      case WeatherType.electricity:
        return WeatherType.divine;
      case WeatherType.divine:
        return WeatherType.electricity;
      default:
        return WeatherType.electricity;
    }
  }

  void _setDynamicWeather(WeatherType newWeather, {double intensity = 0.5}) {
    if (_currentDynamicWeather == newWeather && _weatherTransitionTimer > 0) {
      return;
    }

    if (_currentDynamicWeather != newWeather) {
      _currentDynamicWeather = newWeather;
      _weatherTransitionTimer = 0.5;

      if (_weatherTransitionTimer <= 0) {
        _particles.clear();
      }
    }
  }

  void render(Canvas canvas) {
    _renderer.render(canvas, currentWeather, _particles);
  }

  void reset() {
    _currentDynamicWeather = WeatherType.none;
    _isDangerPhase = false;
    _particles.clear();
  }
}
