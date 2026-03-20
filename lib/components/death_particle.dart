// lib/components/death_particle.dart
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../game/snake_engine.dart';
import '../utils/constants.dart';

enum _Shape { circle, square, triangle, ring, star }

class DeathParticle extends Component {
  final SnakeEngine engine;
  final Vector2 _pos;
  final Vector2 _vel;
  final Color _color;
  final double _maxRadius;
  double _life;
  final double _totalLife;
  final _Shape _shape;
  final Paint _paint = Paint();
  static final Random _rng = Random();

  DeathParticle._({
    required this.engine,
    required Vector2 position,
    required Vector2 velocity,
    required Color color,
    required double radius,
    required double life,
    required _Shape shape,
  })  : _pos = position.clone(),
        _vel = velocity.clone(),
        _color = color,
        _maxRadius = radius,
        _life = life,
        _totalLife = life,
        _shape = shape;

  static List<DeathParticle> burst({
    required SnakeEngine engine,
    required Vector2 center,
    required Color color,
    String skinId = '',
  }) {
    switch (skinId) {
      case 'classic':
        return _burstClassic(engine, center, color);
      case 'hot':
        return _burstHot(engine, center, color);
      case 'sorriso':
        return _burstSorriso(engine, center, color);
      case 'veneno':
        return _burstVeneno(engine, center, color);
      case 'fantasma':
        return _burstFantasma(engine, center, color);
      case 'piranha':
        return _burstPiranha(engine, center, color);
      case 'lava':
        return _burstLava(engine, center, color);
      case 'alien':
        return _burstAlien(engine, center, color);
      case 'lili':
        return _burstLili(engine, center, color);
      case 'robo':
        return _burstRobo(engine, center, color);
      default:
        return _burstDefault(engine, center, color);
    }
  }

