import 'package:flutter/material.dart';
import 'xp_reward.dart';

enum Rank {
  bronze3,
  bronze2,
  bronze1,
  silver3,
  silver2,
  silver1,
  gold4,
  gold3,
  gold2,
  gold1,
  platinum5,
  platinum4,
  platinum3,
  platinum2,
  platinum1,
  diamond5,
  diamond4,
  diamond3,
  diamond2,
  diamond1,
  master,
  masterHonor,
  elite,
  eliteHonor,
  legendary,
}

class RankInfo {
  final Rank rank;
  final String name;
  final Color color;
  final Color colorDark;
  final IconData icon;
  final int winsRequired;  // Vitórias necessárias para atingir esta patente
  final double xpMultiplier;

  const RankInfo({
    required this.rank,
    required this.name,
    required this.color,
    required this.colorDark,
    required this.icon,
    required this.winsRequired,
    required this.xpMultiplier,
  });
}

class RankSystem {
  RankSystem._();

  static const List<RankInfo> ranks = [
    // ── BRONZE ────────────────────────────────────────────────
    RankInfo(
        rank: Rank.bronze3,
        name: 'Bronze III',
        color: Color(0xFFCD7F32),
        colorDark: Color(0xFF6D3A1F),
        icon: Icons.shield_outlined,
        winsRequired: 0,
        xpMultiplier: 1.0),
    RankInfo(
        rank: Rank.bronze2,
        name: 'Bronze II',
        color: Color(0xFFCD7F32),
        colorDark: Color(0xFF6D3A1F),
        icon: Icons.shield_outlined,
        winsRequired: 100,
        xpMultiplier: 1.1),
    RankInfo(
        rank: Rank.bronze1,
        name: 'Bronze I',
        color: Color(0xFFE8A060),
        colorDark: Color(0xFF6D3A1F),
        icon: Icons.shield,
        winsRequired: 200,
        xpMultiplier: 1.2),

    // ── PRATA ─────────────────────────────────────────────────
    RankInfo(
        rank: Rank.silver3,
        name: 'Prata III',
        color: Color(0xFFB0BEC5),
        colorDark: Color(0xFF546E7A),
        icon: Icons.shield_outlined,
        winsRequired: 300,
        xpMultiplier: 1.4),
    RankInfo(
        rank: Rank.silver2,
        name: 'Prata II',
        color: Color(0xFFB0BEC5),
        colorDark: Color(0xFF546E7A),
        icon: Icons.shield_outlined,
        winsRequired: 400,
        xpMultiplier: 1.6),
    RankInfo(
        rank: Rank.silver1,
        name: 'Prata I',
        color: Color(0xFFCFD8DC),
        colorDark: Color(0xFF546E7A),
        icon: Icons.shield,
        winsRequired: 500,
        xpMultiplier: 1.8),

    // ── OURO ──────────────────────────────────────────────────
    RankInfo(
        rank: Rank.gold4,
        name: 'Ouro IV',
        color: Color(0xFFFFD600),
        colorDark: Color(0xFFF57F17),
        icon: Icons.workspace_premium,
        winsRequired: 600,
        xpMultiplier: 2.0),
    RankInfo(
        rank: Rank.gold3,
        name: 'Ouro III',
        color: Color(0xFFFFD600),
        colorDark: Color(0xFFF57F17),
        icon: Icons.workspace_premium,
        winsRequired: 700,
        xpMultiplier: 2.2),
    RankInfo(
        rank: Rank.gold2,
        name: 'Ouro II',
        color: Color(0xFFFFD600),
        colorDark: Color(0xFFF57F17),
        icon: Icons.workspace_premium,
        winsRequired: 800,
        xpMultiplier: 2.4),
    RankInfo(
        rank: Rank.gold1,
        name: 'Ouro I',
        color: Color(0xFFFFE566),
        colorDark: Color(0xFFF57F17),
        icon: Icons.workspace_premium,
        winsRequired: 900,
        xpMultiplier: 2.6),

    // ── PLATINA ───────────────────────────────────────────────
    RankInfo(
        rank: Rank.platinum5,
        name: 'Platina V',
        color: Color(0xFF80DEEA),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond_outlined,
        winsRequired: 1000,
        xpMultiplier: 2.8),
    RankInfo(
        rank: Rank.platinum4,
        name: 'Platina IV',
        color: Color(0xFF80DEEA),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond_outlined,
        winsRequired: 1100,
        xpMultiplier: 3.0),
    RankInfo(
        rank: Rank.platinum3,
        name: 'Platina III',
        color: Color(0xFF80DEEA),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond_outlined,
        winsRequired: 1200,
        xpMultiplier: 3.2),
    RankInfo(
        rank: Rank.platinum2,
        name: 'Platina II',
        color: Color(0xFF80DEEA),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond_outlined,
        winsRequired: 1300,
        xpMultiplier: 3.4),
    RankInfo(
        rank: Rank.platinum1,
        name: 'Platina I',
        color: Color(0xFFB2EBF2),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond,
        winsRequired: 1400,
        xpMultiplier: 3.6),

    // ── DIAMANTE ──────────────────────────────────────────────
    RankInfo(
        rank: Rank.diamond5,
        name: 'Diamante V',
        color: Color(0xFF40C4FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        winsRequired: 1500,
        xpMultiplier: 3.8),
    RankInfo(
        rank: Rank.diamond4,
        name: 'Diamante IV',
        color: Color(0xFF40C4FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        winsRequired: 1600,
        xpMultiplier: 4.0),
    RankInfo(
        rank: Rank.diamond3,
        name: 'Diamante III',
        color: Color(0xFF40C4FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        winsRequired: 1700,
        xpMultiplier: 4.2),
    RankInfo(
        rank: Rank.diamond2,
        name: 'Diamante II',
        color: Color(0xFF40C4FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        winsRequired: 1800,
        xpMultiplier: 4.4),
    RankInfo(
        rank: Rank.diamond1,
        name: 'Diamante I',
        color: Color(0xFF80D8FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        winsRequired: 1900,
        xpMultiplier: 4.6),

    // ── TOPO (MESTRE / ELITE / LENDÁRIO) ─────────────────────
    RankInfo(
        rank: Rank.master,
        name: 'Mestre',
        color: Color(0xFFCE93D8),
        colorDark: Color(0xFF7B1FA2),
        icon: Icons.auto_awesome,
        winsRequired: 2000,
        xpMultiplier: 4.7),
    RankInfo(
        rank: Rank.masterHonor,
        name: 'Mestre de Honra',
        color: Color(0xFFAA00FF),
        colorDark: Color(0xFF4A148C),
        icon: Icons.auto_awesome,
        winsRequired: 2100,
        xpMultiplier: 4.8),
    RankInfo(
        rank: Rank.elite,
        name: 'Elite',
        color: Color(0xFFFF5252),
        colorDark: Color(0xFFB71C1C),
        icon: Icons.military_tech,
        winsRequired: 2200,
        xpMultiplier: 4.9),
    RankInfo(
        rank: Rank.eliteHonor,
        name: 'Elite de Honra',
        color: Color(0xFFFF1744),
        colorDark: Color(0xFF880E4F),
        icon: Icons.military_tech,
        winsRequired: 2300,
        xpMultiplier: 5.0),
    RankInfo(
        rank: Rank.legendary,
        name: 'Lendário',
        color: Color(0xFFFFD700),
        colorDark: Color(0xFFBF360C),
        icon: Icons.local_fire_department,
        winsRequired: 2500,
        xpMultiplier: 5.5),
  ];

  static RankInfo getRankForWins(int wins) {
    RankInfo current = ranks.first;
    for (final r in ranks) {
      if (wins >= r.winsRequired) {
        current = r;
      } else {
        break;
      }
    }
    return current;
  }

  static RankInfo? getNextRank(RankInfo current) {
    final idx = ranks.indexOf(current);
    if (idx < 0 || idx >= ranks.length - 1) return null;
    return ranks[idx + 1];
  }

  static double rankProgress(int wins) {
    final current = getRankForWins(wins);
    final next = getNextRank(current);
    if (next == null) return 1.0;
    final range = next.winsRequired - current.winsRequired;
    final gained = wins - current.winsRequired;
    return (gained / range).clamp(0.0, 1.0);
  }

  // Calcula recompensa baseada nas vitórias
  static XpReward calculateReward({
    required int score,
    required int kills,
    required int level,
    required double secondsAlive,
    required bool isVictory,
    required int totalWins,
  }) {
    final rank = getRankForWins(totalWins);
    final mult = rank.xpMultiplier;

    return XpReward(
      xpFromScore: (score / 10).floor().clamp(1, 10000),
      xpFromKills: (kills * 5 * mult).round(),
      xpFromLevel: (level * 3 * mult).round(),
      xpFromSurvival: (secondsAlive * 0.1 * mult).round(),
      xpFromVictory:
          isVictory ? (500 * mult).round() : 0,
      rankMultiplier: mult,
      isVictory: isVictory,
    );
  }
}
