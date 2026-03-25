#!/usr/bin/env bash
# =============================================================
#  apply_level_system.sh
#  Aplica o sistema de levels ao projeto serpent_strike.
#  Execute na raiz do projeto:  bash apply_level_system.sh
# =============================================================

set -e

# ── Cores para o terminal ─────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== Serpent Strike — Sistema de Levels ===${NC}"
echo ""

# ── Verifica se está na raiz do projeto Flutter ───────────────
if [ ! -f "pubspec.yaml" ]; then
  echo "ERRO: Execute este script na raiz do projeto (onde fica pubspec.yaml)."
  exit 1
fi

# ── Backup dos arquivos originais ─────────────────────────────
echo -e "${YELLOW}Criando backups...${NC}"
cp lib/components/snake_player.dart          lib/components/snake_player.dart.bak2          2>/dev/null || true
cp lib/components/snake_player_renderer.dart lib/components/snake_player_renderer.dart.bak  2>/dev/null || true
cp lib/overlays/hud.dart                     lib/overlays/hud.dart.bak                      2>/dev/null || true
echo -e "${GREEN}Backups criados com sufixo .bak / .bak2${NC}"
echo ""

# =============================================================
#  1. snake_player.dart
# =============================================================
echo -e "${YELLOW}Escrevendo lib/components/snake_player.dart ...${NC}"
cat > lib/components/snake_player.dart << 'DART_PLAYER'
// lib/components/snake_player.dart
import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'
    show
        Colors,
        Color,
        Offset,
        TextPainter,
        TextSpan,
        TextStyle,
        TextDirection,
        Shadow;
import '../game/snake_engine.dart';
import '../game/engine_food.dart';
import '../services/haptic_service.dart';
import '../services/score_service.dart';
import 'food.dart';
import 'death_particle.dart';
import 'snake_player_expressions.dart';
import 'snake_player_renderer.dart';
import '../utils/constants.dart';
import 'package:flame/components.dart';

