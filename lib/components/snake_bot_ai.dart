// lib/components/snake_bot_ai.dart
// IA dos bots com 3 estados: HUNT (caça comida/presas), FLEE (fuga), EXPLORE (explorar)
import 'dart:math';
import 'package:flame/components.dart' show Vector2;
import '../game/snake_engine.dart';
import 'food.dart';

enum _BotState { hunt, flee, explore }

mixin BotAI {
  SnakeEngine get engine;
  List<Vector2> get segments;
  Random get rng;
  bool get isBoosting;
  int get length;
  double get headRadius;

  Vector2 get botDirection;
  set botDirection(Vector2 v);
  Vector2 get botTargetDirection;
  set botTargetDirection(Vector2 v);
  double get botWanderTimer;
  set botWanderTimer(double v);

  // ── Estado interno ────────────────────────────────────────
  _BotState _state = _BotState.explore;
  double _stateTimer = 0; // tempo no estado atual
  double _aiTimer = 0;
  Vector2? _exploreTarget; // ponto alvo no modo explorar
  double _exploreTargetTimer = 0;

  static const double _aiInterval = 0.08; // decisão a cada 80ms
  static const double _visionRadius = 1400.0;
  static const double _fleeRadius = 180.0;
  static const double _wallMargin = 300.0;

  void tickAI(double dt) {
    _aiTimer += dt;
    _stateTimer += dt;
    _exploreTargetTimer -= dt;
    if (_aiTimer >= _aiInterval) {
      _aiTimer = 0;
      _decide();
    }
  }

  void _decide() {
    if (segments.isEmpty) return;
    final head = segments.first;
    final world = engine.worldSize;

    // ── 1. Parede — sempre prioritário ───────────────────────
    final wallForce = _wallForce(head, world);
    if (wallForce != null) {
      botTargetDirection = wallForce;
      _state = _BotState.flee;
      return;
    }

    // ── 2. Perigo de colisão — fuga ───────────────────────────
    final danger = _dangerForce(head);
    if (danger != null) {
      botTargetDirection = danger;
      _state = _BotState.flee;
      _stateTimer = 0;
      return;
    }

    // Se acabou de fugir, mantém estado por 0.3s para não oscilar
    if (_state == _BotState.flee && _stateTimer < 0.30) return;

    // ── 3. Comida próxima — HUNT ──────────────────────────────
    final food = _bestFood(head);
    if (food != null) {
      final toFood = (food.position - head).normalized();
      // Suaviza curva para evitar colisão no caminho
      botTargetDirection =
          (botTargetDirection * 0.25 + toFood * 0.75).normalized();
      _state = _BotState.hunt;
      return;
    }

    // ── 4. Caça bot menor (só se grande o suficiente) ─────────
    if (length > 20) {
      final prey = _findPrey(head);
      if (prey != null) {
        botTargetDirection = (prey - head).normalized();
        _state = _BotState.hunt;
        return;
      }
    }

    // ── 5. EXPLORE — move em linha reta até um alvo fixo ──────
    _state = _BotState.explore;
    _doExplore(head, world);
  }

  // ─────────────────────────────────────────────────────────
  // EXPLORE: escolhe um ponto alvo e vai direto até lá
  // Evita o "ficar em círculos" do wander randômico
  // ─────────────────────────────────────────────────────────
  void _doExplore(Vector2 head, Vector2 world) {
    // Troca de alvo se chegou perto ou tempo expirou
    final needNew = _exploreTarget == null ||
        _exploreTargetTimer <= 0 ||
        head.distanceTo(_exploreTarget!) < 200;

    if (needNew) {
      _exploreTarget = _pickExploreTarget(head, world);
      _exploreTargetTimer = 3.0 + rng.nextDouble() * 3.0; // 3-6s por alvo
    }

    if (_exploreTarget != null) {
      final toTarget = (_exploreTarget! - head).normalized();
      // Suave para não girar bruscamente
      botTargetDirection =
          (botTargetDirection * 0.15 + toTarget * 0.85).normalized();
    }
  }

  // Escolhe um ponto de exploração inteligente:
  // - Preferencialmente onde tem mais comida
  // - Longe de outros bots
  // - Dentro dos limites seguros
  Vector2 _pickExploreTarget(Vector2 head, Vector2 world) {
    final margin = _wallMargin + 100;
    final safeW = world.x - margin * 2;
    final safeH = world.y - margin * 2;

    // Tenta 8 candidatos e escolhe o melhor
    Vector2? best;
    double bestScore = -1;

    for (int i = 0; i < 8; i++) {
      final candidate = Vector2(
        margin + rng.nextDouble() * safeW,
        margin + rng.nextDouble() * safeH,
      );

      // Conta comida próxima ao candidato
      double foodScore = 0;
      for (final f in engine.foods) {
        final d = f.position.distanceTo(candidate);
        if (d < 400) foodScore += f.value / (d + 1);
      }

      // Penaliza se está muito perto de outros bots
      double botPenalty = 0;
      for (final bot in engine.bots) {
        if (bot == this || !bot.isAlive) continue;
        final d = bot.headPosition.distanceTo(candidate);
        if (d < 300) botPenalty += 300 - d;
      }

      // Prefere pontos em direções diferentes da atual
      final toCandidate = (candidate - head).normalized();
      final dirBonus = toCandidate.dot(botTargetDirection) < 0
          ? 0.0 // na direção oposta: sem bônus
          : toCandidate.dot(botTargetDirection) * 200;

      final score = foodScore - botPenalty * 0.5 + dirBonus;
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    return best ?? Vector2(world.x / 2, world.y / 2);
  }

  // ─────────────────────────────────────────────────────────
  // WALL FORCE
  // ─────────────────────────────────────────────────────────
  Vector2? _wallForce(Vector2 head, Vector2 world) {
    Vector2 push = Vector2.zero();
    double urgent = 0;

    void check(double dist, Vector2 dir) {
      if (dist < _wallMargin) {
        final f = 1.0 - dist / _wallMargin;
        push += dir * f;
        if (f > urgent) urgent = f;
      }
    }

    check(head.x, Vector2(1, 0));
    check(world.x - head.x, Vector2(-1, 0));
    check(head.y, Vector2(0, 1));
    check(world.y - head.y, Vector2(0, -1));

    if (urgent < 0.20) return null;
    return (botTargetDirection + push * (3.0 + urgent * 5.0)).normalized();
  }

  // ─────────────────────────────────────────────────────────
  // DANGER FORCE — detecta colisões iminentes
  // ─────────────────────────────────────────────────────────
  Vector2? _dangerForce(Vector2 head) {
    Vector2 force = Vector2.zero();
    bool found = false;

    final dangerR = _fleeRadius + length * 0.4;
    final dangerSq = dangerR * dangerR;

    void pushFrom(Vector2 pos, double multiplier) {
      final dx = head.x - pos.x;
      final dy = head.y - pos.y;
      final sq = dx * dx + dy * dy;
      if (sq < dangerSq && sq > 1) {
        final d = sqrt(sq);
        force += Vector2(dx / d, dy / d) * (1.0 - sq / dangerSq) * multiplier;
        found = true;
      }
    }

    // Cabeça do player — máximo perigo
    if (engine.player.isAlive) {
      pushFrom(engine.player.headPosition, 5.0);
      // Corpo do player (amostrado de 3 em 3)
      final ps = engine.player.segments;
      for (int i = 3; i < ps.length; i += 3) pushFrom(ps[i], 2.0);
    }

    // Outros bots
    for (final bot in engine.bots) {
      if (bot == this || !bot.isAlive) continue;
      // Cabeça de bots do mesmo tamanho ou maior
      if (bot.length >= length * 0.75) pushFrom(bot.headPosition, 4.0);
      // Corpo
      final bs = bot.segments;
      for (int i = 3; i < bs.length; i += 3) pushFrom(bs[i], 1.5);
    }

    if (!found || force.length2 < 0.01) return null;

    // Combina fuga com perpendicular para não bater em frente
    final flee = force.normalized();
    final perp = Vector2(-botDirection.y, botDirection.x);
    final dot = flee.dot(perp);
    // Escolhe o perpendicular que vai na direção de fuga
    final chosenPerp = dot >= 0 ? perp : -perp;
    return (flee * 0.7 + chosenPerp * 0.3).normalized();
  }

  // ─────────────────────────────────────────────────────────
  // BEST FOOD
  // ─────────────────────────────────────────────────────────
  Food? _bestFood(Vector2 head) {
    final visionSq = _visionRadius * _visionRadius;
    Food? best;
    double bestScore = -1;

    for (final food in engine.foods) {
      final sq = food.position.distanceToSquared(head);
      if (sq > visionSq) continue;
      // Score: valor / raiz da distância (valoriza comida valiosa perto)
      final score = food.value * 10.0 / (sqrt(sq) + 20.0);
      if (score > bestScore) {
        bestScore = score;
        best = food;
      }
    }

    // Fallback: comida mais próxima em qualquer lugar
    if (best == null) {
      double nearest = double.infinity;
      for (final food in engine.foods) {
        final sq = food.position.distanceToSquared(head);
        if (sq < nearest) {
          nearest = sq;
          best = food;
        }
      }
    }

    return best;
  }

  // ─────────────────────────────────────────────────────────
  // FIND PREY
  // ─────────────────────────────────────────────────────────
  Vector2? _findPrey(Vector2 head) {
    const double huntSq = 700.0 * 700.0;
    double best = double.infinity;
    Vector2? target;

    for (final bot in engine.bots) {
      if (bot == this || !bot.isAlive) continue;
      if (bot.length >= length * 0.65) continue;
      final sq = bot.headPosition.distanceToSquared(head);
      if (sq < huntSq && sq < best) {
        best = sq;
        target = bot.headPosition;
      }
    }
    return target;
  }
}
