// lib/components/snake_bot_ai.dart
import 'dart:math';
import 'package:flame/components.dart' show Vector2;
import 'package:flame/extensions.dart';
import 'food.dart';
import 'snake_bot.dart';
import 'bot/bot_state.dart';
import '../game/snake_engine.dart';
import '../game/engine_zone.dart';
import '../utils/constants.dart'; // necessário para kPlayerMinSegments

enum BotPersonalityType { aggressive, wanderer, foodie }

enum _BotState { hunt, flee, explore }

mixin BotAI on BotState {
  SnakeBot get _bot => this as SnakeBot;

  // ── Configurações da IA ────────────────────────────────────────
  static const double _aiInterval = 0.08;
  static const double _visionRadius = 1400.0;
  static const double _fleeRadius = 220.0;
  static const double _wallMargin = 400.0;
  static const double _zoneMargin = 350.0;

  // ── Configurações de caça ──────────────────────────────────────
  static const double _huntRadius = 600.0; // raio de detecção de presa
  static const int _huntSizeLead = 8; // segmentos de vantagem mínima para caçar

  _BotState _state = _BotState.explore;
  double _stateTimer = 0;
  double _aiTimer = 0;
  Vector2? _exploreTarget;
  double _exploreTargetTimer = 0;

  void tickAI(double dt) {
    if (!_bot.isAlive || _bot.segments.isEmpty) return;

    _aiTimer += dt;
    _stateTimer += dt;
    _exploreTargetTimer -= dt;

    if (_aiTimer >= _aiInterval) {
      _aiTimer = 0;
      _decide();
    }
  }

  void _decide() {
    final head = _bot.segments.first;
    final world = _bot.engine.worldSize;

    // 1. ✅ Fuga da zona de perigo (prioridade máxima)
    final zoneForce = _zoneForce(head);
    if (zoneForce != null) {
      _bot.botTargetDirection =
          (_bot.botTargetDirection * 0.05 + zoneForce * 0.95).normalized();
      _bot.isBoosting = false;
      _state = _BotState.flee;
      _stateTimer = 0;
      return;
    }

    // 2. Evitar Paredes
    final wallForce = _wallForce(head, world);
    if (wallForce != null) {
      _bot.botTargetDirection =
          (_bot.botTargetDirection * 0.1 + wallForce * 0.9).normalized();
      _bot.isBoosting = false;
      _state = _BotState.flee;
      return;
    }

    // 3. Perigo de colisão
    final danger = _dangerForce(head);
    if (danger != null) {
      _bot.botTargetDirection =
          (_bot.botTargetDirection * 0.2 + danger * 0.8).normalized();
      _bot.isBoosting = false;
      _state = _BotState.flee;
      _stateTimer = 0;
      return;
    }

    if (_state == _BotState.flee && _stateTimer < 0.25) return;

    // 4. ✅ Caça — prioridade sobre comida se houver presa próxima
    if (_bot.length > 25) {
      final preyPos = _findPrey(head);
      if (preyPos != null) {
        final toPrey = (preyPos - head).normalized();
        _bot.botTargetDirection =
            (_bot.botTargetDirection * 0.15 + toPrey * 0.85).normalized();
        // Boost apenas se tiver segmentos suficientes para não morrer de fome
        _bot.isBoosting = _bot.segments.length > kPlayerMinSegments + 10;
        _state = _BotState.hunt;
        return;
      }
    }

    // Para de dar boost quando não está caçando
    _bot.isBoosting = false;

    // 5. Comida — só busca comida dentro da zona segura
    final food = _bestFood(head);
    if (food != null) {
      final toFood = (food.position - head).normalized();
      _bot.botTargetDirection =
          (_bot.botTargetDirection * 0.3 + toFood * 0.7).normalized();
      _state = _BotState.hunt;
      return;
    }

    _state = _BotState.explore;
    _doExplore(head, world);
  }

  // ✅ Força que empurra o bot para dentro da zona de perigo
  Vector2? _zoneForce(Vector2 head) {
    final engine = _bot.engine;
    if (!engine.battleActive) return null;

    final center = engine.zoneCenter;
    final radius = engine.zoneRadius;
    final dist = head.distanceTo(center);

    if (dist < radius - _zoneMargin) return null;

    final toCenter = (center - head).normalized();
    final urgency =
        ((dist - (radius - _zoneMargin)) / _zoneMargin).clamp(0.0, 1.0);
    return toCenter * urgency;
  }

  void _doExplore(Vector2 head, Vector2 world) {
    final bool needNew = _exploreTarget == null ||
        _exploreTargetTimer <= 0 ||
        head.distanceTo(_exploreTarget!) < 300;

    if (needNew) {
      _exploreTarget = _pickExploreTarget(head, world);
      _exploreTargetTimer = 4.0 + _bot.rng.nextDouble() * 4.0;
    }

    if (_exploreTarget != null) {
      final toTarget = (_exploreTarget! - head).normalized();
      _bot.botTargetDirection =
          (_bot.botTargetDirection * 0.2 + toTarget * 0.8).normalized();
    }
  }

  // ✅ Explore target sempre dentro da zona segura
  Vector2 _pickExploreTarget(Vector2 head, Vector2 world) {
    final engine = _bot.engine;

    if (engine.battleActive) {
      final center = engine.zoneCenter;
      final safeRadius =
          (engine.zoneRadius - _zoneMargin * 0.5).clamp(100.0, double.infinity);
      final angle = _bot.rng.nextDouble() * pi * 2;
      final dist = _bot.rng.nextDouble() * safeRadius;
      return Vector2(
        center.x + cos(angle) * dist,
        center.y + sin(angle) * dist,
      );
    }

    return Vector2(
      _bot.rng.nextDouble() * world.x,
      _bot.rng.nextDouble() * world.y,
    );
  }

  Vector2? _wallForce(Vector2 head, Vector2 world) {
    Vector2 push = Vector2.zero();
    bool near = false;

    if (head.x < _wallMargin) {
      push.x = 1;
      near = true;
    } else if (head.x > world.x - _wallMargin) {
      push.x = -1;
      near = true;
    }

    if (head.y < _wallMargin) {
      push.y = 1;
      near = true;
    } else if (head.y > world.y - _wallMargin) {
      push.y = -1;
      near = true;
    }

    return near ? push.normalized() : null;
  }

  Vector2? _dangerForce(Vector2 head) {
    Vector2 force = Vector2.zero();
    bool found = false;
    final double dangerR = _fleeRadius + (_bot.length * 0.5);

    void pushFrom(Vector2 pos, double multiplier) {
      final double d = head.distanceTo(pos);
      if (d < dangerR && d > 1) {
        force += (head - pos).normalized() * (1.0 - d / dangerR) * multiplier;
        found = true;
      }
    }

    if (_bot.engine.player.isAlive) {
      pushFrom(_bot.engine.player.segments.first, 6.0);
    }

    for (final bot in _bot.engine.bots) {
      if (bot == _bot || !bot.isAlive) continue;
      pushFrom(bot.segments.first, 4.0);
    }

    return found ? force.normalized() : null;
  }

  Food? _bestFood(Vector2 head) {
    Food? best;
    double maxScore = -1;
    final engine = _bot.engine;

    for (final food in engine.foods) {
      final double d = head.distanceTo(food.position);
      if (d > _visionRadius) continue;

      // ✅ Ignora comida fora da zona quando a zona está ativa
      if (engine.battleActive) {
        final distToCenter = food.position.distanceTo(engine.zoneCenter);
        if (distToCenter > engine.zoneRadius) continue;
      }

      final double score = food.value / (d + 1);
      if (score > maxScore) {
        maxScore = score;
        best = food;
      }
    }
    return best;
  }

  // ✅ Caça bots menores E o player se for menor
  Vector2? _findPrey(Vector2 head) {
    Vector2? bestPrey;
    double bestDist = double.infinity;

    // Verifica bots menores
    for (final bot in _bot.engine.bots) {
      if (bot == _bot || !bot.isAlive || bot.segments.isEmpty) continue;
      // Só caça se for significativamente maior
      if (bot.length + _huntSizeLead > _bot.length) continue;

      final dist = head.distanceTo(bot.segments.first);
      if (dist < _huntRadius && dist < bestDist) {
        bestDist = dist;
        bestPrey = bot.segments.first;
      }
    }

    // Verifica o player se for menor
    final player = _bot.engine.player;
    if (player.isAlive && player.segments.isNotEmpty) {
      if (player.length + _huntSizeLead <= _bot.length) {
        final dist = head.distanceTo(player.segments.first);
        if (dist < _huntRadius && dist < bestDist) {
          bestDist = dist;
          bestPrey = player.segments.first;
        }
      }
    }

    return bestPrey;
  }
}
