// lib/components/snake_bot.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart'
    show Colors, Color, TextPainter, TextSpan, TextStyle, TextDirection, Shadow;
import '../game/snake_engine.dart';
import '../game/engine_food.dart';
import '../services/haptic_service.dart';
import 'food.dart';
import 'death_particle.dart';
import 'snake_bot_ai.dart';
import 'snake_bot_accessories.dart';
import 'snake_bot_renderer.dart';
import '../utils/constants.dart';
import 'package:flame/components.dart';

typedef BotPersonality = BotPersonalityType;

class SnakeBot extends Component with BotAI, BotAccessoryRenderer, BotRenderer {
  @override
  final SnakeEngine engine;
  final int botId;
  final String name;
  @override
  final Color bodyColor;
  @override
  final Color bodyColorDark;
  final BotPersonality personality;

  @override
  final List<Vector2> segments = [];

  // ── BotAI ────────────────────────────────────────────────
  Vector2 _botDirection = Vector2(1, 0);
  Vector2 _botTargetDirection = Vector2(1, 0);
  double _botWanderTimer = 0.0;
  @override
  Vector2 get botDirection => _botDirection;
  @override
  set botDirection(Vector2 v) => _botDirection = v;
  @override
  Vector2 get botTargetDirection => _botTargetDirection;
  @override
  set botTargetDirection(Vector2 v) => _botTargetDirection = v;
  @override
  double get botWanderTimer => _botWanderTimer;
  @override
  set botWanderTimer(double v) => _botWanderTimer = v;
  @override
  final Random rng = Random();

  // ── Estado ───────────────────────────────────────────────
  bool _isBoosting = false;
  double _boostTimer = 0.0;
  double _boostDrainAccum = 0.0;
  bool isAlive = false;
  int score = 0;

  // ✅ Acumula pontos antes de crescer — igual ao player (1 seg a cada 10 pts)
  int _growAccum = 0;

  double _accTimerInternal = 0.0;
  @override
  double get accTimer => _accTimerInternal;
  @override
  bool get isBoosting => _isBoosting;

  // ── Paints ───────────────────────────────────────────────
  final Paint _botBodyPaintField = Paint();
  final Paint _botShadowPaintField = Paint()..color = const Color(0x28000000);
  final Paint _botHighlightPaintField = Paint()
    ..color = const Color(0x55FFFFFF);
  final Paint _botEyeWhiteField = Paint()..color = Colors.white;
  final Paint _botEyePupilField = Paint()..color = Colors.black;
  final Paint _botBoostGlowPaintField = Paint()
    ..color = const Color(0x40FFFFFF);
  late Paint _botHeadPaintField;

  @override
  Paint get botBodyPaint => _botBodyPaintField;
  @override
  Paint get botShadowPaint => _botShadowPaintField;
  @override
  Paint get botHighlightPaint => _botHighlightPaintField;
  @override
  Paint get botEyeWhite => _botEyeWhiteField;
  @override
  Paint get botEyePupil => _botEyePupilField;
  @override
  Paint get botBoostGlowPaint => _botBoostGlowPaintField;
  @override
  Paint get botHeadPaint => _botHeadPaintField;

