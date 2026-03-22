// lib/game/engine_collision.dart
import '../components/snake_bot.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';
import 'package:flame/components.dart';

extension EngineCollision on SnakeEngine {
  void checkCollisions() {
    final activeBots = bots.where((b) => b.isAlive).toList();

    void check({
      required Vector2 headA,
      required double radiusA,
      required List<Vector2> bodyB,
      required double radiusB,
      required bool attackerIsPlayer,
      SnakeBot? attackerBot,
      bool victimIsPlayer = false,
    }) {
      final double threshSq = (radiusA + radiusB * kCollisionBodyRatio) *
          (radiusA + radiusB * kCollisionBodyRatio);
      const int skip = 4;
      final Vector2 headB = bodyB.first;
      if ((headA.x - headB.x).abs() > 450 ||
          (headA.y - headB.y).abs() > 450) return;
      for (int s = skip; s < bodyB.length; s++) {
        final double dx = headA.x - bodyB[s].x;
        final double dy = headA.y - bodyB[s].y;
        if (dx * dx + dy * dy < threshSq) {
          if (attackerIsPlayer) {
            handlePlayerDeath();
          } else {
            attackerBot!.die(killedByPlayer: victimIsPlayer);
          }
          return;
        }
      }
    }

    if (player.isAlive) {
      for (final bot in activeBots) {
        check(
          headA: player.headPosition,
          radiusA: player.headRadius,
          bodyB: bot.segments,
          radiusB: bot.headRadius,
          attackerIsPlayer: true,
        );
        if (!player.isAlive) break;
      }
    }

    if (player.isAlive) {
      for (final bot in activeBots) {
        if (!bot.isAlive) continue;
        check(
          headA: bot.headPosition,
          radiusA: bot.headRadius,
          bodyB: player.segments,
          radiusB: player.headRadius,
          attackerIsPlayer: false,
          attackerBot: bot,
          victimIsPlayer: true,
        );
      }
    }

    for (int a = 0; a < activeBots.length; a++) {
      if (!activeBots[a].isAlive) continue;
      for (int b = 0; b < activeBots.length; b++) {
        if (a == b || !activeBots[b].isAlive) continue;
        check(
          headA: activeBots[a].headPosition,
          radiusA: activeBots[a].headRadius,
          bodyB: activeBots[b].segments,
          radiusB: activeBots[b].headRadius,
          attackerIsPlayer: false,
          attackerBot: activeBots[a],
        );
      }
    }
  }

  void checkWallCollision() {
    const double margin = kWallThickness * 0.5;

    if (player.isAlive && player.segments.isNotEmpty) {
      final head = player.headPosition;
      if (head.x < margin ||
          head.x > worldSize.x - margin ||
          head.y < margin ||
          head.y > worldSize.y - margin) {
        handlePlayerDeath();
      }
    }

    for (final bot in bots) {
      if (!bot.isAlive || bot.segments.isEmpty) continue;
      final bh = bot.headPosition;
      if (bh.x < margin ||
          bh.x > worldSize.x - margin ||
          bh.y < margin ||
          bh.y > worldSize.y - margin) {
        bot.die(killedByPlayer: false);
      }
    }
  }
}