class SnakePlayer extends Component
    with DragCallbacks, PlayerExpressions, PlayerRenderer {
  // ── Skin ─────────────────────────────────────────────────────
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

  int score = 0;
  int kills = 0;
  int foodEaten = 0;
  int _coinsEarned = 0;
  int _diamondsEarned = 0;

  // ── Acumula pontos antes de crescer — 1 segmento a cada 10 pontos ──
  int _growAccum = 0;

  // ── Sistema de Level ─────────────────────────────────────────
  int level = 1;
  int _starsForLevel = 0;  // estrelas acumuladas (food.value >= 5)
  int _foodForLevel  = 0;  // comidas normais acumuladas
  int _killsForLevel = 0;  // kills acumuladas (1 kill = +1 level)
  double levelUpTimer = 0.0; // quando > 0 exibe badge "LEVEL UP!" na tela

  String name = 'Você';

  // ── Paints ───────────────────────────────────────────────────
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

  // ── Lifecycle ────────────────────────────────────────────────
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
        text: name,
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
    _direction = _targetDirection = Vector2(1, 0);
    score = kills = foodEaten = 0;
    _coinsEarned = 0;
    _diamondsEarned = 0;
    _growAccum = 0;
    _isBoosting = false;
    _boostDrainAccum = 0;
    _tongueTimer = 0;
    _isAlive = true;
    // Reset do sistema de level
    level = 1;
    _starsForLevel = 0;
    _foodForLevel  = 0;
    _killsForLevel = 0;
    levelUpTimer   = 0.0;
    for (int i = 0; i < kPlayerInitialSegments; i++) {
      _segments.add(pos - Vector2(kPlayerSegmentSpacing * i, 0));
    }
  }

  // ── DragCallbacks ────────────────────────────────────────────
  @override
  bool onDragStart(DragStartEvent event) {
    _activeTouchId = event.pointerId;
    _joystickOrigin = event.canvasPosition.clone();
    _joystickCurrent = event.canvasPosition.clone();
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (event.pointerId == _activeTouchId) {
      _joystickCurrent = event.canvasEndPosition.clone();
    }
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    if (event.pointerId == _activeTouchId) {
      _joystickOrigin = _joystickCurrent = null;
      _activeTouchId = null;
    }
    return true;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    _joystickOrigin = _joystickCurrent = null;
    _activeTouchId = null;
    return true;
  }

  // ── API HUD ──────────────────────────────────────────────────
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

  // ── Update ───────────────────────────────────────────────────
  @override
  void update(double dt) {
    if (!_isAlive) return;
    _tongueTimer += dt;
    // Decrementa timer do badge "LEVEL UP!"
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
    _targetDirection = delta.normalized();
  }

  void _updateDirection(double dt) {
    final double t = (kPlayerTurnLerp * dt).clamp(0.0, 1.0);
    final Vector2 lerped = _direction.clone()..lerp(_targetDirection, t);
    if (lerped.length2 > 0) lerped.normalize();
    _direction = lerped;
  }

  void _moveSegments(double dt) {
    final double speed = _isBoosting && _segments.length > kPlayerMinSegments
        ? kPlayerBoostSpeed
        : kPlayerBaseSpeed;
    final Vector2 newHead = _segments.first + _direction * (speed * dt);
    newHead.x = newHead.x.clamp(0.0, _engine.worldSize.x);
    newHead.y = newHead.y.clamp(0.0, _engine.worldSize.y);
    for (int i = _segments.length - 1; i > 0; i--) {
      _segments[i] = _segments[i - 1].clone();
    }
    _segments[0] = newHead;
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
    for (final food in List<Food>.from(_engine.foods)) {
      if (food.position.distanceTo(head) < eatR) {
        _engine.consumeFood(food, this);
        grow(food.value);
        HapticService.instance.eat();
      }
    }
  }

  // ── API pública ──────────────────────────────────────────────

  void grow(int amount) {
    score += amount;
    foodEaten += amount;
    _checkRewardMilestones();
    _checkLevelMilestones(amount);

    // Cresce 1 segmento a cada 10 pontos acumulados
    _growAccum += amount;
    while (_growAccum >= 10) {
      _growAccum -= 10;
      _segments.add(_segments.last.clone());
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

  // ── Sistema de Level ─────────────────────────────────────────

  void _checkLevelMilestones(int amount) {
    // Food especial (estrela): food.value >= 5 → 2 estrelas = +1 level
    if (amount >= 5) {
      _starsForLevel++;
      if (_starsForLevel >= 2) {
        _starsForLevel = 0;
        _gainLevel();
      }
    } else {
      // Comida normal: a cada 10 unidades = +1 level
      _foodForLevel += amount;
      while (_foodForLevel >= 10) {
        _foodForLevel -= 10;
        _gainLevel();
      }
    }
  }

  void _gainLevel() {
    level++;
    levelUpTimer = 2.0; // exibe badge "LEVEL UP!" por 2 segundos
    HapticService.instance.boost();
  }

  void registerKill() {
    kills++;
    _killsForLevel++;
    if (_killsForLevel >= 1) {  // 1 kill = +1 level
      _killsForLevel = 0;
      _gainLevel();
    }
    HapticService.instance.kill();
  }

  void revive(Vector2 pos) {
    _segments.clear();
    _direction = _targetDirection = Vector2(1, 0);
    _isBoosting = false;
    _boostDrainAccum = 0;
    _tongueTimer = 0;
    _growAccum = 0;
    _isAlive = true;
    // Reset do sistema de level
    level = 1;
    _starsForLevel = 0;
    _foodForLevel  = 0;
    _killsForLevel = 0;
    levelUpTimer   = 0.0;
    for (int i = 0; i < kPlayerInitialSegments + 4; i++) {
      _segments.add(pos - Vector2(kPlayerSegmentSpacing * i, 0));
    }
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

  // ── Render ───────────────────────────────────────────────────
  @override
  void render(Canvas canvas) => renderPlayer(canvas);
}
DART_PLAYER
echo -e "${GREEN}✓ snake_player.dart${NC}"


# =============================================================
#  2. snake_player_renderer.dart
# =============================================================
echo -e "${YELLOW}Escrevendo lib/components/snake_player_renderer.dart ...${NC}"
cat > lib/components/snake_player_renderer.dart << 'DART_RENDERER'
// lib/components/snake_player_renderer.dart
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart'
    show
        Colors,
        Color,
        FontWeight,
        TextPainter,
        TextSpan,
        TextStyle,
        TextDirection,
        Shadow,
        HSVColor,
        RadialGradient,
        LinearGradient,
        Alignment;
import '../game/snake_engine.dart';
import 'snake_player.dart';
import 'snake_player_expressions.dart';
import 'animal_skins.dart';

const _kAnimalSkinIds = {
  'gato',
  'cachorro',
  'leao',
  'vaca',
  'coelho',
  'peixe',
  'dragao_animal',
  'raposa',
};

mixin PlayerRenderer on PlayerExpressions {
  SnakeEngine get engine;
  List<Vector2> get segments;
  bool get isAlive;
  bool get isBoosting;
  double get headRadius;
  double get tongueTimer;
  Paint get bodyPaint;
  Paint get headPaint;
  Paint get shadowPaint;
  Paint get highlightPaint;
  Paint get boostGlowPaint;
  Paint get accentRingPaint;
  TextPainter get namePainter;

  final Paint _scalePaint = Paint()..style = PaintingStyle.stroke;
  final Paint _ventPaint = Paint();
  final Paint _shimmerPaint = Paint();
  final Paint _rimPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _patternPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _glowPaint = Paint();
  final Paint _tailPaint = Paint();

  void renderPlayer(Canvas canvas) {
    if (!isAlive || segments.isEmpty) return;
    final Vector2 cam = engine.cameraOffset;
    final double sw = engine.size.x;
    final double sh = engine.size.y;
    final double hr = headRadius;
    final bool isAnimal = _kAnimalSkinIds.contains(skinId);

    _renderTail(canvas, cam, sw, sh, hr, isAnimal);

    for (int i = segments.length - 1; i >= 1; i--) {
      final double sx = segments[i].x - cam.x;
      final double sy = segments[i].y - cam.y;
      if (sx < -30 || sx > sw + 30 || sy < -30 || sy > sh + 30) continue;
      final double t = 1.0 - (i / segments.length);
      final double r = _segmentRadius(i, hr);
      _drawSegment(canvas, Offset(sx, sy), r, t, i, isAnimal);
      if (isBoosting && i % 3 == 0) {
        _glowPaint.color = skinAccentColor.withValues(alpha: 0.28);
        canvas.drawCircle(Offset(sx, sy), r + 4, _glowPaint);
      }
    }

    final double hx = segments.first.x - cam.x;
    final double hy = segments.first.y - cam.y;
    if (hx > -hr * 3 && hx < sw + hr * 3 && hy > -hr * 3 && hy < sh + hr * 3) {
      _renderHead(canvas, Offset(hx, hy), hr, isAnimal);
      _renderName(canvas, Offset(hx, hy), hr);
    }
  }

  void _renderTail(Canvas canvas, Vector2 cam, double sw, double sh, double hr,
      bool isAnimal) {
    if (segments.length < 3) return;
    final last = segments.last;
    final prev = segments[segments.length - 2];
    final sx = last.x - cam.x;
    final sy = last.y - cam.y;
    if (sx < -60 || sx > sw + 60 || sy < -60 || sy > sh + 60) return;
    final dir = (last - prev);
    final angle = dir.length2 > 0 ? atan2(dir.y, dir.x) : 0.0;
    final tailR = _segmentRadius(segments.length - 1, hr);
    if (isAnimal) {
      renderAnimalTail(canvas, skinId, Offset(sx, sy), angle, tailR);
    } else {
      _drawSnakeTail(canvas, Offset(sx, sy), angle, tailR);
    }
  }

  void _drawSnakeTail(Canvas canvas, Offset pos, double angle, double r) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    final tailLen = r * 2.8;
    final path = Path()
      ..moveTo(0, -r * 0.82)
      ..cubicTo(r * 0.3, -r * 0.5, tailLen * 0.6, -r * 0.25, tailLen, 0)
      ..cubicTo(tailLen * 0.6, r * 0.25, r * 0.3, r * 0.5, 0, r * 0.82)
      ..close();
    _tailPaint.shader = LinearGradient(
      colors: [
        skinBodyColor,
        skinBodyColorDark,
        skinBodyColorDark.withValues(alpha: 0.0)
      ],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(Rect.fromLTWH(0, -r, tailLen, r * 2));
    canvas.drawPath(path, _tailPaint);
    _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.35);
    _scalePaint.strokeWidth = r * 0.10;
    for (int i = 1; i <= 3; i++) {
      final tx = tailLen * (i / 4.0);
      final tr = r * (1.0 - i * 0.22);
      canvas.drawArc(Rect.fromCircle(center: Offset(tx, 0), radius: tr * 0.7),
          pi * 0.2, pi * 0.6, false, _scalePaint);
    }
    _shimmerPaint.shader = RadialGradient(
      center: const Alignment(-0.5, -0.5),
      radius: 0.65,
      colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0.0)],
    ).createShader(Rect.fromLTWH(0, -r, tailLen * 0.6, r * 2));
    canvas.drawPath(path, _shimmerPaint);
    canvas.restore();
  }

  void _drawSegment(
      Canvas canvas, Offset pos, double r, double t, int idx, bool isAnimal) {
    bodyPaint.color = Colors.black.withValues(alpha: 0.26);
    canvas.drawCircle(pos + Offset(r * 0.16, r * 0.20), r * 0.92, bodyPaint);
    final Color base = Color.lerp(skinBodyColorDark, skinBodyColor, t)!;
    final Color ventral = _lighten(base, 0.38);
    _ventPaint.shader = RadialGradient(
      center: const Alignment(-0.30, -0.42),
      radius: 1.0,
      colors: [ventral, base, skinBodyColorDark],
      stops: const [0.0, 0.52, 1.0],
    ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, _ventPaint);
    if (!isAnimal) {
      _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.32);
      _scalePaint.strokeWidth = r * 0.12;
      _scalePaint.strokeCap = StrokeCap.round;
      canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, r * 0.10), radius: r * 0.72),
          pi * 0.18, pi * 0.64, false, _scalePaint);
      _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.18);
      _scalePaint.strokeWidth = r * 0.08;
      canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, r * 0.04), radius: r * 0.44),
          pi * 0.22, pi * 0.56, false, _scalePaint);
    } else {
      _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.28);
      _scalePaint.strokeWidth = r * 0.10;
      _scalePaint.strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: pos, radius: r * 0.68), pi * 0.18,
          pi * 0.64, false, _scalePaint);
      if (skinId == 'vaca' && (pos.dx.toInt() + pos.dy.toInt()) % 3 == 0) {
        canvas.drawOval(
          Rect.fromCenter(
              center: pos + Offset(r * 0.2, -r * 0.1),
              width: r * 0.9,
              height: r * 0.7),
          Paint()..color = const Color(0xFF212121).withValues(alpha: 0.55),
        );
      }
    }
    _rimPaint.color = skinBodyColorDark.withValues(alpha: 0.42);
    _rimPaint.strokeWidth = r * 0.14;
    canvas.drawCircle(pos, r * 0.91, _rimPaint);
    _shimmerPaint.shader = RadialGradient(
      center: const Alignment(-0.45, -0.45),
      radius: 0.65,
      colors: [
        Colors.white.withValues(alpha: 0.55 * t),
        Colors.white.withValues(alpha: 0.0)
      ],
    ).createShader(Rect.fromCircle(center: pos, radius: r));
    canvas.drawCircle(pos, r, _shimmerPaint);
    if (isBoosting && t > 0.6) {
      canvas.drawCircle(
          pos,
          r,
          Paint()
            ..color = skinAccentColor.withValues(alpha: 0.15)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.22);
    }
  }

  void _renderHead(Canvas canvas, Offset pos, double hr, bool isAnimal) {
    final Vector2 dir = segments.length >= 2
        ? (segments[0] - segments[1]).normalized()
        : Vector2(1, 0);
    final double angle = atan2(dir.y, dir.x);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    bodyPaint.color = Colors.black.withValues(alpha: 0.30);
    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(2, 3), width: hr * 2.4, height: hr * 2.0),
      bodyPaint,
    );

    if (isBoosting) {
      _glowPaint.color = skinAccentColor.withValues(alpha: 0.40);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hr * 3.0, height: hr * 2.6),
        _glowPaint,
      );
    }

    final shape = headShape();
    final double hw = hr * shape.$1;
    final double hh = hr * shape.$2;

    if (isAnimal) {
      renderAnimalBackLayer(
          canvas, skinId, hr, tongueTimer, skinBodyColor, skinBodyColorDark);

      final headGrad = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.30, -0.40),
          radius: 1.0,
          colors: [
            _lighten(skinBodyColor, 0.42),
            skinBodyColor,
            skinBodyColorDark
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(
            Rect.fromCenter(center: Offset.zero, width: hw, height: hh));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
        headGrad,
      );

      _shimmerPaint.shader = RadialGradient(
        center: const Alignment(-0.40, -0.50),
        radius: 0.60,
        colors: [Colors.white.withValues(alpha: 0.48), Colors.white.withValues(alpha: 0.0)],
      ).createShader(
          Rect.fromCenter(center: Offset.zero, width: hw, height: hh));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
        _shimmerPaint,
      );

      renderExpression(canvas, hr, tongueTimer);
    } else {
      final headGrad = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.30, -0.40),
          radius: 1.0,
          colors: [
            _lighten(skinBodyColor, 0.42),
            skinBodyColor,
            skinBodyColorDark
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(
            Rect.fromCenter(center: Offset.zero, width: hw, height: hh));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
        headGrad,
      );
      _scalePaint.color = skinBodyColorDark.withValues(alpha: 0.22);
      _scalePaint.strokeWidth = hr * 0.10;
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset.zero, width: hw * 0.70, height: hh * 0.68),
        pi * 0.20, pi * 0.60, false, _scalePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hw * 0.36, 0), width: hh * 0.46, height: hh * 0.44),
        Paint()..color = _darken(skinBodyColor, 0.14),
      );
      final Paint nostril = Paint()
        ..color = skinBodyColorDark.withValues(alpha: 0.80);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hw * 0.44, -hh * 0.13),
            width: hr * 0.14,
            height: hr * 0.09),
        nostril,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(hw * 0.44, hh * 0.13),
            width: hr * 0.14,
            height: hr * 0.09),
        nostril,
      );
      _shimmerPaint.shader = RadialGradient(
        center: const Alignment(-0.40, -0.50),
        radius: 0.60,
        colors: [Colors.white.withValues(alpha: 0.52), Colors.white.withValues(alpha: 0.0)],
      ).createShader(
          Rect.fromCenter(center: Offset.zero, width: hw, height: hh));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: hw, height: hh),
        _shimmerPaint,
      );
      renderExpression(canvas, hr, tongueTimer);
    }

    canvas.restore();
  }

  // ── Nome + badge de level ─────────────────────────────────────
  void _renderName(Canvas canvas, Offset headPos, double hr) {
    namePainter.paint(canvas,
        Offset(headPos.dx - namePainter.width / 2, headPos.dy - hr - 22));

    if (engine.leader == this) {
      _drawCrown(canvas, Offset(headPos.dx, headPos.dy - hr - 30), hr);
    }

    _drawLevelBadge(canvas, headPos, hr);
  }

  // ── Badge de level ────────────────────────────────────────────
  void _drawLevelBadge(Canvas canvas, Offset headPos, double hr) {
    final SnakePlayer player = engine.player;
    final int lvl = player.level;
    final bool isLevelUpAnim = player.levelUpTimer > 0;

    // Badge fica 28px acima do nome (que já fica hr+22 acima da cabeça)
    final double badgeY = headPos.dy - hr - 42 - (isLevelUpAnim ? 16 : 0);
    final double badgeX = headPos.dx;

    // ── Texto "Lv.N" ─────────────────────────────────────────
    final String lvlText = 'Lv.$lvl';
    final badgePainter = TextPainter(
      text: TextSpan(
        text: lvlText,
        style: TextStyle(
          color: _levelColor(lvl),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Color(0xFF000000), blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Fundo arredondado semi-transparente
    const double padH = 6, padV = 3;
    final double bw = badgePainter.width + padH * 2;
    final double bh = badgePainter.height + padV * 2;
    final RRect badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(badgeX, badgeY), width: bw, height: bh),
      const Radius.circular(6),
    );

    // Fundo escuro
    canvas.drawRRect(
      badgeRect,
      Paint()..color = const Color(0xCC000000),
    );
    // Borda colorida por tier
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = _levelColor(lvl).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Texto do level
    badgePainter.paint(
      canvas,
      Offset(badgeX - badgePainter.width / 2, badgeY - badgePainter.height / 2),
    );

    // ── Animação "LEVEL UP!" flutuante ────────────────────────
    if (isLevelUpAnim) {
      final double progress = player.levelUpTimer / 2.0; // 1.0 → 0.0
      final double alpha = (progress * 2).clamp(0.0, 1.0); // fade out
      final double floatOffset = (1.0 - progress) * 12;    // sobe 12px

      final lvlUpPainter = TextPainter(
        text: TextSpan(
          text: 'LEVEL UP!',
          style: TextStyle(
            color: const Color(0xFFFFD600).withValues(alpha: alpha),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: const Color(0xFFFFD600).withValues(alpha: alpha * 0.6),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      lvlUpPainter.paint(
        canvas,
        Offset(
          badgeX - lvlUpPainter.width / 2,
          badgeY - bh - 6 - floatOffset,
        ),
      );
    }
  }

  /// Cor do badge baseada no tier de level
  Color _levelColor(int lvl) {
    if (lvl >= 50) return const Color(0xFF00E5FF); // Diamante (ciano)
    if (lvl >= 30) return const Color(0xFFE040FB); // Platina  (roxo)
    if (lvl >= 20) return const Color(0xFFFFD600); // Ouro
    if (lvl >= 10) return const Color(0xFFB0BEC5); // Prata
    return const Color(0xFFCD7F32);                // Bronze
  }

  void _drawCrown(Canvas canvas, Offset pos, double hr) {
    final gold = Paint()..color = const Color(0xFFFFD600);
    final outline = Paint()
      ..color = const Color(0xFFAA8800)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final double w = hr * 1.4, h = hr * 0.7;
    final double x = pos.dx - w / 2, y = pos.dy - h;
    final path = Path()
      ..moveTo(x, y + h)
      ..lineTo(x, y + h * 0.3)
      ..lineTo(x + w * 0.25, y + h * 0.65)
      ..lineTo(x + w * 0.5, y)
      ..lineTo(x + w * 0.75, y + h * 0.65)
      ..lineTo(x + w, y + h * 0.3)
      ..lineTo(x + w, y + h)
      ..close();
    canvas.drawPath(path, gold);
    canvas.drawPath(path, outline);
    for (final dx in [0.0, 0.5, 1.0]) {
      canvas.drawCircle(
        Offset(x + w * dx, dx == 0.5 ? y - hr * 0.05 : y + h * 0.3),
        hr * 0.12,
        Paint()..color = const Color(0xFFFF5252),
      );
    }
  }

  double _segmentRadius(int index, double hr) {
    final double taper = 1.0 - (index / segments.length) * 0.18;
    return (hr * taper).clamp(hr * 0.70, hr);
  }

  Color _lighten(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value - amount).clamp(0.0, 1.0)).toColor();
  }
}
DART_RENDERER
echo -e "${GREEN}✓ snake_player_renderer.dart${NC}"


# =============================================================
#  3. hud.dart
# =============================================================
echo -e "${YELLOW}Escrevendo lib/overlays/hud.dart ...${NC}"
cat > lib/overlays/hud.dart << 'DART_HUD'
// lib/overlays/hud.dart
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class HudOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const HudOverlay({super.key, required this.engine});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  Offset? _joystickOrigin;
  Offset? _joystickThumb;
  int? _joystickPointer;

  static const double _baseRadius = 55.0;
  static const double _thumbRadius = 24.0;
  bool _boostPressed = false;

  static const _base = TextStyle(
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
    decorationThickness: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  void _tick(Duration _) {
    if (!mounted) return;
    if (mounted) setState(() {});
    if (mounted) WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_joystickPointer != null) return;
    _joystickPointer = e.pointer;
    setState(() {
      _joystickOrigin = e.localPosition;
      _joystickThumb = e.localPosition;
    });
    widget.engine.player.setJoystick(e.localPosition, e.localPosition);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _joystickPointer || _joystickOrigin == null) return;
    final delta = e.localPosition - _joystickOrigin!;
    final dist = delta.distance;
    final clamped = dist <= _baseRadius
        ? e.localPosition
        : _joystickOrigin! + Offset(delta.dx, delta.dy) / dist * _baseRadius;
    setState(() => _joystickThumb = clamped);
    widget.engine.player.setJoystick(_joystickOrigin!, e.localPosition);
  }

  void _onPointerUp(PointerUpEvent e) {
    if (e.pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickThumb = null;
    });
    widget.engine.player.clearJoystick();
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (e.pointer != _joystickPointer) return;
    _joystickPointer = null;
    setState(() {
      _joystickOrigin = null;
      _joystickThumb = null;
    });
    widget.engine.player.clearJoystick();
  }

  void _onBoostDown(PointerDownEvent _) {
    setState(() => _boostPressed = true);
    widget.engine.player.setBoost(true);
  }

  void _onBoostUp(PointerUpEvent _) {
    setState(() => _boostPressed = false);
    widget.engine.player.setBoost(false);
  }

  void _onBoostCancel(PointerCancelEvent _) {
    setState(() => _boostPressed = false);
    widget.engine.player.setBoost(false);
  }

  @override
  Widget build(BuildContext context) {
    final score    = widget.engine.player.score;
    final kills    = widget.engine.player.kills;
    final length   = widget.engine.player.length;
    final level    = widget.engine.player.level;
    final hs       = ScoreService.instance.highScore;
    final coins    = ScoreService.instance.coins;
    final diamonds = ScoreService.instance.diamonds;
    final revives  = ScoreService.instance.revives;
    final isRecord = score >= hs && score > 0;
    final size     = MediaQuery.of(context).size;
    final isBoosting = widget.engine.player.isBoosting;

    const double boostSize   = 76.0;
    const double boostRight  = 24.0;
    const double boostBottom = 24.0;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: _base,
        child: Stack(
          children: [
            // ── Área do joystick (metade esquerda) ────────────
            Positioned(
              left: 0, top: 0,
              width: size.width * 0.5,
              height: size.height,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                child: Stack(clipBehavior: Clip.none, children: [
                  if (_joystickOrigin == null)
                    Positioned(
                      left: size.width * 0.10,
                      bottom: size.height * 0.10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.04),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(Icons.gamepad_outlined,
                                color: Colors.white.withValues(alpha: 0.12),
                                size: 20),
                          ),
                          const SizedBox(height: 5),
                          Text('Arraste aqui',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.09),
                              fontSize: 9, letterSpacing: 1.5,
                              decoration: TextDecoration.none,
                            )),
                        ],
                      ),
                    ),
                  if (_joystickOrigin != null)
                    Positioned(
                      left: _joystickOrigin!.dx - _baseRadius,
                      top:  _joystickOrigin!.dy - _baseRadius,
                      child: Container(
                        width: _baseRadius * 2, height: _baseRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  if (_joystickThumb != null)
                    Positioned(
                      left: _joystickThumb!.dx - _thumbRadius,
                      top:  _joystickThumb!.dy - _thumbRadius,
                      child: Container(
                        width: _thumbRadius * 2, height: _thumbRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.38),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.80),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ),

            // ── BOOST — canto inferior direito ────────────────
            Positioned(
              right: boostRight, bottom: boostBottom,
              child: Listener(
                onPointerDown: _onBoostDown,
                onPointerUp: _onBoostUp,
                onPointerCancel: _onBoostCancel,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width:  _boostPressed ? boostSize - 4 : boostSize,
                  height: _boostPressed ? boostSize - 4 : boostSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isBoosting
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.30)
                        : Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: isBoosting
                          ? const Color(0xFF00E5FF)
                          : Colors.white.withValues(alpha: 0.30),
                      width: isBoosting ? 2.5 : 1.5,
                    ),
                    boxShadow: isBoosting
                        ? [BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            blurRadius: 16, spreadRadius: 2)]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on_rounded,
                        color: isBoosting
                            ? const Color(0xFF00E5FF)
                            : Colors.white.withValues(alpha: 0.5),
                        size: 28),
                      Text('BOOST',
                        style: TextStyle(
                          color: isBoosting
                              ? const Color(0xFF00E5FF)
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: 9, fontWeight: FontWeight.bold,
                          letterSpacing: 1, decoration: TextDecoration.none,
                        )),
                    ],
                  ),
                ),
              ),
            ),

            // ── PAUSE ─────────────────────────────────────────
            Positioned(
              right: boostRight + (boostSize - 64) / 2,
              bottom: boostBottom + boostSize + 12.0,
              child: GestureDetector(
                onTap: () {
                  widget.engine.pauseEngine();
                  widget.engine.overlays.remove(kOverlayHud);
                  widget.engine.overlays.add(kOverlayPause);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: 64, height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30), width: 1.5),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8, offset: const Offset(0, 3),
                    )],
                  ),
                  child: Center(
                    child: Text('PAUSE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 10, fontWeight: FontWeight.bold,
                        letterSpacing: 2, decoration: TextDecoration.none,
                      )),
                  ),
                ),
              ),
            ),

            // ── Score central superior ─────────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Text('$score',
                      style: TextStyle(
                        fontSize: 42, fontWeight: FontWeight.w900,
                        height: 1.0, letterSpacing: 2,
                        color: isRecord ? const Color(0xFFFFD600) : Colors.white,
                        decoration: TextDecoration.none,
                        shadows: [Shadow(
                          color: isRecord
                              ? const Color(0xFFFFD600).withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                        )],
                      )),
                    if (isRecord)
                      const Text('● RECORDE',
                        style: TextStyle(
                          color: Color(0xFFFFD600), fontSize: 9,
                          fontWeight: FontWeight.bold, letterSpacing: 3,
                          decoration: TextDecoration.none,
                        )),
                  ],
                ),
              ),
            ),

            // ── Stats top right ────────────────────────────────
            Positioned(
              top: 0, right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 10),
                  child: _HudCard(children: [
                    // Linha 1: KILLS / TAMANHO / RECORDE
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      _HudStat(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFFF5252),
                        label: 'KILLS', value: '$kills',
                        valueColor: const Color(0xFFFF5252),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.linear_scale_rounded,
                        iconColor: const Color(0xFF69F0AE),
                        label: 'TAMANHO', value: '$length',
                        valueColor: const Color(0xFF69F0AE),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.emoji_events_rounded,
                        iconColor: const Color(0xFFFFD700),
                        label: 'RECORDE', value: '$hs',
                        valueColor: const Color(0xFFFFD700),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    // Linha 2: LEVEL / MOEDAS / DIAMANTES / VIDAS
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      _HudStat(
                        icon: Icons.star_rounded,
                        iconColor: _levelHudColor(level),
                        label: 'LEVEL', value: '$level',
                        valueColor: _levelHudColor(level),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.monetization_on_rounded,
                        iconColor: const Color(0xFFFFD600),
                        label: 'MOEDAS', value: '$coins',
                        valueColor: const Color(0xFFFFD600),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.diamond_rounded,
                        iconColor: const Color(0xFF00E5FF),
                        label: 'DIAMANTES', value: '$diamonds',
                        valueColor: const Color(0xFF00E5FF),
                      ),
                      const SizedBox(width: 12),
                      _HudStat(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFF2ECC71),
                        label: 'VIDAS', value: '$revives',
                        valueColor: const Color(0xFF2ECC71),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mesma paleta de tiers do renderer
  Color _levelHudColor(int lvl) {
    if (lvl >= 50) return const Color(0xFF00E5FF);
    if (lvl >= 30) return const Color(0xFFE040FB);
    if (lvl >= 20) return const Color(0xFFFFD600);
    if (lvl >= 10) return const Color(0xFFB0BEC5);
    return const Color(0xFFCD7F32);
  }
}

class _HudCard extends StatelessWidget {
  final List<Widget> children;
  const _HudCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
}

class _HudStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final Color valueColor;
  const _HudStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: iconColor, size: 10),
            const SizedBox(width: 3),
            Text(label,
              style: const TextStyle(
                color: Color(0xFF546E7A), fontSize: 8,
                fontWeight: FontWeight.bold, letterSpacing: 1.2,
                decoration: TextDecoration.none,
              )),
          ]),
          const SizedBox(height: 1),
          Text(value,
            style: TextStyle(
              color: valueColor, fontSize: 16,
              fontWeight: FontWeight.w900, height: 1.0,
              decoration: TextDecoration.none,
            )),
        ],
      );
}
DART_HUD
echo -e "${GREEN}✓ hud.dart${NC}"


# =============================================================
#  Resumo final
# =============================================================
echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${GREEN}  Sistema de levels aplicado com sucesso!${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo "  Arquivos modificados:"
echo "    lib/components/snake_player.dart"
echo "    lib/components/snake_player_renderer.dart"
echo "    lib/overlays/hud.dart"
echo ""
echo "  Regras de level:"
echo "    ★ 2 estrelas (food.value >= 5)  → +1 level"
echo "    ☠  1 kill                        → +1 level"
echo "    🍎 10 comidas normais            → +1 level"
echo ""
echo "  Tiers de badge:"
echo "    Lv. 1-9   Bronze  (#CD7F32)"
echo "    Lv.10-19  Prata   (#B0BEC5)"
echo "    Lv.20-29  Ouro    (#FFD600)"
echo "    Lv.30-49  Platina (#E040FB)"
echo "    Lv.50+    Diamante(#00E5FF)"
echo ""
echo "  Backups salvos em .bak / .bak2"
echo ""