  late TextPainter _namePainterField;
  @override
  TextPainter get namePainter => _namePainterField;

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
    _botHeadPaintField = Paint()..color = bodyColor;
    _buildNamePainter();
    respawn();
  }

  void _buildNamePainter() {
    _namePainterField = TextPainter(
      text: TextSpan(
        text: name,
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
    segments.clear();
    score = 0;
    _growAccum = 0; // ✅ reseta acumulador
    _isBoosting = false;
    _boostTimer = 0;
    _boostDrainAccum = 0;
    _botWanderTimer = rng.nextDouble() * kBotWanderInterval;
    _accTimerInternal = 0;

    Vector2 spawnPos;
    int attempts = 0;
    const double minDist = 800.0;
    do {
      spawnPos = Vector2(
        kWorldMargin +
            rng.nextDouble() * (engine.worldSize.x - kWorldMargin * 2),
        kWorldMargin +
            rng.nextDouble() * (engine.worldSize.y - kWorldMargin * 2),
      );
      attempts++;
    } while (attempts < 20 &&
        engine.player.isAlive &&
        engine.player.segments.isNotEmpty &&
        spawnPos.distanceTo(engine.player.segments.first) < minDist);

    final double angle = rng.nextDouble() * pi * 2;
    _botDirection = _botTargetDirection = Vector2(cos(angle), sin(angle));
    for (int i = 0; i < kBotInitialSegments; i++) {
      segments.add(spawnPos - _botDirection * (kBotSegmentSpacing * i));
    }
    isAlive = true;
  }

  @override
  void update(double dt) {
    if (!isAlive) return;
    _accTimerInternal += dt;
    tickAI(dt);
    _updateBoost(dt);
    _updateDirection(dt);
    _moveSegments(dt);
    _handleBoostDrain(dt);
    _checkFoodCollisions();
  }

  void _updateBoost(double dt) {
    if (_isBoosting) {
      _boostTimer -= dt;
      if (_boostTimer <= 0 || segments.length <= kPlayerMinSegments) {
        _isBoosting = false;
      }
    } else {
      if (segments.length > kPlayerMinSegments + 5 &&
          rng.nextDouble() < kBotBoostChance) {
        _isBoosting = true;
        _boostTimer = kBotBoostDuration;
      }
    }
  }

  void _updateDirection(double dt) {
    final double t = (kBotTurnLerp * dt).clamp(0.0, 1.0);
    final Vector2 lerped = _botDirection.clone()..lerp(_botTargetDirection, t);
    if (lerped.length2 > 0) lerped.normalize();
    _botDirection = lerped;
  }

  void _moveSegments(double dt) {
    final double speed = _isBoosting ? kBotBoostSpeed : kBotBaseSpeed;
    final Vector2 newHead = segments.first + _botDirection * (speed * dt);
    newHead.x = newHead.x % engine.worldSize.x;
    newHead.y = newHead.y % engine.worldSize.y;
    if (newHead.x < 0) newHead.x += engine.worldSize.x;
    if (newHead.y < 0) newHead.y += engine.worldSize.y;
    for (int i = segments.length - 1; i > 0; i--) {
      segments[i] = segments[i - 1].clone();
    }
    segments[0] = newHead;
  }

  void _handleBoostDrain(double dt) {
    if (!_isBoosting || segments.length <= kPlayerMinSegments) return;
    _boostDrainAccum += kPlayerBoostDrain * dt;
    while (_boostDrainAccum >= 1.0 && segments.length > kPlayerMinSegments) {
      _boostDrainAccum -= 1.0;
      final food = Food.snakeMass(
          position: segments.last.clone(), segmentColor: bodyColor);
      engine.foods.add(food);
      segments.removeLast();
    }
  }

  void _checkFoodCollisions() {
    final Vector2 head = segments.first;
    final double er = headRadius + kEatRadius;
    for (final food in List<Food>.from(engine.foods)) {
      if (food.position.distanceTo(head) < er) {
        engine.consumeFood(food, this);
        grow(food.value);
      }
    }
  }

  // ✅ Mesmo ritmo do player: 1 segmento a cada 10 pontos
  void grow(int amount) {
    score += amount;
    _growAccum += amount;
    while (_growAccum >= 10) {
      _growAccum -= 10;
      segments.add(segments.last.clone());
    }
  }

  void die({bool killedByPlayer = false}) {
    if (!isAlive) return;
    isAlive = false;
    final particles = DeathParticle.burst(
        engine: engine, center: segments.first.clone(), color: bodyColor);
    for (final p in particles) engine.add(p);
    engine.explodeSnake(segments, bodyColor);
    if (killedByPlayer) {
      engine.player.registerKill();
      HapticService.instance.kill();
    }
    engine.scheduleBotRespawn(this);
  }

  Vector2 get headPosition =>
      segments.isEmpty ? Vector2.zero() : segments.first;
  @override
  double get headRadius =>
      kBotHeadRadius + (segments.length * 0.02).clamp(0.0, 5.0);
  int get length => segments.length;

  @override
  void render(Canvas canvas) => renderBot(canvas);

  @override
  void renderHead(Canvas canvas, Offset pos, double hr) {
    canvas.drawCircle(pos + const Offset(2, 2), hr, botShadowPaint);
    if (_isBoosting) canvas.drawCircle(pos, hr + 3, botBoostGlowPaint);
    botHeadPaint.color = bodyColor;
    canvas.drawCircle(pos, hr, botHeadPaint);
    renderEyes(canvas, pos, hr);
    canvas.drawCircle(
        pos + Offset(-hr * 0.25, -hr * 0.25), hr * 0.32, botHighlightPaint);
    renderAccessoryForPersonality(personality, canvas, pos, hr);
  }
}
