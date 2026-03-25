// lib/game/engine_collision.dart
import '../components/snake_bot.dart';
import 'snake_engine.dart';
// import 'engine_zone.dart'; // Mantenha se for usar zoneRadius futuramente
import '../utils/constants.dart';
import 'package:flame/components.dart';

extension EngineCollision on SnakeEngine {
  void checkCollisions() {
    final activeBots =
        bots.where((b) => b.isAlive && b.segments.isNotEmpty).toList();

    /// Verifica colisão cabeça-a-cabeça entre dois snakes.
    /// Apenas a cobra MAIOR pode matar a MENOR.
    /// Empate (mesmo tamanho) → nenhuma morre.
    void checkHeadToHead({
      required Vector2 headA,
      required double radiusA,
      required int lengthA,
      required Vector2 headB,
      required double radiusB,
      required int lengthB,
      required void Function() killA,
      required void Function() killB,
    }) {
      final double threshSq = (radiusA + radiusB) * (radiusA + radiusB);
      final double dx = headA.x - headB.x;
      final double dy = headA.y - headB.y;

      // Se não encostaram, sai da função
      if (dx * dx + dy * dy >= threshSq) return;

      // Lógica de sobrevivência baseada no tamanho (length)
      if (lengthA > lengthB) {
        killB();
      } else if (lengthB > lengthA) {
        killA();
      }
    }

    // ── 1. Jogador vs cada Bot ──────────────────────────────────────
    if (player.isAlive && player.segments.isNotEmpty) {
      final playerHead = player.segments.first; // ✅ Substituído headPosition

      for (final bot in activeBots) {
        if (!bot.isAlive || bot.segments.isEmpty) continue;

        final botHead = bot.segments.first; // ✅ Substituído headPosition

        checkHeadToHead(
          headA: playerHead,
          radiusA: player.headRadius,
          lengthA: player.length,
          headB: botHead,
          radiusB: bot.headRadius,
          lengthB: bot.segments.length,
          killA: () => handlePlayerDeath(),
          killB: () => bot.die(killedByPlayer: true),
        );

        if (!player.isAlive) break;
      }
    }

    // ── 2. Bot vs Bot ───────────────────────────────────────────────
    for (int a = 0; a < activeBots.length; a++) {
      final botA = activeBots[a];
      if (!botA.isAlive || botA.segments.isEmpty) continue;

      for (int b = a + 1; b < activeBots.length; b++) {
        final botB = activeBots[b];
        if (!botB.isAlive || botB.segments.isEmpty) continue;

        checkHeadToHead(
          headA: botA.segments.first, // ✅ Correção aqui
          radiusA: botA.headRadius,
          lengthA: botA.segments.length,
          headB: botB.segments.first, // ✅ Correção aqui
          radiusB: botB.headRadius,
          lengthB: botB.segments.length,
          killA: () => botA.die(killedByPlayer: false),
          killB: () => botB.die(killedByPlayer: false),
        );
      }
    }
  }

  void checkWallCollision() {
    // Usando a constante de espessura de parede para definir o limite
    const double margin = kWallThickness * 0.5;

    // Colisão do Jogador com a parede
    if (player.isAlive && player.segments.isNotEmpty) {
      final head = player.segments.first; // ✅ Correção aqui
      if (head.x < margin ||
          head.x > worldSize.x - margin ||
          head.y < margin ||
          head.y > worldSize.y - margin) {
        handlePlayerDeath();
      }
    }

    // Colisão dos Bots com a parede
    for (final bot in bots) {
      if (!bot.isAlive || bot.segments.isEmpty) continue;
      final bh = bot.segments.first; // ✅ Correção aqui
      if (bh.x < margin ||
          bh.x > worldSize.x - margin ||
          bh.y < margin ||
          bh.y > worldSize.y - margin) {
        bot.die(killedByPlayer: false);
      }
    }
  }
}
