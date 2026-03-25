// lib/services/xp_reward.dart

/// Resultado detalhado de XP ganho em uma partida.
class XpReward {
  final int xpFromScore;
  final int xpFromKills;
  final int xpFromLevel;
  final int xpFromSurvival;
  final int xpFromVictory;
  final double rankMultiplier;
  final bool isVictory;

  const XpReward({
    required this.xpFromScore,
    required this.xpFromKills,
    required this.xpFromLevel,
    required this.xpFromSurvival,
    required this.xpFromVictory,
    required this.rankMultiplier,
    required this.isVictory,
  });

  /// XP total já com o multiplicador de patente aplicado.
  int get total {
    final raw = xpFromScore + xpFromKills + xpFromLevel + xpFromSurvival + xpFromVictory;
    return (raw * rankMultiplier).round().clamp(1, 999999);
  }

  /// XP bruto antes do multiplicador (para mostrar no breakdown).
  int get rawTotal =>
      xpFromScore + xpFromKills + xpFromLevel + xpFromSurvival + xpFromVictory;
}
