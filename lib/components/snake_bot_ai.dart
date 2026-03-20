// lib/components/snake_bot_ai.dart
// IA dos bots: faminta, esquiva de tudo, caça bots menores.
import 'dart:math' show Random, pi, atan2, cos, sin, sqrt, min;
import 'package:flame/components.dart' show Vector2;
import '../game/snake_engine.dart';
import '../utils/constants.dart';
import 'food.dart';

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

  // Intervalo de decisão: 60ms — reage rápido
  static const double _aiInterval = 0.06;
  double _aiTimer = 0;

  // Cooldown para não mudar de ideia muito rápido em fuga
  double _escapeCooldown = 0;
  // Direção de escape salva
  Vector2? _escapeDir;

  void tickAI(double dt) {
    if (_escapeCooldown > 0) _escapeCooldown -= dt;
    _aiTimer += dt;
    if (_aiTimer >= _aiInterval) {
      _aiTimer = 0;
      _decide();
    }
  }

  void _decide() {
    if (segments.isEmpty) return;
    final head = segments.first;
    final world = engine.worldSize;

    // ── PRIORIDADE 1: Parede — fuga imediata com antecedência ──
    const double safeMargin = 350.0;
    Vector2 wallPush = Vector2.zero();
    double wallUrgency = 0;

    void addWall(double dist, Vector2 dir) {
      if (dist < safeMargin) {
        final f = (1.0 - dist / safeMargin);
        wallPush += dir * f;
        if (f > wallUrgency) wallUrgency = f;
      }
    }

    addWall(head.x, Vector2(1, 0));
    addWall(world.x - head.x, Vector2(-1, 0));
    addWall(head.y, Vector2(0, 1));
    addWall(world.y - head.y, Vector2(0, -1));

    if (wallUrgency > 0.25) {
      // Combina direção atual com empurrão da parede
      botTargetDirection =
          (botTargetDirection + wallPush * (3.0 + wallUrgency * 4.0))
              .normalized();
      _escapeCooldown = 0.2;
      return;
    }

    // ── PRIORIDADE 2: Perigo de colisão com corpos ─────────────
    if (_escapeCooldown <= 0) {
      final danger = _calcDangerForce(head);
      if (danger != null) {
        botTargetDirection =
            (botTargetDirection + danger * 5.0).normalized();
        _escapeCooldown = 0.25;
        _escapeDir = botTargetDirection.clone();
        return;
      }
    } else if (_escapeDir != null) {
      // Continua na direção de escape por um tempo
      botTargetDirection = _escapeDir!;
      return;
    }

    // ── PRIORIDADE 3: Comida — modo faminto extremo ────────────
    final bestFood = _findBestFood(head);
    if (bestFood != null) {
      final toFood = (bestFood.position - head).normalized();
      // Suaviza a virada para não bater em nada no caminho
      botTargetDirection =
          (botTargetDirection * 0.3 + toFood * 0.7).normalized();
      botWanderTimer = 1.0;
      return;
    }

    // ── PRIORIDADE 4: Caça bots menores ────────────────────────
    if (length > 25) {
      final prey = _findPrey(head);
      if (prey != null) {
        botTargetDirection = (prey - head).normalized();
        return;
      }
    }

    // ── PRIORIDADE 5: Wander inteligente (vai ao centro) ───────
    botWanderTimer -= _aiInterval;
    if (botWanderTimer <= 0) {
      botWanderTimer = 0.4 + rng.nextDouble() * 0.6;
      final center = world / 2;
      final toCenter = center - head;
      final distCenter = toCenter.length;

      final double cur = atan2(botTargetDirection.y, botTargetDirection.x);
      double delta = (rng.nextDouble() - 0.5) * kBotWanderTurnAngle * 1.5;

      // Puxa suavemente para o centro se estiver longe
      if (distCenter > 1500) {
        final centerAngle = atan2(toCenter.y, toCenter.x);
        delta += (centerAngle - cur) * 0.3;
      }
      botTargetDirection =
          Vector2(cos(cur + delta), sin(cur + delta)).normalized();
    }
  }

  /// Calcula força de repulsão de todos os obstáculos próximos.
  Vector2? _calcDangerForce(Vector2 head) {
    Vector2 force = Vector2.zero();
    bool found = false;

    // Raio de perigo baseado no tamanho do bot (maior = mais cauteloso)
    final double dangerR = 120.0 + length * 0.5;
    final double dangerSq = dangerR * dangerR;

    // Corpo do player
    if (engine.player.isAlive) {
      final segs = engine.player.segments;
      for (int s = 2; s < segs.length; s += 3) {
        final dx = head.x - segs[s].x;
        final dy = head.y - segs[s].y;
        final sq = dx * dx + dy * dy;
        if (sq < dangerSq && sq > 1) {
          final d = sqrt(sq);
          force += Vector2(dx / d, dy / d) * (1.0 - sq / dangerSq) * 2.0;
          found = true;
        }
      }
      // Cabeça do player = perigo extremo
      final ph = engine.player.headPosition;
      final pdx = head.x - ph.x;
      final pdy = head.y - ph.y;
      final psq = pdx * pdx + pdy * pdy;
      if (psq < dangerSq && psq > 1) {
        final d = sqrt(psq);
        force += Vector2(pdx / d, pdy / d) * (1.0 - psq / dangerSq) * 4.0;
        found = true;
      }
    }

    // Corpo e cabeça de outros bots
    for (final bot in engine.bots) {
      if (bot == this || !bot.isAlive) continue;
      // Cabeça de bot maior — perigo extremo
      if (bot.length >= length * 0.8) {
        final bh = bot.headPosition;
        final dx = head.x - bh.x;
        final dy = head.y - bh.y;
        final sq = dx * dx + dy * dy;
        if (sq < dangerSq && sq > 1) {
          final d = sqrt(sq);
          force += Vector2(dx / d, dy / d) * (1.0 - sq / dangerSq) * 4.0;
          found = true;
        }
      }
      // Corpo
      final segs = bot.segments;
      for (int s = 2; s < segs.length; s += 3) {
        final dx = head.x - segs[s].x;
        final dy = head.y - segs[s].y;
        final sq = dx * dx + dy * dy;
        if (sq < dangerSq && sq > 1) {
          final d = sqrt(sq);
          force += Vector2(dx / d, dy / d) * (1.0 - sq / dangerSq) * 1.5;
          found = true;
        }
      }
    }

    if (!found || force.length2 < 0.01) return null;
    return force.normalized();
  }

  /// Encontra a melhor comida: valor alto + perto + sem obstáculo no caminho.
  Food? _findBestFood(Vector2 head) {
    // Raio de visão enorme — bots são muito famintos
    const double visionSq = 1200.0 * 1200.0;
    Food? best;
    double bestScore = -1;

    for (final food in engine.foods) {
      final dx = food.position.x - head.x;
      final dy = food.position.y - head.y;
      final sq = dx * dx + dy * dy;
      if (sq > visionSq) continue;

      // Score: valor da comida / distância (ponderado)
      final score = (food.value * 15.0) / (sq + 50.0);
      if (score > bestScore) {
        bestScore = score;
        best = food;
      }
    }

    // Se não achou nada no raio, pega a comida mais próxima de qualquer lugar
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

  /// Procura bot menor para caçar.
  Vector2? _findPrey(Vector2 head) {
    const double huntSq = 600.0 * 600.0;
    double best = double.infinity;
    Vector2? target;

    for (final bot in engine.bots) {
      if (bot == this || !bot.isAlive) continue;
      if (bot.length >= length * 0.65) continue; // só caça bem menores
      final sq = bot.headPosition.distanceToSquared(head);
      if (sq < huntSq && sq < best) {
        best = sq;
        target = bot.headPosition;
      }
    }
    return target;
  }
}
