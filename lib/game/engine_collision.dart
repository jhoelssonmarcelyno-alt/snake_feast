import '../components/snake_bot.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';
import 'package:flame/components.dart';

extension EngineCollision on SnakeEngine {
  // ─────────────────────────────────────────────────────────────────────────
  // Regra de morte atualizada:
  //   • APENAS Cabeça bate em Cabeça:
  //       - A maior sobrevive, a menor morre
  //       - Mesmo tamanho → ambas morrem
  //   • Tocar no corpo de outra cobra NÃO causa dano (corpos são neutros)
  // ─────────────────────────────────────────────────────────────────────────

  static double _distSq(Vector2 a, Vector2 b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return dx * dx + dy * dy;
  }

  void checkCollisions() {
    final List<SnakeBot> alive =
        bots.where((b) => b.isAlive && b.segments.isNotEmpty).toList();

    // ── 1. JOGADOR vs BOTS ───────────────────────────────────────────────
    if (player.isAlive && player.segments.isNotEmpty) {
      for (int i = 0; i < alive.length; i++) {
        final bot = alive[i];
        if (!bot.isAlive || bot.segments.isEmpty) continue;
        if (!player.isAlive || player.segments.isEmpty) break;

        final Vector2 pH = player.segments.first;
        final Vector2 bH = bot.segments.first;
        final double combinedR = player.headRadius + bot.headRadius;

        // ── Cabeça vs Cabeça ──────────────────────────────────────────
        if (_distSq(pH, bH) < combinedR * combinedR) {
          if (player.length > bot.segments.length) {
            bot.die(killedByPlayer: true);
          } else if (bot.segments.length > player.length) {
            handlePlayerDeath();
            break; // O jogador morreu, interrompe o laço para ele
          } else {
            // Empate de tamanho → ambos morrem
            bot.die(killedByPlayer: true);
            handlePlayerDeath();
            break; // O jogador morreu, interrompe o laço para ele
          }
        }
      }
    }

    // ── 2. BOT vs BOT ────────────────────────────────────────────────────
    final int n = alive.length;
    for (int a = 0; a < n; a++) {
      final botA = alive[a];
      if (!botA.isAlive || botA.segments.isEmpty) continue;

      for (int b = a + 1; b < n; b++) {
        final botB = alive[b];
        if (!botB.isAlive || botB.segments.isEmpty) continue;
        if (!botA.isAlive || botA.segments.isEmpty) break;

        final Vector2 hA = botA.segments.first;
        final Vector2 hB = botB.segments.first;
        final double combinedR = botA.headRadius + botB.headRadius;

        // ── Cabeça vs Cabeça ──────────────────────────────────────────
        if (_distSq(hA, hB) < combinedR * combinedR) {
          if (botA.segments.length > botB.segments.length) {
            botB.die(killedByPlayer: false);
          } else if (botB.segments.length > botA.segments.length) {
            botA.die(killedByPlayer: false);
            break; // botA morreu, interrompe o laço para o botA
          } else {
            // Empate de tamanho → ambos morrem
            botA.die(killedByPlayer: false);
            botB.die(killedByPlayer: false);
            break; // botA morreu, interrompe o laço para o botA
          }
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  void checkWallCollision() {
    const double margin = kWallThickness * 0.5;
    final double maxX = worldSize.x - margin;
    final double maxY = worldSize.y - margin;

    if (player.isAlive && player.segments.isNotEmpty) {
      final head = player.segments.first;
      if (head.x < margin ||
          head.x > maxX ||
          head.y < margin ||
          head.y > maxY) {
        handlePlayerDeath();
      }
    }

    for (final bot in bots) {
      if (!bot.isAlive || bot.segments.isEmpty) continue;
      final bh = bot.segments.first;
      if (bh.x < margin || bh.x > maxX || bh.y < margin || bh.y > maxY) {
        bot.die(killedByPlayer: false);
      }
    }
  }
}
