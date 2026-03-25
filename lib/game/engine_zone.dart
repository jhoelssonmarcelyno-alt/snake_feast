// lib/game/engine_zone.dart
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart' show Colors;
import '../components/food.dart';

// ── Constantes da zona ────────────────────────────────────────
const double kBattleTotalTime = 300.0; // 5 minutos
const double kZoneGraceTime = 60.0; // 1 min sem zona
const double kZoneMinRadiusFrac = 0.05; // zona final = 5% do mapa
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

  // ── Raio atual da zona ────────────────────────────────────────
  double get zoneRadius {
    final double halfW = worldSize.x / 2;
    final double halfH = worldSize.y / 2;
    final double absoluteMaxR = sqrt(halfW * halfW + halfH * halfH);
    final double minR = min(halfW, halfH) * kZoneMinRadiusFrac;
    final double elapsed =
        (kBattleTotalTime - battleTimer).clamp(0.0, kBattleTotalTime);

    if (elapsed <= kZoneGraceTime) return absoluteMaxR;

    final double shrinkDuration = kBattleTotalTime - kZoneGraceTime;
    final double shrinkElapsed =
        (elapsed - kZoneGraceTime).clamp(0.0, shrinkDuration);
    final double t = shrinkElapsed / shrinkDuration;
    return absoluteMaxR + (minR - absoluteMaxR) * t;
  }

  Vector2 get zoneCenter => Vector2(worldSize.x / 2, worldSize.y / 2);

  // ── Update principal ──────────────────────────────────────────
  void updateBattleZone(double dt) {
    if (battleEnded) return;

    battleTimer = (battleTimer - dt).clamp(0.0, kBattleTotalTime);
    final double elapsed = kBattleTotalTime - battleTimer;

    if (elapsed > kZoneGraceTime) {
      battleActive = true;

      zoneDamageAccum += dt;
      if (zoneDamageAccum >= kZoneDamageInterval) {
        zoneDamageAccum = 0.0;
        _applyZoneDamage();
        _optimizeZoneResources(); // ✅ Nova função otimizada
      }
    } else {
      battleActive = false;
    }

    if (battleTimer <= 0 || (elapsed > 5 && _countAlive() <= 1)) {
      _endBattle();
    }
  }

  // ── Otimização Jhoelsson Studio: Teleporte em vez de Re-spawn ──
  void _optimizeZoneResources() {
    final Vector2 center = zoneCenter;
    final double r = zoneRadius;
    final double rSq = r * r;

    // ✅ REGRA DE ESCASSEZ: Se faltar 1 minuto (60s), para tudo!
    // As comidas fora da zona não entram mais e as de dentro não renascem.
    if (battleTimer <= 60) return;

    // 1. Em vez de remover, vamos REPOSICIONAR as comidas que ficaram no gás
    for (final food in foods) {
      if (food.position.distanceToSquared(center) > rSq) {
        // Teleporta a comida para um lugar seguro dentro do círculo
        food.position.setFrom(_randomInsideZone(center, r));
      }
    }

    // 2. Mantém a densidade mínima sem loops pesados de spawn
    final double zoneArea = pi * r * r;
    final int targetCommon = (zoneArea * kMinFoodDensity)
        .round()
        .clamp(kFoodMinCount, kCommonFoodCount);

    final int currentCommon =
        foods.where((f) => f.type == FoodType.common).length;

    // Se ainda faltar comida (porque alguém comeu), adiciona só o necessário
    if (currentCommon < targetCommon) {
      final int toAdd = (targetCommon - currentCommon)
          .clamp(0, 5); // Limita por ciclo para não travar
      for (int i = 0; i < toAdd; i++) {
        foods.add(Food.common(position: _randomInsideZone(center, r)));
      }
    }
  }

  Vector2 _randomInsideZone(Vector2 center, double radius) {
    final angle = rng.nextDouble() * pi * 2;
    // 0.90 para não spawnar muito colado na borda da zona
    final dist = sqrt(rng.nextDouble()) * radius * 0.90;
    return Vector2(
      center.x + cos(angle) * dist,
      center.y + sin(angle) * dist,
    );
  }

  // ── Dano às cobras fora da zona ───────────────────────────────
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
    final double pulse = 0.7 + 0.3 * sin(battleTimer * 4.0);

    final Path outsidePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.x, size.y))
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..fillType = PathFillType.evenOdd;

    final double progress = (kBattleTotalTime - battleTimer - kZoneGraceTime) /
        (kBattleTotalTime - kZoneGraceTime);

    // Cor vai de azul para vermelho sangue conforme o tempo acaba
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
    if (battleTimer > 60) return 1;
    return 2; // Fase crítica (último minuto)
  }
}
