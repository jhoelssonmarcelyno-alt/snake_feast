// lib/components/snake_bot_ai.dart
import 'dart:math';
import 'package:flame/extensions.dart';
import 'food.dart';
import 'snake_bot.dart';
import '../game/engine_zone.dart';
import 'bot/bot_state.dart';
import '../utils/constants.dart';

enum BotPersonalityType {
  aggressive, // Caça ativamente, usa boost com frequência
  wanderer, // Explora mais, menos agressivo
  foodie, // Foca em comida, evita confrontos
  hunter, // Especialista em caçar cobras menores
  stalker, // Persegue presas por mais tempo
  cautious, // Muito cauteloso, foge rápido
  passive, // Passivo, só come comida
  explorer // Explora o mapa, não busca confronto
}

enum _BotState { hunt, flee, explore }

mixin BotAI on BotState {
  SnakeBot get _bot => this as SnakeBot;

  final Vector2 _headPos = Vector2.zero();
  final Vector2 _diff = Vector2.zero();
  final Vector2 _force = Vector2.zero();

  // ── Intervalos e raios (ajustáveis por dificuldade) ─────────────────────
  static const double _aiInterval = 0.08;
  static const double _baseVisionRadiusSq = 1400.0 * 1400.0;
  static const double _baseFleeRadius = 300.0;
  static const double _wallMargin = 300.0;
  static const double _zoneMargin = 1200.0;
  static const double _zoneBoostThr = 0.45;

  // Raios de caça (ajustáveis por dificuldade)
  static const double _baseHuntRadiusSq = 900.0 * 900.0;
  static const double _baseAggressiveHuntRadiusSq = 1600.0 * 1600.0;
  static const double _killZoneRadiusSq = 350.0 * 350.0;
  static const int _huntSizeLead = 5;

  static const double _huntPhaseThreshold = 120.0;

  _BotState _state = _BotState.explore;
  double _stateTimer = 0;
  double _aiTimer = 0;
  Vector2? _exploreTarget;
  double _exploreTargetTimer = 0;

  // Dificuldade do mundo (cache para performance)
  double _cachedDifficulty = 0.0;
  double _cachedSpeedMultiplier = 1.0;
  double _cachedIntelligenceMultiplier = 1.0;

  void tickAI(double dt) {
    if (!_bot.isAlive || _bot.segments.isEmpty) return;

    // Atualiza dificuldade baseada no mundo atual
    _updateDifficulty();

    _aiTimer += dt;
    _stateTimer += dt;
    _exploreTargetTimer -= dt;

    if (_aiTimer >= _aiInterval) {
      _aiTimer = 0;
      _decide();
    }
  }

  void _updateDifficulty() {
    final engine = _bot.engine;
    final worldIndex = engine.selectedWorld.clamp(0, 24);
    // Dificuldade de 0.5 a 2.0 baseado no mundo
    _cachedDifficulty = 0.5 + (worldIndex / 24.0) * 1.5;
    _cachedSpeedMultiplier = 0.7 + _cachedDifficulty * 0.6; // 0.7 a 1.9
    _cachedIntelligenceMultiplier = 0.6 + _cachedDifficulty * 0.7; // 0.6 a 1.8
  }

  double _getVisionRadius() {
    return _baseVisionRadiusSq * _cachedIntelligenceMultiplier;
  }

  double _getFleeRadius() {
    return _baseFleeRadius * (1.0 + _cachedDifficulty * 0.5);
  }

  double _getHuntRadius() {
    final personality = _bot.personality;
    if (personality == BotPersonalityType.aggressive ||
        personality == BotPersonalityType.hunter) {
      return _baseAggressiveHuntRadiusSq * _cachedIntelligenceMultiplier;
    }
    return _baseHuntRadiusSq * _cachedIntelligenceMultiplier;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Decisão principal com personalidade e dificuldade
  // ─────────────────────────────────────────────────────────────────────────
  void _decide() {
    if (_bot.segments.isEmpty) return;
    _headPos.setFrom(_bot.segments.first);

    final engine = _bot.engine;
    final world = engine.worldSize;

    // ── Prioridade 1: Zona de Batalha ─────────────────────────────────────
    if (_applyZoneForce()) return;

    // ── Prioridade 2: Paredes ─────────────────────────────────────────────
    if (_applyWallForce(world)) return;

    // ── Prioridade 3: Fugir de cobras maiores ────────────────────────────
    if (_applyDangerForce()) return;

    // ── Prioridade 4: Decisão baseada na personalidade ───────────────────
    final bool isHuntPhase = engine.battleTimer <= _huntPhaseThreshold;
    final personality = _bot.personality;

    // Personalidades agressivas caçam mais
    if (personality == BotPersonalityType.aggressive ||
        personality == BotPersonalityType.hunter ||
        personality == BotPersonalityType.stalker) {
      // Caça presas menores
      final prey = _findPrey(radiusSq: _getHuntRadius());
      if (prey != null) {
        _attackPrey(prey);
        return;
      }
    }

    // Fase de caça ou personalidades agressivas
    if (isHuntPhase || personality == BotPersonalityType.aggressive) {
      final prey = _findPrey(radiusSq: _getHuntRadius());
      if (prey != null) {
        _attackPrey(prey);
        return;
      }
    }

    // Busca comida (prioridade para personalidade foodie)
    final food = _bestFood();
    if (food != null) {
      _seekFood(food);
      return;
    }

    // Caça oportunista (se estiver perto)
    if (!isHuntPhase && personality != BotPersonalityType.passive) {
      final prey = _findPrey(radiusSq: _getHuntRadius() * 0.7);
      if (prey != null) {
        _attackPrey(prey);
        return;
      }
    }

    // ── Fallback: Exploração (comportamento varia por personalidade) ─────
    _bot.isBoosting = false;
    _state = _BotState.explore;
    _doExplore(world);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Força de Perigo (Fuga de Maiores) - Inteligência aumenta a percepção
  // ─────────────────────────────────────────────────────────────────────────

  bool _applyDangerForce() {
    _force.setZero();
    bool foundThreat = false;
    double closestDistSq = double.infinity;

    // Distância de fuga aumenta com dificuldade e tamanho
    final double currentFleeRadius = _getFleeRadius() + (_bot.length * 0.5);
    final double dangerRSq = currentFleeRadius * currentFleeRadius;

    void checkThreat(Vector2 otherHead, int otherLength, bool isPlayer) {
      // Bots mais inteligentes consideram ameaças com menos diferença de tamanho
      final int sizeThreshold = _cachedDifficulty > 1.2 ? 0 : 1;

      // Só considera ameaça se a outra cobra for maior
      if (otherLength <= _bot.length + sizeThreshold) return;

      final double distSq = _headPos.distanceToSquared(otherHead);
      if (distSq < dangerRSq) {
        _diff.setFrom(_headPos);
        _diff.sub(otherHead);

        // Peso da fuga aumenta com dificuldade
        double weight =
            (1.0 - (sqrt(distSq) / currentFleeRadius)).clamp(0.0, 1.0);
        weight *= (0.8 + _cachedDifficulty * 0.4);

        _diff.normalize();
        _diff.scale(weight * 12.0);
        _force.add(_diff);
        foundThreat = true;
        if (distSq < closestDistSq) closestDistSq = distSq;
      }
    }

    // Checar jogador
    final p = _bot.engine.player;
    if (p.isAlive && p.segments.isNotEmpty) {
      checkThreat(p.segments.first, p.length, true);
    }

    // Checar outros bots
    for (final other in _bot.engine.bots) {
      if (other == _bot || !other.isAlive || other.segments.isEmpty) continue;
      checkThreat(other.segments.first, other.length, false);
    }

    if (foundThreat) {
      _force.normalize();

      // Bots mais inteligentes fogem de forma mais eficiente
      final double lerpFactor = 0.7 + _cachedIntelligenceMultiplier * 0.2;
      _bot.botTargetDirection.lerp(_force, lerpFactor.clamp(0.5, 0.95));

      // Boost em fuga: bots mais agressivos usam boost mais cedo
      final bool useBoost = _bot.personality == BotPersonalityType.aggressive ||
          _bot.personality == BotPersonalityType.hunter;

      if (closestDistSq < (150 * 150) && _bot.length > kPlayerMinSegments + 2) {
        _bot.isBoosting =
            useBoost ? true : _bot.length > kPlayerMinSegments + 8;
      } else {
        _bot.isBoosting = false;
      }

      _state = _BotState.flee;
      _stateTimer = 0;
      return true;
    }
    return false;
  }

  // ── Zona ─────────────────────────────────────────────────────────────────
  bool _applyZoneForce() {
    final engine = _bot.engine;
    if (!engine.battleActive) return false;

    final center = engine.zoneCenter;
    final radius = engine.zoneRadius;
    final dist = _headPos.distanceTo(center);

    if (dist < radius - _zoneMargin) return false;

    _diff.setFrom(center);
    _diff.sub(_headPos);
    _diff.normalize();

    final double urgency =
        ((dist - (radius - _zoneMargin)) / _zoneMargin).clamp(0.0, 1.0);

    // Bots mais inteligentes reagem mais rápido à zona
    final double reactionSpeed = 0.6 + _cachedIntelligenceMultiplier * 0.3;

    if (urgency >= 0.75) {
      _bot.botTargetDirection.setFrom(_diff);
    } else {
      _bot.botTargetDirection.lerp(_diff, reactionSpeed + urgency * 0.3);
    }

    _bot.isBoosting = urgency >= _zoneBoostThr;
    _state = _BotState.flee;
    _stateTimer = 0;
    return true;
  }

  // ── Paredes ──────────────────────────────────────────────────────────────
  bool _applyWallForce(Vector2 world) {
    _force.setZero();
    bool near = false;

    final margin = _wallMargin * (1.0 - _cachedDifficulty * 0.2);

    if (_headPos.x < margin) {
      _force.x = 1;
      near = true;
    } else if (_headPos.x > world.x - margin) {
      _force.x = -1;
      near = true;
    }

    if (_headPos.y < margin) {
      _force.y = 1;
      near = true;
    } else if (_headPos.y > world.y - margin) {
      _force.y = -1;
      near = true;
    }

    if (near) {
      _force.normalize();
      final lerpFactor = 0.8 + _cachedIntelligenceMultiplier * 0.15;
      _bot.botTargetDirection.lerp(_force, lerpFactor.clamp(0.7, 0.95));
      _bot.isBoosting = false;
      _state = _BotState.flee;
      return true;
    }
    return false;
  }

  // ── Comida (prioridade maior para foodie) ───────────────────────────────
  Food? _bestFood() {
    Food? best;
    double maxScore = -1;
    final engine = _bot.engine;
    final visionRadiusSq = _getVisionRadius();

    for (final food in engine.foods) {
      final double dSq = _headPos.distanceToSquared(food.position);
      if (dSq > visionRadiusSq) continue;

      if (engine.battleActive) {
        final distToCenterSq =
            food.position.distanceToSquared(engine.zoneCenter);
        final r = engine.zoneRadius;
        if (distToCenterSq > r * r) continue;
      }

      // Personalidade foodie dá prioridade maior à comida
      double scoreMultiplier =
          _bot.personality == BotPersonalityType.foodie ? 2.5 : 1.0;
      final double score = (food.value * scoreMultiplier) / (sqrt(dSq) + 1);

      if (score > maxScore) {
        maxScore = score;
        best = food;
      }
    }
    return best;
  }

  void _seekFood(Food food) {
    _diff.setFrom(food.position);
    _diff.sub(_headPos);
    _diff.normalize();

    // Bots mais inteligentes se movem mais diretamente para a comida
    final lerpFactor = 0.6 + _cachedIntelligenceMultiplier * 0.2;
    _bot.botTargetDirection.lerp(_diff, lerpFactor.clamp(0.5, 0.9));
    _bot.isBoosting = false;
    _state = _BotState.hunt;
  }

  // ── Caça a presas ───────────────────────────────────────────────────────
  Vector2? _findPrey({required double radiusSq}) {
    Vector2? bestPos;
    double bestDistSq = double.infinity;

    void check(bool isAlive, List<dynamic> segs, int len) {
      if (!isAlive || segs.isEmpty) return;

      // Bots mais agressivos caçam cobras de tamanho mais próximo
      final int sizeLead =
          _cachedDifficulty > 1.0 ? _huntSizeLead + 2 : _huntSizeLead;
      if (len + sizeLead > _bot.length) return;

      final Vector2 head = segs.first as Vector2;
      final double dSq = _headPos.distanceToSquared(head);
      if (dSq < radiusSq && dSq < bestDistSq) {
        bestDistSq = dSq;
        bestPos = head;
      }
    }

    for (final b in _bot.engine.bots) {
      if (b == _bot) continue;
      check(b.isAlive, b.segments, b.length);
    }
    final p = _bot.engine.player;
    check(p.isAlive, p.segments, p.length);

    return bestPos;
  }

  void _attackPrey(Vector2 preyPos) {
    _diff.setFrom(preyPos);
    _diff.sub(_headPos);
    final double distSq = _diff.length2;
    _diff.normalize();

    // Bots mais agressivos são mais precisos na caça
    double precision = distSq < _killZoneRadiusSq ? 0.95 : 0.7;
    precision += _cachedIntelligenceMultiplier * 0.1;

    _bot.botTargetDirection.lerp(_diff, precision.clamp(0.65, 0.98));

    // Boost na caça: bots agressivos usam boost com mais frequência
    final bool isAggressive =
        _bot.personality == BotPersonalityType.aggressive ||
            _bot.personality == BotPersonalityType.hunter;

    _bot.isBoosting = distSq < _killZoneRadiusSq &&
        _bot.length > kPlayerMinSegments + (isAggressive ? 3 : 5);
    _state = _BotState.hunt;
  }

  // ── Exploração (varia por personalidade) ─────────────────────────────────
  void _doExplore(Vector2 world) {
    if (_exploreTarget == null || _exploreTargetTimer <= 0) {
      _exploreTarget = _pickExploreTarget(world);
      // Personalidade wanderer/explorer exploram por mais tempo
      final isExplorer = _bot.personality == BotPersonalityType.wanderer ||
          _bot.personality == BotPersonalityType.explorer;
      _exploreTargetTimer =
          (isExplorer ? 6.0 : 3.0) + _bot.rng.nextDouble() * 4.0;
    }
    if (_exploreTarget != null) {
      _diff.setFrom(_exploreTarget!);
      _diff.sub(_headPos);
      _diff.normalize();

      final lerpFactor = 0.5 + _cachedIntelligenceMultiplier * 0.15;
      _bot.botTargetDirection.lerp(_diff, lerpFactor.clamp(0.4, 0.8));
    }
  }

  Vector2 _pickExploreTarget(Vector2 world) {
    final engine = _bot.engine;
    final isExplorer = _bot.personality == BotPersonalityType.wanderer ||
        _bot.personality == BotPersonalityType.explorer;

    if (engine.battleActive) {
      final center = engine.zoneCenter;
      final safeRadius =
          (engine.zoneRadius - _zoneMargin * 1.2).clamp(80.0, double.infinity);
      final double angle = _bot.rng.nextDouble() * pi * 2;
      final double dist = _bot.rng.nextDouble() * safeRadius;
      return Vector2(
          center.x + cos(angle) * dist, center.y + sin(angle) * dist);
    }

    // Exploradores vão mais longe
    if (isExplorer) {
      return Vector2(
          _bot.rng.nextDouble() * world.x, _bot.rng.nextDouble() * world.y);
    }

    // Fica mais perto do centro
    return Vector2(world.x / 2 + (_bot.rng.nextDouble() - 0.5) * world.x * 0.5,
        world.y / 2 + (_bot.rng.nextDouble() - 0.5) * world.y * 0.5);
  }
}
