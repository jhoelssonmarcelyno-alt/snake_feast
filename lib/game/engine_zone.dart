import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart' show Colors;
import '../components/food.dart';

// ── Constantes da zona ────────────────────────────────────────
const double kBattleTotalTime = 300.0; // 5 minutos total
const double kZoneGraceTime = 60.0; // 1 min de paz → zona aparece com 4:00
const double kZoneDamagePerSec = 2.0;
const double kZoneDamageInterval = 0.35;

extension EngineZone on SnakeEngine {
  // ── Inicialização ─────────────────────────────────────────────
  void initBattleZone() {
    battleTimer = kBattleTotalTime;
    zoneDamageAccum = 0.0;
    battleActive = false;
    battleWinner = null;
    battleEnded = false;
  }

  // Nota: zoneRadius e zoneCenter são getters definidos diretamente
  // em SnakeEngine (snake_engine.dart) para ficarem visíveis em
  // qualquer arquivo sem necessidade de importar engine_zone.dart.

  // ── Update principal ──────────────────────────────────────────
  // ⚠️  NÃO decrementa battleTimer aqui — isso é feito no snake_engine.update()
  void updateBattleZone(double dt) {
    if (battleEnded) return;

    final double elapsed = kBattleTotalTime - battleTimer;

    // Zona visível e com dano após o minuto de graça
    if (elapsed > kZoneGraceTime) {
      battleActive = true;

      zoneDamageAccum += dt;
      if (zoneDamageAccum >= kZoneDamageInterval) {
        zoneDamageAccum = 0.0;
        _applyZoneDamage();
        _optimizeZoneResources();
      }
    } else {
      battleActive = false;
    }

    // Fim de partida
    if (battleTimer <= 0 || (elapsed > 5 && _countAlive() <= 1)) {
      _endBattle();
    }
  }

  // ── Recursos dentro da zona ───────────────────────────────────
  void _optimizeZoneResources() {
    final Vector2 center = zoneCenter;
    final double r = zoneRadius;
    final double rSq = r * r;

    if (r < 5) {
      foods.clear();
      return;
    }

    // Teleporta comidas de fora para dentro
    for (final food in foods) {
      if (food.position.distanceToSquared(center) > rSq) {
        food.position.setFrom(_randomInsideZone(center, r));
      }
    }

    // Nos últimos 90 segundos NÃO gera mais comida (aumenta tensão)
    if (battleTimer <= 90) return;

    final double zoneArea = pi * r * r;
    final int targetCommon = (zoneArea * kMinFoodDensity)
        .round()
        .clamp(kFoodMinCount, kCommonFoodCount);
    final int currentCommon =
        foods.where((f) => f.type == FoodType.common).length;

    if (currentCommon < targetCommon) {
      final int toAdd = (targetCommon - currentCommon).clamp(0, 5);
      for (int i = 0; i < toAdd; i++) {
        foods.add(Food.common(position: _randomInsideZone(center, r)));
      }
    }
  }

  Vector2 _randomInsideZone(Vector2 center, double radius) {
    final angle = rng.nextDouble() * pi * 2;
    final dist = sqrt(rng.nextDouble()) * radius * 0.90;
    return Vector2(
      center.x + cos(angle) * dist,
      center.y + sin(angle) * dist,
    );
  }

  // ── Dano fora da zona ─────────────────────────────────────────
  void _applyZoneDamage() {
    final Vector2 center = zoneCenter;
    final double radius = zoneRadius;

    if (player.isAlive && player.segments.isNotEmpty) {
      if (player.segments.first.distanceTo(center) > radius) {
        _damageSnakePlayer();
      }
    }

    for (final bot in bots) {
      if (bot.isAlive && bot.segments.isNotEmpty) {
        if (bot.segments.first.distanceTo(center) > radius) {
          _damageSnakeBot(bot);
        }
      }
    }
  }

  void _damageSnakePlayer() {
    if (player.segments.length <= kPlayerMinSegments) {
      handlePlayerDeath();
      return;
    }
    player.segments.removeLast();
  }

  void _damageSnakeBot(dynamic bot) {
    if (bot.segments.length <= 2) {
      bot.die(killedByPlayer: false);
      return;
    }
    bot.segments.removeLast();
  }

  int _countAlive() {
    int count = player.isAlive ? 1 : 0;
    for (final b in bots) {
      if (b.isAlive) count++;
    }
    return count;
  }

  void _endBattle() {
    if (battleEnded) return;
    battleEnded = true;
    battleActive = false;

    if (player.isAlive) {
      battleWinner = player.name;
      try {
        (this as dynamic).triggerVictory();
      } catch (_) {}
    } else {
      for (final b in bots) {
        if (b.isAlive) {
          battleWinner = b.name;
          break;
        }
      }
      battleWinner ??= 'Bot';
      overlays.remove(kOverlayHud);
      overlays.add(kOverlayGameOver);
    }
  }

  // ── Renderização ──────────────────────────────────────────────
  void renderZone(Canvas canvas) {
    if (!battleActive) return;

    final double cx = zoneCenter.x - cameraOffset.x;
    final double cy = zoneCenter.y - cameraOffset.y;
    final double r = zoneRadius;

    if (r <= 0.5) return;

    final double pulse = 0.7 + 0.3 * sin(battleTimer * 4.0);

    final Path outsidePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.x, size.y))
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..fillType = PathFillType.evenOdd;

    final double progress = (kBattleTotalTime - battleTimer - kZoneGraceTime) /
        (kBattleTotalTime - kZoneGraceTime);

    final Color zoneColor = Color.lerp(
      const Color(0x4400AAFF),
      const Color(0xAAFF2200),
      progress.clamp(0.0, 1.0),
    )!;

    canvas.drawPath(outsidePath, Paint()..color = zoneColor);

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 + pulse * 3.0,
    );
  }

  String get battleTimerFormatted {
    final int total = battleTimer.ceil().clamp(0, kBattleTotalTime.toInt());
    final int m = total ~/ 60;
    final int s = total % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get battleTimerPhase {
    if (battleTimer > 120) return 0;
    if (battleTimer > 90) return 1;
    return 2;
  }
}
