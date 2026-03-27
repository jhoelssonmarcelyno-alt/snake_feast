// lib/components/snake_bot_ai.dart
import 'dart:math';
import 'package:flame/extensions.dart';
import 'food.dart';
import 'snake_bot.dart';
import 'bot/bot_state.dart';
import '../utils/constants.dart';

enum BotPersonalityType { aggressive, wanderer, foodie }

enum _BotState { hunt, flee, explore }

mixin BotAI on BotState {
  SnakeBot get _bot => this as SnakeBot;

  final Vector2 _headPos = Vector2.zero();
  final Vector2 _diff = Vector2.zero();
  final Vector2 _force = Vector2.zero();

  // ── Intervalos e raios ────────────────────────────────────────────────────
  static const double _aiInterval = 0.08;
  static const double _visionRadiusSq = 1400.0 * 1400.0;
  static const double _fleeRadius = 300.0; // Aumentado para detecção antecipada
  static const double _wallMargin = 300.0;
  static const double _zoneMargin = 1200.0;
  static const double _zoneBoostThr = 0.45;

  // Raios de caça
  static const double _huntRadiusSq = 900.0 * 900.0;
  static const double _aggressiveHuntRadiusSq = 1600.0 * 1600.0;
  static const double _killZoneRadiusSq = 350.0 * 350.0;
  static const int _huntSizeLead = 5;

  /// Tempo restante (segundos) abaixo do qual a fase de caça se ativa.
  static const double _huntPhaseThreshold = 120.0;

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

  // ─────────────────────────────────────────────────────────────────────────
  // Decisão principal - Ordem de Prioridade Alterada para Sobrevivência
  // ─────────────────────────────────────────────────────────────────────────
  void _decide() {
    if (_bot.segments.isEmpty) return;
    _headPos.setFrom(_bot.segments.first);

    final engine = _bot.engine;
    final world = engine.worldSize;

    // ── Prioridade 1: Zona de Batalha (Morte certa) ────────────────────────
    if (_applyZoneForce()) return;

    // ── Prioridade 2: Paredes (Morte certa) ────────────────────────────────
    if (_applyWallForce(world)) return;

    // ── Prioridade 3: Fugir de cobras maiores (Sobrevivência) ──────────────
    // Agora o bot checa se precisa fugir ANTES de pensar em comer.
    if (_applyDangerForce()) return;

    // ── Prioridade 4: Determina fase de busca (Caça ou Comida) ─────────────
    final bool isHuntPhase = engine.battleTimer <= _huntPhaseThreshold;

    if (isHuntPhase) {
      // FASE CAÇA: Procura presas menores
      final prey = _findPrey(radiusSq: _aggressiveHuntRadiusSq);
      if (prey != null) {
        _attackPrey(prey);
        return;
      }
    }

    // FASE COMIDA / Fallback da Caça
    final food = _bestFood();
    if (food != null) {
      _seekFood(food);
      return;
    }

    // Se não houver comida nem presas, caça oportunista (se estiver perto)
    if (!isHuntPhase) {
      final prey = _findPrey(radiusSq: _huntRadiusSq);
      if (prey != null) {
        _attackPrey(prey);
        return;
      }
    }

    // ── Fallback final: Exploração ─────────────────────────────────────────
    _bot.isBoosting = false;
    _state = _BotState.explore;
    _doExplore(world);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Força de Perigo (Fuga de Maiores)
  // ─────────────────────────────────────────────────────────────────────────

  bool _applyDangerForce() {
    _force.setZero();
    bool foundThreat = false;
    double closestDistSq = double.infinity;

    // Distância de fuga baseada no tamanho do bot (quanto maior o bot, mais longe ele percebe)
    final double currentFleeRadius = _fleeRadius + (_bot.length * 0.5);
    final double dangerRSq = currentFleeRadius * currentFleeRadius;

    void checkThreat(Vector2 otherHead, int otherLength) {
      // Só considera ameaça se a outra cobra for maior que o bot atual
      // (Damos uma margem de 1 segmento para evitar fugas desnecessárias por igualdade)
      if (otherLength <= _bot.length + 1) return;

      final double distSq = _headPos.distanceToSquared(otherHead);
      if (distSq < dangerRSq) {
        _diff.setFrom(_headPos);
        _diff.sub(otherHead); // Vetor que aponta para longe da ameaça

        // Peso da fuga aumenta quanto mais perto a ameaça está
        double weight =
            (1.0 - (sqrt(distSq) / currentFleeRadius)).clamp(0.0, 1.0);
        _diff.normalize();
        _diff.scale(weight * 10.0); // Multiplicador de força de fuga

        _force.add(_diff);
        foundThreat = true;
        if (distSq < closestDistSq) closestDistSq = distSq;
      }
    }

    // Checar o jogador
    final p = _bot.engine.player;
    if (p.isAlive && p.segments.isNotEmpty) {
      checkThreat(p.segments.first, p.length);
    }

    // Checar outros bots
    for (final other in _bot.engine.bots) {
      if (other == _bot || !other.isAlive || other.segments.isEmpty) continue;
      checkThreat(other.segments.first, other.length);
    }

    if (foundThreat) {
      _force.normalize();
      // Aplica a direção de fuga suavemente para não parecer robótico demais
      _bot.botTargetDirection.lerp(_force, 0.85);

      // LOGICA DE BOOST: Se a cobra maior estiver muito perto, o bot "se assusta" e acelera
      // (Só usa boost se tiver tamanho suficiente para não morrer sumindo)
      if (closestDistSq < (150 * 150) && _bot.length > kPlayerMinSegments + 2) {
        _bot.isBoosting = true;
      } else {
        _bot.isBoosting = false;
      }

      _state = _BotState.flee;
      _stateTimer = 0;
      return true;
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Demais funções (Zone, Wall, Food, Prey, Explore) - Mantidas e Otimizadas
  // ─────────────────────────────────────────────────────────────────────────

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

    if (urgency >= 0.75) {
      _bot.botTargetDirection.setFrom(_diff);
    } else {
      _bot.botTargetDirection.lerp(_diff, 0.7 + urgency * 0.3);
    }

    _bot.isBoosting = urgency >= _zoneBoostThr;
    _state = _BotState.flee;
    _stateTimer = 0;
    return true;
  }

  bool _applyWallForce(Vector2 world) {
    _force.setZero();
    bool near = false;

    if (_headPos.x < _wallMargin) {
      _force.x = 1;
      near = true;
    } else if (_headPos.x > world.x - _wallMargin) {
      _force.x = -1;
      near = true;
    }

    if (_headPos.y < _wallMargin) {
      _force.y = 1;
      near = true;
    } else if (_headPos.y > world.y - _wallMargin) {
      _force.y = -1;
      near = true;
    }

    if (near) {
      _force.normalize();
      _bot.botTargetDirection.lerp(_force, 0.9);
      _bot.isBoosting = false;
      _state = _BotState.flee;
      return true;
    }
    return false;
  }

  Food? _bestFood() {
    Food? best;
    double maxScore = -1;
    final engine = _bot.engine;

    for (final food in engine.foods) {
      final double dSq = _headPos.distanceToSquared(food.position);
      if (dSq > _visionRadiusSq) continue;

      if (engine.battleActive) {
        final distToCenterSq =
            food.position.distanceToSquared(engine.zoneCenter);
        final r = engine.zoneRadius;
        if (distToCenterSq > r * r) continue;
      }

      final double score = food.value / (sqrt(dSq) + 1);
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
    _bot.botTargetDirection.lerp(_diff, 0.7);
    _bot.isBoosting = false;
    _state = _BotState.hunt;
  }

  Vector2? _findPrey({required double radiusSq}) {
    Vector2? bestPos;
    double bestDistSq = double.infinity;

    void check(bool isAlive, List<dynamic> segs, int len) {
      if (!isAlive || segs.isEmpty) return;
      if (len + _huntSizeLead > _bot.length) return;
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

    final double precision = distSq < _killZoneRadiusSq ? 0.95 : 0.75;
    _bot.botTargetDirection.lerp(_diff, precision);

    _bot.isBoosting =
        distSq < _killZoneRadiusSq && _bot.length > kPlayerMinSegments + 5;
    _state = _BotState.hunt;
  }

  void _doExplore(Vector2 world) {
    if (_exploreTarget == null || _exploreTargetTimer <= 0) {
      _exploreTarget = _pickExploreTarget(world);
      _exploreTargetTimer = 4.0 + _bot.rng.nextDouble() * 4.0;
    }
    if (_exploreTarget != null) {
      _diff.setFrom(_exploreTarget!);
      _diff.sub(_headPos);
      _diff.normalize();
      _bot.botTargetDirection.lerp(_diff, 0.6);
    }
  }

  Vector2 _pickExploreTarget(Vector2 world) {
    final engine = _bot.engine;
    if (engine.battleActive) {
      final center = engine.zoneCenter;
      final safeRadius =
          (engine.zoneRadius - _zoneMargin * 1.2).clamp(80.0, double.infinity);
      final double angle = _bot.rng.nextDouble() * pi * 2;
      final double dist = _bot.rng.nextDouble() * safeRadius;
      return Vector2(
          center.x + cos(angle) * dist, center.y + sin(angle) * dist);
    }
    return Vector2(
        _bot.rng.nextDouble() * world.x, _bot.rng.nextDouble() * world.y);
  }
}
