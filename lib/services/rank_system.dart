// lib/services/rank_system.dart
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
  final int xpRequired;
  final double xpMultiplier;

  const RankInfo({
    required this.rank,
    required this.name,
    required this.color,
    required this.colorDark,
    required this.icon,
    required this.xpRequired,
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
        xpRequired: 0,
        xpMultiplier: 1.0),
    RankInfo(
        rank: Rank.bronze2,
        name: 'Bronze II',
        color: Color(0xFFCD7F32),
        colorDark: Color(0xFF6D3A1F),
        icon: Icons.shield_outlined,
        xpRequired: 1000,
        xpMultiplier: 1.1),
    RankInfo(
        rank: Rank.bronze1,
        name: 'Bronze I',
        color: Color(0xFFE8A060),
        colorDark: Color(0xFF6D3A1F),
        icon: Icons.shield,
        xpRequired: 2000,
        xpMultiplier: 1.2),

    // ── PRATA ─────────────────────────────────────────────────
    RankInfo(
        rank: Rank.silver3,
        name: 'Prata III',
        color: Color(0xFFB0BEC5),
        colorDark: Color(0xFF546E7A),
        icon: Icons.shield_outlined,
        xpRequired: 4000,
        xpMultiplier: 1.4),
    RankInfo(
        rank: Rank.silver2,
        name: 'Prata II',
        color: Color(0xFFB0BEC5),
        colorDark: Color(0xFF546E7A),
        icon: Icons.shield_outlined,
        xpRequired: 8000,
        xpMultiplier: 1.6),
    RankInfo(
        rank: Rank.silver1,
        name: 'Prata I',
        color: Color(0xFFCFD8DC),
        colorDark: Color(0xFF546E7A),
        icon: Icons.shield,
        xpRequired: 16000,
        xpMultiplier: 1.8),

    // ── OURO ──────────────────────────────────────────────────
    RankInfo(
        rank: Rank.gold4,
        name: 'Ouro IV',
        color: Color(0xFFFFD600),
        colorDark: Color(0xFFF57F17),
        icon: Icons.workspace_premium,
        xpRequired: 32000,
        xpMultiplier: 2.0),
    RankInfo(
        rank: Rank.gold3,
        name: 'Ouro III',
        color: Color(0xFFFFD600),
        colorDark: Color(0xFFF57F17),
        icon: Icons.workspace_premium,
        xpRequired: 64000,
        xpMultiplier: 2.2),
    RankInfo(
        rank: Rank.gold2,
        name: 'Ouro II',
        color: Color(0xFFFFD600),
        colorDark: Color(0xFFF57F17),
        icon: Icons.workspace_premium,
        xpRequired: 128000,
        xpMultiplier: 2.4),
    RankInfo(
        rank: Rank.gold1,
        name: 'Ouro I',
        color: Color(0xFFFFE566),
        colorDark: Color(0xFFF57F17),
        icon: Icons.workspace_premium,
        xpRequired: 256000,
        xpMultiplier: 2.6),

    // ── PLATINA ───────────────────────────────────────────────
    RankInfo(
        rank: Rank.platinum5,
        name: 'Platina V',
        color: Color(0xFF80DEEA),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond_outlined,
        xpRequired: 512000,
        xpMultiplier: 2.8),
    RankInfo(
        rank: Rank.platinum4,
        name: 'Platina IV',
        color: Color(0xFF80DEEA),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond_outlined,
        xpRequired: 1024000,
        xpMultiplier: 3.0),
    RankInfo(
        rank: Rank.platinum3,
        name: 'Platina III',
        color: Color(0xFF80DEEA),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond_outlined,
        xpRequired: 2048000,
        xpMultiplier: 3.2),
    RankInfo(
        rank: Rank.platinum2,
        name: 'Platina II',
        color: Color(0xFF80DEEA),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond_outlined,
        xpRequired: 4096000,
        xpMultiplier: 3.4),
    RankInfo(
        rank: Rank.platinum1,
        name: 'Platina I',
        color: Color(0xFFB2EBF2),
        colorDark: Color(0xFF00838F),
        icon: Icons.diamond,
        xpRequired: 8192000,
        xpMultiplier: 3.6),

    // ── DIAMANTE ──────────────────────────────────────────────
    RankInfo(
        rank: Rank.diamond5,
        name: 'Diamante V',
        color: Color(0xFF40C4FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        xpRequired: 16384000,
        xpMultiplier: 3.8),
    RankInfo(
        rank: Rank.diamond4,
        name: 'Diamante IV',
        color: Color(0xFF40C4FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        xpRequired: 32768000,
        xpMultiplier: 4.0),
    RankInfo(
        rank: Rank.diamond3,
        name: 'Diamante III',
        color: Color(0xFF40C4FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        xpRequired: 65536000,
        xpMultiplier: 4.2),
    RankInfo(
        rank: Rank.diamond2,
        name: 'Diamante II',
        color: Color(0xFF40C4FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        xpRequired: 131072000,
        xpMultiplier: 4.4),
    RankInfo(
        rank: Rank.diamond1,
        name: 'Diamante I',
        color: Color(0xFF80D8FF),
        colorDark: Color(0xFF0277BD),
        icon: Icons.bolt,
        xpRequired: 262144000,
        xpMultiplier: 4.6),

    // ── TOPO (MESTRE / ELITE / LENDÁRIO) ─────────────────────
    RankInfo(
        rank: Rank.master,
        name: 'Mestre',
        color: Color(0xFFCE93D8),
        colorDark: Color(0xFF7B1FA2),
        icon: Icons.auto_awesome,
        xpRequired: 524288000,
        xpMultiplier: 4.7),
    RankInfo(
        rank: Rank.masterHonor,
        name: 'Mestre de Honra',
        color: Color(0xFFAA00FF),
        colorDark: Color(0xFF4A148C),
        icon: Icons.auto_awesome,
        xpRequired: 1048576000,
        xpMultiplier: 4.8),
    RankInfo(
        rank: Rank.elite,
        name: 'Elite',
        color: Color(0xFFFF5252),
        colorDark: Color(0xFFB71C1C),
        icon: Icons.military_tech,
        xpRequired: 2097152000,
        xpMultiplier: 4.9),
    RankInfo(
        rank: Rank.eliteHonor,
        name: 'Elite de Honra',
        color: Color(0xFFFF1744),
        colorDark: Color(0xFF880E4F),
        icon: Icons.military_tech,
        xpRequired: 4194304000,
        xpMultiplier: 5.0),
    RankInfo(
        rank: Rank.legendary,
        name: 'Lendário',
        color: Color(0xFFFFD700),
        colorDark: Color(0xFFBF360C),
        icon: Icons.local_fire_department,
        xpRequired: 8388608000,
        xpMultiplier: 5.5),
  ];

  static RankInfo getRankForXP(int xp) {
    RankInfo current = ranks.first;
    for (final r in ranks) {
      if (xp >= r.xpRequired) {
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

  static double rankProgress(int xp) {
    final current = getRankForXP(xp);
    final next = getNextRank(current);
    if (next == null) return 1.0;
    final range = next.xpRequired - current.xpRequired;
    final gained = xp - current.xpRequired;
    return (gained / range).clamp(0.0, 1.0);
  }

  // Cálculos de recompensa por partida
  static XpReward calculateReward({
    required int score,
    required int kills,
    required int level,
    required double secondsAlive,
    required bool isVictory,
    required int currentXP,
  }) {
    final rank = getRankForXP(currentXP);
    final mult = rank.xpMultiplier;

    return XpReward(
      xpFromScore: (score / 10).floor().clamp(1, 10000),
      xpFromKills: (kills * 5 * mult).round(),
      xpFromLevel: (level * 3 * mult).round(),
      xpFromSurvival: (secondsAlive * 0.1 * mult).round(),
      xpFromVictory:
          isVictory ? (500 * mult).round() : 0, // Vitória agora vale 500 base
      rankMultiplier: mult,
      isVictory: isVictory,
    );
  }
}
