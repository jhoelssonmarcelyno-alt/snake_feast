// lib/components/snake_player.dart
import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show
        Colors,
        Color,
        Offset,
        TextPainter,
        TextSpan,
        TextStyle,
        TextDirection,
        FontWeight,
        Shadow;
import '../game/snake_engine.dart';
import '../game/engine_food.dart';
import '../services/haptic_service.dart';
import '../services/score_service.dart';
import 'food.dart';
import 'death_particle.dart';
import 'expressions/expressions_mixin.dart';
import 'snake_player_renderer.dart';
import '../utils/constants.dart';
import 'package:flame/components.dart';

class SnakePlayer extends Component
    with DragCallbacks, PlayerExpressions, PlayerRenderer {
  // ── OTIMIZAÇÃO: Variáveis de Reuso (Zero Alocação no Loop) ──
  final Vector2 _tempHead = Vector2.zero();
  final Vector2 _moveDelta = Vector2.zero();

  double speed = 150.0;
  double _baseSpeed = kPlayerBaseSpeed;
  int _totalLevelBonus = 0;
  SnakeSkin skin;

  // ── PlayerExpressions overrides ──────────────────────────────
  @override
  Color get skinBodyColor => skin.bodyColor;
  @override
  Color get skinBodyColorDark => skin.bodyColorDark;
  @override
  Color get skinAccentColor => skin.accentColor;
  @override
  String get skinId => skin.id;
  @override
  Paint get eyeWhite => _eyeWhite;
  @override
  Paint get eyePupil => _eyePupil;

  // ── PlayerRenderer overrides ─────────────────────────────────
  @override
  SnakeEngine get engine => _engine;
  @override
  List<Vector2> get segments => _segments;
  @override
  bool get isAlive => _isAlive;
  @override
  bool get isBoosting => _isBoosting;
  @override
  double get headRadius =>
      kPlayerHeadRadius + (_segments.length * 0.03).clamp(0.0, 6.0);
  @override
  double get tongueTimer => _tongueTimer;
  @override
  Paint get bodyPaint => _bodyPaint;
  @override
  Paint get headPaint => _headPaint;
  @override
  Paint get shadowPaint => _shadowPaint;
  @override
  Paint get highlightPaint => _highlightPaint;
  @override
  Paint get boostGlowPaint => _boostGlowPaint;
  @override
  Paint get accentRingPaint => _accentRingPaint;
  @override
  TextPainter get namePainter => _namePainter;

  // ── Estado ───────────────────────────────────────────────────
  final List<Vector2> _segments = [];
  Vector2 _direction = Vector2(1, 0);
  Vector2 _targetDirection = Vector2(1, 0);
  bool _isBoosting = false;
  double _boostDrainAccum = 0.0;
  Vector2? _joystickOrigin;
  Vector2? _joystickCurrent;
  int? _activeTouchId;
  double _tongueTimer = 0.0;
  bool _isAlive = true;

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> killsNotifier = ValueNotifier<int>(0);

  int get score => scoreNotifier.value;
  set score(int value) => scoreNotifier.value = value;

  int get kills => killsNotifier.value;
  set kills(int value) => killsNotifier.value = value;

  int foodEaten = 0;
  int _coinsEarned = 0;
  int _diamondsEarned = 0;
  int _growAccum = 0;

  int level = 1;
  int _totalFoodEaten = 0;
  int _totalStarsEaten = 0;
  int _totalKills = 0;
  double levelUpTimer = 0.0;

  String name = 'Você';

  // ── Paints (Pré-alocados) ────────────────────────────────────
  final Paint _bodyPaint = Paint();
  final Paint _headPaint = Paint();
  final Paint _shadowPaint = Paint()..color = const Color(0x33000000);
  final Paint _highlightPaint = Paint()..color = const Color(0x70FFFFFF);
  final Paint _eyeWhite = Paint()..color = Colors.white;
  final Paint _eyePupil = Paint()..color = Colors.black;
  final Paint _boostGlowPaint = Paint()..color = const Color(0x44FFFFFF);
  final Paint _accentRingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  late TextPainter _namePainter;
  final SnakeEngine _engine;

  SnakePlayer({required SnakeEngine engine, required this.skin})
      : _engine = engine;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _applySkin();
    _buildNamePainter();
    _spawnAt(_engine.worldSize / 2);
  }

  void _applySkin() {
    _headPaint.color = skin.bodyColor;
    _accentRingPaint.color = skin.accentColor.withValues(alpha: 0.5);
  }

  void updateSkin(SnakeSkin newSkin) {
    skin = newSkin;
    _applySkin();
    _buildNamePainter();
  }

  void _buildNamePainter() {
    _namePainter = TextPainter(
      text: TextSpan(
        text: '$name (Lv. $level)',
        style: TextStyle(
          color: skin.accentColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Color(0xFF000000), blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _spawnAt(Vector2 pos) {
    _segments.clear();
    _direction.setValues(1, 0);
    _targetDirection.setValues(1, 0);
    score = kills = foodEaten = 0;
    _coinsEarned = 0;
    _diamondsEarned = 0;
    _growAccum = 0;
    _isBoosting = false;
    _boostDrainAccum = 0;
    _tongueTimer = 0;
    _isAlive = true;
    level = 1;
    _totalFoodEaten = 0;
    _totalStarsEaten = 0;
    _totalKills = 0;
    _totalLevelBonus = 0;
    speed = _baseSpeed;
    levelUpTimer = 0.0;
    for (int i = 0; i < kPlayerInitialSegments; i++) {
      _segments.add(pos - Vector2(kPlayerSegmentSpacing * i, 0));
    }
  }

  void _updateSpeedBonus() {
    final int bonusFromLevels = (level / 10).floor();
    if (bonusFromLevels > _totalLevelBonus) {
      _totalLevelBonus = bonusFromLevels;
      speed = _baseSpeed * (1 + (_totalLevelBonus / 100));
    }
  }

  // ── DragCallbacks ────────────────────────────────────────────
  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _activeTouchId = event.pointerId;
    _joystickOrigin = event.canvasPosition.clone();
    _joystickCurrent = event.canvasPosition.clone();
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (event.pointerId == _activeTouchId) {
      _joystickCurrent = event.canvasEndPosition.clone();
    }
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (event.pointerId == _activeTouchId) {
      _joystickOrigin = _joystickCurrent = null;
      _activeTouchId = null;
    }
    return true;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _joystickOrigin = _joystickCurrent = null;
    _activeTouchId = null;
    return true;
  }

  void setJoystick(Offset origin, Offset current) {
    _joystickOrigin = Vector2(origin.dx, origin.dy);
    _joystickCurrent = Vector2(current.dx, current.dy);
    _activeTouchId ??= -1;
  }

  void clearJoystick() {
    _joystickOrigin = _joystickCurrent = null;
    _activeTouchId = null;
  }

  void setBoost(bool active) {
    if (active && !_isBoosting && _segments.length > kPlayerMinSegments) {
      _isBoosting = true;
      HapticService.instance.boost();
    } else if (!active) {
      _isBoosting = false;
    }
  }

  @override
  void update(double dt) {
    if (!_isAlive) return;
    _tongueTimer += dt;
    if (levelUpTimer > 0) levelUpTimer = (levelUpTimer - dt).clamp(0.0, 10.0);
    _updateTargetFromJoystick();
    _updateDirection(dt);
    _moveSegments(dt);
    _handleBoostDrain(dt);
    _checkFoodCollisions();
  }

  void _updateTargetFromJoystick() {
    if (_joystickOrigin == null || _joystickCurrent == null) return;
    final Vector2 delta = _joystickCurrent! - _joystickOrigin!;
    if (delta.length < kJoystickDeadzone) return;
    _targetDirection.setFrom(delta.normalized());
  }

  void _updateDirection(double dt) {
    final double t = (kPlayerTurnLerp * dt).clamp(0.0, 1.0);
    _direction.lerp(_targetDirection, t);
    if (_direction.length2 > 0) _direction.normalize();
  }

  void _moveSegments(double dt) {
    final double currentSpeed =
        _isBoosting && _segments.length > kPlayerMinSegments
            ? speed * 1.8
            : speed;

    _moveDelta.setFrom(_direction);
    _moveDelta.scale(currentSpeed * dt);

    _tempHead.setFrom(_segments.first);
    _tempHead.add(_moveDelta);

    _tempHead.x = _tempHead.x.clamp(0.0, _engine.worldSize.x);
    _tempHead.y = _tempHead.y.clamp(0.0, _engine.worldSize.y);

    for (int i = _segments.length - 1; i > 0; i--) {
      _segments[i].setFrom(_segments[i - 1]);
    }
    _segments[0].setFrom(_tempHead);
  }

  void _handleBoostDrain(double dt) {
    if (!_isBoosting || _segments.length <= kPlayerMinSegments) {
      if (_isBoosting && _segments.length <= kPlayerMinSegments) {
        _isBoosting = false;
      }
      return;
    }
    _boostDrainAccum += kPlayerBoostDrain * dt;
    while (_boostDrainAccum >= 1.0 && _segments.length > kPlayerMinSegments) {
      _boostDrainAccum -= 1.0;
      final food = Food.boostMass(
          position: _segments.last.clone(), segmentColor: skin.bodyColor);
      _engine.foods.add(food);
      _segments.removeLast();
    }
  }

  void _checkFoodCollisions() {
    final Vector2 head = _segments.first;
    final double eatR = headRadius + kEatRadius;
    for (int i = _engine.foods.length - 1; i >= 0; i--) {
      final food = _engine.foods[i];
      if (food.position.distanceTo(head) < eatR) {
        _engine.consumeFood(this, food);
        grow(food.value);
        HapticService.instance.eat();
      }
    }
  }

  void grow(int amount) {
    score += amount;
    foodEaten += amount;

    if (amount == kFoodStarValue) {
      _totalStarsEaten++;
    } else {
      _totalFoodEaten++;
    }

    _checkRewardMilestones();
    _updateLevelByMilestones();

    _growAccum += amount;
    while (_growAccum >= 10) {
      _growAccum -= 10;
      _segments.add(_segments.last.clone());
    }
  }

  void _updateLevelByMilestones() {
    int newLevel = 1;
    newLevel += _totalFoodEaten ~/ 100;
    newLevel += _totalStarsEaten ~/ 10;
    newLevel += _totalKills;

    if (newLevel > level) {
      final int oldLevel = level;
      level = newLevel;
      _onLevelUp(oldLevel, level);
    }
  }

  void _onLevelUp(int oldLevel, int newLevel) {
    levelUpTimer = 2.0;
    HapticService.instance.boost();
    _updateSpeedBonus();
    _addLevelUpEffect();
  }

  void _addLevelUpEffect() {
    if (_segments.isEmpty) return;
    final particles = DeathParticle.burst(
      engine: _engine,
      center: _segments.first.clone(),
      color: const Color(0xFFFFD700),
      skinId: 'classic',
    );
    for (final p in particles) {
      _engine.add(p);
    }
  }

  void _checkRewardMilestones() {
    final int coinsOwed = foodEaten ~/ 50;
    if (coinsOwed > _coinsEarned) {
      ScoreService.instance.addCoins(coinsOwed - _coinsEarned);
      _coinsEarned = coinsOwed;
    }
    final int diamondsOwed = foodEaten ~/ 5000;
    if (diamondsOwed > _diamondsEarned) {
      ScoreService.instance.addDiamonds(diamondsOwed - _diamondsEarned);
      _diamondsEarned = diamondsOwed;
    }
  }

  void registerKill() {
    kills++;
    _totalKills++;
    _updateLevelByMilestones();
    HapticService.instance.kill();
  }

  void revive(Vector2 pos) {
    if (_isAlive) return;
    _spawnAt(pos);
  }

  void forceKill() {
    if (!_isAlive) return;
    _isAlive = false;
    _segments.clear();
    _isBoosting = false;
  }

  void die() {
    if (!_isAlive) return;
    _isAlive = false;
    HapticService.instance.die();
    final particles = DeathParticle.burst(
      engine: _engine,
      center: _segments.first.clone(),
      color: skin.bodyColor,
      skinId: skin.id,
    );
    for (final p in particles) _engine.add(p);
    _engine.explodeSnake(_segments, skin.bodyColor);
  }

  Vector2 get headPosition =>
      _segments.isEmpty ? Vector2.zero() : _segments.first;
  int get length => _segments.length;

  @override
  void render(Canvas canvas) => renderPlayer(canvas);
}
