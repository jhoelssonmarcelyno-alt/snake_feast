// lib/game/win/win_xp_breakdown.dart
import 'package:flutter/material.dart';
import '../../services/xp_reward.dart';

class WinXpBreakdown extends StatelessWidget {
  final XpReward reward;
  const WinXpBreakdown({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF0D1F38),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        children: [
          _XpLine(label: '🎯  Score',          value: reward.xpFromScore),
          _XpLine(label: '💀  Kills',           value: reward.xpFromKills),
          _XpLine(label: '⭐  Level',           value: reward.xpFromLevel),
          _XpLine(label: '⏱️  Sobrevivência',   value: reward.xpFromSurvival),
          if (reward.isVictory)
            _XpLine(
              label: '🏆  Vitória',
              value: reward.xpFromVictory,
              highlight: true,
            ),
          const SizedBox(height: 6),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 6),
          Row(children: [
            Text(
              '×${reward.rankMultiplier.toStringAsFixed(1)} (patente)',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 10,
                  fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            Text(
              '+${reward.total} XP',
              style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w900),
            ),
          ]),
        ],
      ),
    );
  }
}

class _XpLine extends StatelessWidget {
  final String label;
  final int value;
  final bool highlight;

  const _XpLine(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? const Color(0xFFFFD700)
        : Colors.white.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text(label, style: TextStyle(color: color, fontSize: 12)),
        const Spacer(),
        Text('+$value XP',
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}
