import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection, Shadow, FontWeight;

import '../game/snake_engine.dart';
import '../services/haptic_service.dart';
import 'food.dart';
import 'snake_bot_ai.dart';
import 'snake_bot_accessories.dart' hide BotPersonalityType;
import 'snake_bot_renderer.dart';
import 'bot/bot_state.dart';
import 'bot/bot_movement.dart';
import 'bot/bot_paints.dart';
import '../utils/constants.dart';

class SnakeBot extends Component
    with
        BotState,
        BotMovement,
        BotPaints,
        BotAI,
        BotAccessoryRenderer,
        BotRenderer {
  // ── VARIÁVEIS DE ESTADO (CORREÇÃO DOS ERROS DE "UNDEFINED") ──
  int score = 0;
  int foodEaten = 0;
  int kills = 0;

  // ── OTIMIZAÇÃO: Variáveis de Reuso (Zero Alocação no Loop) ──
  final Vector2 _tempVec = Vector2.zero();
  final Vector2 _moveDelta = Vector2.zero();
  final Vector2 _headPos = Vector2.zero();

  @override
  final SnakeEngine engine;
  final int botId;
  final String name;

  @override
  final Color bodyColor;
  @override
  final Color bodyColorDark;

  final BotPersonalityType personality;

  Vector2 botDirection = Vector2(1, 0);
  Vector2 botTargetDirection = Vector2(1, 0);
  double botWanderTimer = 0.0;

  @override
  double accTimer = 0.0;
  final Random rng = Random();

  int get length => segments.length;

  // ── Sistema de Level ─────────────────────
  int level = 1;
  double levelUpTimer = 0.0;
  int _starsForLevel = 0;
  int _foodForLevel = 0;
  int _killsForLevel = 0;

  // ── Crescimento com acumulador ───────────
  int _growAccum = 0;
  static const int _kGrowThreshold = 10;

  late TextPainter _namePainter;
  @override
  TextPainter get namePainter => _namePainter;

  // DEPOIS
  double difficultyOverride; // ← adicione esta linha como campo da classe

  SnakeBot({
    required this.botId,
    required this.name,
    required this.engine,
    required this.bodyColor,
    required this.bodyColorDark,
    required this.personality,
    this.difficultyOverride = 0.5, // ← adicione esta linha no construtor
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    botHeadPaint.color = bodyColor;
    _buildNamePainter();
    respawn();
  }

  void _buildNamePainter() {
    _namePainter = TextPainter(
      text: TextSpan(
        text: '$name (Lv. $level)',
        style: TextStyle(
          color: bodyColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(
                color: Color(0xFF000000), blurRadius: 4, offset: Offset(1, 1))
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void respawn() {
    resetState();
    segments.clear();

    // Reset total
    score = 0;
    foodEaten = 0;
    kills = 0;
    level = 1;
    levelUpTimer = 0.0;
    _starsForLevel = 0;
    _foodForLevel = 0;
    _killsForLevel = 0;
    _growAccum = 0;

    _buildNamePainter();

    final Vector2 spawnPos = _generateValidSpawnPos();
    final double angle = rng.nextDouble() * pi * 2;
    botDirection.setValues(cos(angle), sin(angle));
    botTargetDirection.setFrom(botDirection);

    for (int i = 0; i < kBotInitialSegments; i++) {
      segments.add(spawnPos - botDirection * (kBotSegmentSpacing * i));
    }
    isAlive = true;
  }

  Vector2 _generateValidSpawnPos() {
    _tempVec.setZero();
    int attempts = 0;
    do {
      _tempVec.setValues(
        kWorldMargin +
            rng.nextDouble() * (engine.worldSize.x - kWorldMargin * 2),
        kWorldMargin +
            rng.nextDouble() * (engine.worldSize.y - kWorldMargin * 2),
      );
      attempts++;
    } while (attempts < 20 &&
        engine.player.isAlive &&
        engine.player.segments.isNotEmpty &&
        _tempVec.distanceTo(engine.player.segments.first) < 800);
    return _tempVec.clone();
  }

  @override
  void update(double dt) {
    if (!isAlive || segments.isEmpty) return;

    accTimer += dt;

    if (levelUpTimer > 0) {
      levelUpTimer = (levelUpTimer - dt).clamp(0.0, 10.0);
      if (levelUpTimer == 0.0) _buildNamePainter();
    }

    tickAI(dt);
    _updateBoostLogic(dt);

    final double t = (kBotTurnLerp * dt).clamp(0.0, 1.0);
    botDirection.lerp(botTargetDirection, t);
    if (botDirection.length2 > 0) botDirection.normalize();

    moveSegments(dt, botDirection, isBoosting, engine.worldSize);

    _checkFoodCollisions();
    _checkSnakeCollisions();
  }

  void _updateBoostLogic(double dt) {
    if (isBoosting && segments.length > kPlayerMinSegments) {
      boostDrainAccum += kPlayerBoostDrain * dt;
      if (boostDrainAccum >= 1.0) {
        boostDrainAccum -= 1.0;
        if (segments.isNotEmpty) segments.removeLast();
      }
    }
  }

  void _checkFoodCollisions() {
    // 🛡️ ADICIONE ESTA TRAVA AQUI:
    if (segments.isEmpty || !isAlive || engine.foods.isEmpty) return;

    _headPos.setFrom(segments.first);
    final double er = headRadius + kEatRadius;
    final double erSq = er * er;

    // Use o loop for comum, mas com uma checagem extra de segurança
    for (int i = engine.foods.length - 1; i >= 0; i--) {
      // 🛡️ Outra trava: se o jogo resetar no meio do loop, o i pode ficar inválido
      if (i >= engine.foods.length) continue;

      final food = engine.foods[i];
      if (food.position.distanceToSquared(_headPos) < erSq) {
        engine.consumeFood(this, food);
        grow(food.value);
      }
    }
  }

  void _checkSnakeCollisions() {
    if (segments.isEmpty || !isAlive) return;
    _headPos.setFrom(segments.first);
    final double headR = headRadius;

    // Colisão com Player
    if (engine.player.isAlive) {
      final double pHeadR = engine.player.headRadius * 0.8;
      final double limitSq = (headR + pHeadR) * (headR + pHeadR);

      for (final segment in engine.player.segments) {
        if (_headPos.distanceToSquared(segment) < limitSq) {
          die(killedByPlayer: true);
          return;
        }
      }
    }

    // Colisão com outros Bots
    for (final otherBot in engine.bots) {
      if (otherBot == this || !otherBot.isAlive) continue;

      final double bHeadR = otherBot.headRadius * 0.8;
      final double limitSq = (headR + bHeadR) * (headR + bHeadR);

      for (final segment in otherBot.segments) {
        if (_headPos.distanceToSquared(segment) < limitSq) {
          die();
          return;
        }
      }
    }
  }

  void grow(int amount) {
    score += amount;
    foodEaten += amount;

    _growAccum += amount;
    while (_growAccum >= _kGrowThreshold) {
      _growAccum -= _kGrowThreshold;
      if (segments.isNotEmpty) {
        segments.add(segments.last.clone());
      }
    }

    _checkLevelMilestones(amount);
  }

  void _checkLevelMilestones(int amount) {
    if (amount >= 5) {
      _starsForLevel++;
      if (_starsForLevel >= 2) {
        _starsForLevel = 0;
        _gainLevel();
      }
    } else {
      _foodForLevel += amount;
      while (_foodForLevel >= 10) {
        _foodForLevel -= 10;
        _gainLevel();
      }
    }
  }

  void _gainLevel() {
    level++;
    levelUpTimer = 2.0;
    _buildNamePainter();
  }

  void registerKill() {
    kills++;
    _killsForLevel++;
    if (_killsForLevel >= 1) {
      _killsForLevel = 0;
      _gainLevel();
    }
    // Haptic no bot é opcional, deixei para manter o padrão
    HapticService.instance.kill();
  }

  void die({bool killedByPlayer = false}) {
    if (!isAlive) return;
    isAlive = false;

    // Transforma corpo em comida (sem chamar removeFromParent)
    for (var i = 0; i < segments.length; i += 2) {
      engine.foods.add(Food.snakeMass(
          position: segments[i].clone(), segmentColor: bodyColor));
    }

    if (killedByPlayer) {
      engine.player.registerKill();
      HapticService.instance.kill();
    }

    segments.clear();
    engine.scheduleBotRespawn(this);
  }

  @override
  double get headRadius =>
      kBotHeadRadius + (segments.length * 0.02).clamp(0.0, 5.0);

  @override
  void render(Canvas canvas) => renderBot(canvas);
}
