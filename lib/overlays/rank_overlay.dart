// lib/overlays/rank_overlay.dart
import 'package:flutter/material.dart';
import '../services/rank_system.dart';
import '../services/score_service.dart';

class RankOverlay extends StatelessWidget {
  final VoidCallback onClose;
  const RankOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final totalXP = ScoreService.instance.totalXP;
    final currentRank = RankSystem.getRankForXP(totalXP);
    final nextRank = RankSystem.getNextRank(currentRank);
    final xpIntoRank = totalXP - currentRank.xpRequired;
    final xpNeeded =
        nextRank != null ? nextRank.xpRequired - currentRank.xpRequired : 1;
    final progress =
        nextRank != null ? (xpIntoRank / xpNeeded).clamp(0.0, 1.0) : 1.0;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: Container(
          color: Colors.black.withValues(alpha: 0.88),
          child: SafeArea(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                constraints:
                    const BoxConstraints(maxWidth: 480, maxHeight: 560),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF0D1B2A),
                  border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 40)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ───────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        color: currentRank.colorDark,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(currentRank.icon,
                                color: currentRank.color, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              'TABELA DE PATENTES',
                              style: TextStyle(
                                color: currentRank.color,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                          ]),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: onClose,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── XP atual ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(currentRank.icon,
                                color: currentRank.color, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              currentRank.name,
                              style: TextStyle(
                                color: currentRank.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$totalXP XP',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              valueColor:
                                  AlwaysStoppedAnimation(currentRank.color),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (nextRank != null)
                            Text(
                              '$xpIntoRank / $xpNeeded XP → ${nextRank.name}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                              ),
                            )
                          else
                            Text(
                              'Patente máxima atingida!',
                              style: TextStyle(
                                color: currentRank.color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Divider(color: Color(0xFF1E3A5F), height: 1),

                    // ── Lista de patentes ─────────────────────────
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        itemCount: RankSystem.ranks.length,
                        itemBuilder: (context, i) {
                          final r = RankSystem.ranks[i];
                          final isCurrentRank = r.rank == currentRank.rank;
                          final isUnlocked = totalXP >= r.xpRequired;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isCurrentRank
                                  ? r.color.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.03),
                              border: Border.all(
                                color: isCurrentRank
                                    ? r.color.withValues(alpha: 0.6)
                                    : Colors.white.withValues(alpha: 0.06),
                                width: isCurrentRank ? 1.5 : 1,
                              ),
                            ),
                            child: Row(children: [
                              Icon(
                                r.icon,
                                color: isUnlocked
                                    ? r.color
                                    : Colors.white.withValues(alpha: 0.2),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  r.name,
                                  style: TextStyle(
                                    color: isUnlocked
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.3),
                                    fontWeight: isCurrentRank
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (isCurrentRank)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: r.color.withValues(alpha: 0.2),
                                    border: Border.all(
                                        color: r.color.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    'ATUAL',
                                    style: TextStyle(
                                      color: r.color,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '${r.xpRequired} XP',
                                  style: TextStyle(
                                    color: isUnlocked
                                        ? Colors.white.withValues(alpha: 0.4)
                                        : Colors.white.withValues(alpha: 0.15),
                                    fontSize: 12,
                                  ),
                                ),
                            ]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
