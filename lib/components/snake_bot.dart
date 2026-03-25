import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show TextPainter, TextSpan, TextStyle, TextDirection, Shadow, FontWeight;

import '../game/snake_engine.dart';
import '../services/haptic_service.dart';
import 'food.dart';
// Removido import não utilizado de death_particle
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
  final SnakeEngine engine;
  final int botId;
  final String name;

  final Color bodyColor;
  final Color bodyColorDark;

  final BotPersonalityType personality;

  Vector2 botDirection = Vector2(1, 0);
  Vector2 botTargetDirection = Vector2(1, 0);
  double botWanderTimer = 0.0;
  double accTimer = 0.0;
  final Random rng = Random();

  int get length => segments.length;

  late TextPainter _namePainter;
  @override
  TextPainter get namePainter => _namePainter;

  SnakeBot({
    required this.botId,
    required this.name,
    required this.engine,
    required this.bodyColor,
    required this.bodyColorDark,
    required this.personality,
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
          shadows: const [Shadow(color: Color(0xFF000000), blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void respawn() {
    resetState();
    segments.clear();
    Vector2 spawnPos = _generateValidSpawnPos();
    final double angle = rng.nextDouble() * pi * 2;
    botDirection = botTargetDirection = Vector2(cos(angle), sin(angle));
    for (int i = 0; i < kBotInitialSegments; i++) {
      segments.add(spawnPos - botDirection * (kBotSegmentSpacing * i));
    }
    isAlive = true;
  }

  Vector2 _generateValidSpawnPos() {
    Vector2 pos;
    int attempts = 0;
    do {
      pos = Vector2(
        kWorldMargin +
            rng.nextDouble() * (engine.worldSize.x - kWorldMargin * 2),
        kWorldMargin +
            rng.nextDouble() * (engine.worldSize.y - kWorldMargin * 2),
      );
      attempts++;
    } while (attempts < 20 &&
        engine.player.isAlive &&
        engine.player.segments.isNotEmpty &&
        pos.distanceTo(engine.player.segments.first) < 800);
    return pos;
  }

  @override
  void update(double dt) {
    if (!isAlive) return;

    accTimer += dt;
    tickAI(dt);
    _updateBoostLogic(dt);

    final double t = (kBotTurnLerp * dt).clamp(0.0, 1.0);
    botDirection =
        (botDirection.clone()..lerp(botTargetDirection, t)).normalized();

    moveSegments(dt, botDirection, isBoosting, engine.worldSize);

    _checkFoodCollisions();
    _checkSnakeCollisions();
  }

  void _updateBoostLogic(double dt) {
    if (isBoosting && segments.length > kPlayerMinSegments) {
      boostDrainAccum += kPlayerBoostDrain * dt;
      if (boostDrainAccum >= 1.0) {
        boostDrainAccum -= 1.0;
        segments.removeLast();
      }
    }
  }

  void _checkFoodCollisions() {
    if (segments.isEmpty) return;
    final head = segments.first;
    final double er = headRadius + kEatRadius;

    // ✅ CORREÇÃO: Removendo da lista de forma segura
    for (int i = engine.foods.length - 1; i >= 0; i--) {
      final food = engine.foods[i];
      if (food.position.distanceTo(head) < er) {
        // Se sua classe Food não for um Component, você não chama removeFromParent
        // Você apenas remove da lista do motor
        engine.foods.removeAt(i);
        grow(food.value);
      }
    }
  }

  void _checkSnakeCollisions() {
    if (segments.isEmpty || !isAlive) return;
    final head = segments.first;
    final double headR = headRadius;

    if (engine.player.isAlive) {
      for (final segment in engine.player.segments) {
        if (head.distanceTo(segment) <
            (headR + engine.player.headRadius * 0.8)) {
          die(killedByPlayer: true);
          return;
        }
      }
    }

    for (final otherBot in engine.bots) {
      if (otherBot == this || !otherBot.isAlive) continue;
      for (final segment in otherBot.segments) {
        if (head.distanceTo(segment) < (headR + otherBot.headRadius * 0.8)) {
          die();
          return;
        }
      }
    }
  }

  void grow(int amount) {
    score += amount;
    growAccum += amount;
    while (growAccum >= 10) {
      growAccum -= 10;
      segments.add(segments.last.clone());
    }
  }

  void die({bool killedByPlayer = false}) {
    if (!isAlive) return;
    isAlive = false;

    // ✅ CORREÇÃO: Adicionando massa sem erro de tipo
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
