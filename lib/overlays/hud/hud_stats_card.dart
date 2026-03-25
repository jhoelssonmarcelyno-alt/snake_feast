// lib/overlays/hud/hud_stats_card.dart
import 'package:flutter/material.dart';
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
  final int aliveSnakes;
  final int totalSnakes;

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

  Color _levelColor(int lvl) {
    if (lvl >= 50) return const Color(0xFF00E5FF);
    if (lvl >= 30) return const Color(0xFFE040FB);
    if (lvl >= 20) return const Color(0xFFFFD600);
    if (lvl >= 10) return const Color(0xFFB0BEC5);
    return const Color(0xFFCD7F32);
  }

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
            // Linha 1: KILLS / TAMANHO / RECORDE
            Row(mainAxisSize: MainAxisSize.min, children: [
              HudStat(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFFF5252),
                label: 'KILLS',
                value: '$kills',
                valueColor: const Color(0xFFFF5252),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.linear_scale_rounded,
                iconColor: const Color(0xFF69F0AE),
                label: 'TAMANHO',
                value: '$length',
                valueColor: const Color(0xFF69F0AE),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFD700),
                label: 'RECORDE',
                value: '$highScore',
                valueColor: const Color(0xFFFFD700),
              ),
            ]),
            const SizedBox(height: 6),
            // Linha 2: LEVEL / MOEDAS / DIAMANTES / VIDAS
            Row(mainAxisSize: MainAxisSize.min, children: [
              HudStat(
                icon: Icons.star_rounded,
                iconColor: _levelColor(level),
                label: 'LEVEL',
                value: '$level',
                valueColor: _levelColor(level),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.monetization_on_rounded,
                iconColor: const Color(0xFFFFD600),
                label: 'MOEDAS',
                value: '$coins',
                valueColor: const Color(0xFFFFD600),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.diamond_rounded,
                iconColor: const Color(0xFF00E5FF),
                label: 'DIAMANTES',
                value: '$diamonds',
                valueColor: const Color(0xFF00E5FF),
              ),
              const SizedBox(width: 12),
              HudStat(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFF2ECC71),
                label: 'VIDAS',
                value: '$revives',
                valueColor: const Color(0xFF2ECC71),
              ),
            ]),
            const SizedBox(height: 6),
            // Linha 3: Contador de cobras
            HudSnakeCounter(alive: aliveSnakes, total: totalSnakes),
          ]),
        ),
      ),
    );
  }
}
