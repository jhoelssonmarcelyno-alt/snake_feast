import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'hud_widgets.dart';
import 'hud_snake_counter.dart';

class HudStatsCard extends StatelessWidget {
  final int kills;
  final int length;
  final int highScore;
  final int level;
  final int coins;
  final int diamonds;
  final int revives;

  final ValueListenable<int> aliveSnakes;
  final ValueListenable<int> totalSnakes;

  const HudStatsCard({
    super.key,
    required this.kills,
    required this.length,
    required this.highScore,
    required this.level,
    required this.coins,
    required this.diamonds,
    required this.revives,
    required this.aliveSnakes,
    required this.totalSnakes,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(right: 12, top: 10),
          child: HudCard(children: [
            // ── PRIMEIRA LINHA: Só o que importa no combate ──
            Row(mainAxisSize: MainAxisSize.min, children: [
              HudStat(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFF5252),
                label: 'KILLS',
                value: '$kills',
                valueColor: const Color(0xFFFF5252),
              ),
              const SizedBox(width: 16), // Aumentei um pouco o espaço
              HudStat(
                icon: Icons.linear_scale_rounded,
                iconColor: const Color(0xFF69F0AE),
                label: 'TAMANHO',
                value: '$length',
                valueColor: const Color(0xFF69F0AE),
              ),
            ]),

            const SizedBox(height: 8),

            // ── SEGUNDA LINHA: Contador de Cobras (Inimigos Vivos) ──
            // Removi a linha de moedas/diamantes/level/recorde daqui
            HudSnakeCounter(
              alive: aliveSnakes,
              total: totalSnakes,
            ),
          ]),
        ),
      ),
    );
  }
}
