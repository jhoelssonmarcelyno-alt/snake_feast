import 'package:flutter/material.dart';

class LevelConfig {
  final int number;
  final String rankName;
  final double speed;
  final int targetScore;
  final int rewardCoins;
  final Color themeColor;
  final IconData rankIcon;

  /// 0.0 = fácil, 1.0 = máximo — usado pelo SnakeBot para calibrar IA
  final double botDifficulty;

  LevelConfig({
    required this.number,
    required this.rankName,
    required this.speed,
    required this.targetScore,
    required this.rewardCoins,
    required this.themeColor,
    required this.rankIcon,
    this.botDifficulty = 0.0,
  });
}
