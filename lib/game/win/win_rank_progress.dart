// lib/game/win/win_rank_progress.dart
import 'package:flutter/material.dart';
import '../../services/rank_system.dart';

class WinRankProgress extends StatelessWidget {
  final RankInfo rank;
  final RankInfo? next;
  final double progress;
  final int totalXP;

  const WinRankProgress({
    super.key,
    required this.rank,
    required this.next,
    required this.progress,
    required this.totalXP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF0D1F38),
        border: Border.all(
            color: rank.color.withValues(alpha: 0.30), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(rank.icon, color: rank.color, size: 20),
            const SizedBox(width: 8),
            Text(rank.name,
                style: TextStyle(
                    color: rank.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const Spacer(),
            Text('$totalXP XP',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11)),
          ]),
          if (next != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(rank.color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Próxima: ${next!.name}  (${next!.xpRequired} XP)',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Patente máxima atingida!',
                  style: TextStyle(
                      color: rank.color.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }
}