  static List<DeathParticle> _burstClassic(
      SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int i = 0; i < 36; i++) {
      final angle = (i / 36) * pi * 2;
      list.add(_make(e, c, angle, 140.0 + _rng.nextDouble() * 90, col,
          4.0 + _rng.nextDouble() * 4, 0.9, _Shape.circle));
    }
    _sparks(list, e, c, const Color(0xFFFFFFFF), 12);
    return list;
  }

  static List<DeathParticle> _burstHot(SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int i = 0; i < 30; i++) {
      final color = _rng.nextBool() ? col : const Color(0xFFFF8C00);
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          80.0 + _rng.nextDouble() * 220,
          color,
          5.0 + _rng.nextDouble() * 5,
          0.8,
          _Shape.star));
    }
    _sparks(list, e, c, const Color(0xFFFFFF00), 14);
    return list;
  }

  static List<DeathParticle> _burstSorriso(
      SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    final colors = [
      const Color(0xFFFF5252),
      const Color(0xFF00E5FF),
      const Color(0xFF69F0AE),
      const Color(0xFFFFCA28),
      const Color(0xFFE040FB),
      col
    ];
    for (int i = 0; i < 44; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          60.0 + _rng.nextDouble() * 180,
          colors[i % colors.length],
          3.5 + _rng.nextDouble() * 4,
          1.1,
          _Shape.square));
    }
    return list;
  }

  static List<DeathParticle> _burstVeneno(SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int i = 0; i < 20; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          40.0 + _rng.nextDouble() * 120,
          const Color(0xFF00E676),
          6.0 + _rng.nextDouble() * 8,
          1.2,
          _Shape.ring));
    }
    for (int i = 0; i < 16; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          50.0 + _rng.nextDouble() * 80,
          const Color(0xFF1A1A1A),
          3.0 + _rng.nextDouble() * 3,
          0.7,
          _Shape.circle));
    }
    return list;
  }

  static List<DeathParticle> _burstFantasma(
      SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int i = 0; i < 25; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          30.0 + _rng.nextDouble() * 100,
          const Color(0xCCF5F5F5),
          5.0 + _rng.nextDouble() * 9,
          0.5,
          _Shape.circle));
    }
    for (int i = 0; i < 14; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          150.0 + _rng.nextDouble() * 100,
          const Color(0xFFB3E5FC),
          2.0 + _rng.nextDouble() * 3,
          0.6,
          _Shape.circle));
    }
    return list;
  }

  static List<DeathParticle> _burstPiranha(
      SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int i = 0; i < 28; i++) {
      final color = _rng.nextBool() ? col : const Color(0xFFCCFF80);
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          100.0 + _rng.nextDouble() * 220,
          color,
          4.0 + _rng.nextDouble() * 5,
          0.8,
          _Shape.triangle));
    }
    _sparks(list, e, c, const Color(0xFFFFFFFF), 8);
    return list;
  }

  static List<DeathParticle> _burstLava(SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int i = 0; i < 14; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          50.0 + _rng.nextDouble() * 120,
          col,
          7.0 + _rng.nextDouble() * 7,
          1.0,
          _Shape.square));
    }
    for (int i = 0; i < 24; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          150.0 + _rng.nextDouble() * 260,
          const Color(0xFFFF1744),
          2.0 + _rng.nextDouble() * 3,
          0.6,
          _Shape.circle));
    }
    return list;
  }

  static List<DeathParticle> _burstAlien(SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int ring = 0; ring < 3; ring++) {
      for (int i = 0; i < 16; i++) {
        final angle = (i / 16) * pi * 2;
        final speed = (80.0 + ring * 65) + _rng.nextDouble() * 30;
        list.add(_make(
            e,
            c + Vector2(_rng.nextDouble() * 8 - 4, _rng.nextDouble() * 8 - 4),
            angle,
            speed,
            ring == 0 ? const Color(0xFFB2FF59) : col,
            3.0 + _rng.nextDouble() * 4,
            0.7 + ring * 0.15,
            _Shape.ring));
      }
    }
    return list;
  }

  static List<DeathParticle> _burstLili(SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    final colors = [
      col,
      const Color(0xFFFF80AB),
      const Color(0xFFFF4081),
      const Color(0xFFFFCDD2)
    ];
    for (int i = 0; i < 36; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          50.0 + _rng.nextDouble() * 160,
          colors[i % colors.length],
          3.0 + _rng.nextDouble() * 5,
          1.0,
          _Shape.circle));
    }
    _sparks(list, e, c, const Color(0xFFFFD600), 10);
    return list;
  }

  static List<DeathParticle> _burstRobo(SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int i = 0; i < 18; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          80.0 + _rng.nextDouble() * 160,
          col,
          5.0 + _rng.nextDouble() * 6,
          0.9,
          _Shape.square));
    }
    for (int i = 0; i < 22; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          180.0 + _rng.nextDouble() * 220,
          const Color(0xFF00E5FF),
          1.5 + _rng.nextDouble() * 2,
          0.4,
          _Shape.circle));
    }
    _sparks(list, e, c, const Color(0xFFF44336), 8);
    return list;
  }

  static List<DeathParticle> _burstDefault(
      SnakeEngine e, Vector2 c, Color col) {
    final list = <DeathParticle>[];
    for (int i = 0; i < kDeathParticleCount; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          kDeathParticleSpeed * (0.3 + _rng.nextDouble() * 0.7),
          col,
          3.0 + _rng.nextDouble() * 5,
          kDeathParticleLife,
          _Shape.circle));
    }
    _sparks(list, e, c, const Color(0xFFFFFFFF), 10);
    return list;
  }

  static DeathParticle _make(SnakeEngine e, Vector2 center, double angle,
      double speed, Color color, double radius, double life, _Shape shape) {
    return DeathParticle._(
      engine: e,
      position: center +
          Vector2(_rng.nextDouble() * 8 - 4, _rng.nextDouble() * 8 - 4),
      velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
      color: color,
      radius: radius,
      life: life * (0.7 + _rng.nextDouble() * 0.3),
      shape: shape,
    );
  }

  static void _sparks(List<DeathParticle> list, SnakeEngine e, Vector2 c,
      Color color, int count) {
    for (int i = 0; i < count; i++) {
      list.add(_make(
          e,
          c,
          _rng.nextDouble() * pi * 2,
          200.0 + _rng.nextDouble() * 160,
          color,
          1.5 + _rng.nextDouble() * 2,
          0.4,
          _Shape.circle));
    }
  }

  @override
  void update(double dt) {
    _life -= dt;
    if (_life <= 0) {
      removeFromParent();
      return;
    }
    _pos.x += _vel.x * dt;
    _pos.y += _vel.y * dt;
    _vel.scale(1.0 - dt * 2.5);
  }

  @override
  void render(Canvas canvas) {
    if (_life <= 0) return;
    final double t = (_life / _totalLife).clamp(0.0, 1.0);
    final double alpha = t * t;
    final double radius = _maxRadius * (0.4 + t * 0.6);
    final Vector2 cam = engine.cameraOffset;
    final double sx = _pos.x - cam.x;
    final double sy = _pos.y - cam.y;
    if (sx < -20 ||
        sx > engine.size.x + 20 ||
        sy < -20 ||
        sy > engine.size.y + 20) return;

    _paint.color = Color.fromARGB(
        (alpha * 255).round(), _color.red, _color.green, _color.blue);

    switch (_shape) {
      case _Shape.circle:
        canvas.drawCircle(Offset(sx, sy), radius, _paint);
        break;
      case _Shape.square:
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(sx, sy),
                width: radius * 1.8,
                height: radius * 1.8),
            _paint);
        break;
      case _Shape.triangle:
        canvas.drawPath(
            Path()
              ..moveTo(sx, sy - radius)
              ..lineTo(sx + radius * 0.87, sy + radius * 0.5)
              ..lineTo(sx - radius * 0.87, sy + radius * 0.5)
              ..close(),
            _paint);
        break;
      case _Shape.ring:
        _paint.style = PaintingStyle.stroke;
        _paint.strokeWidth = radius * 0.4;
        canvas.drawCircle(Offset(sx, sy), radius, _paint);
        _paint.style = PaintingStyle.fill;
        break;
      case _Shape.star:
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final double r2 = i.isEven ? radius : radius * 0.45;
          final double a = (i * pi / 5) - pi / 2;
          final p = Offset(sx + cos(a) * r2, sy + sin(a) * r2);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        path.close();
        canvas.drawPath(path, _paint);
        break;
    }

    if (t > 0.4 && _shape != _Shape.ring) {
      _paint.color = Color.fromARGB((alpha * 70).round(), 255, 255, 255);
      canvas.drawCircle(Offset(sx - radius * 0.28, sy - radius * 0.28),
          radius * 0.28, _paint);
    }
  }
}
