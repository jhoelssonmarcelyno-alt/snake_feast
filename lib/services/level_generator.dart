import 'package:flutter/material.dart';

/// Modelo para a configuração de cada fase
class LevelConfig {
  final int number; // Número da fase (1 a 250)
  final String rankName; // Nome da Patente (ex: Bronze I)
  final double speed; // Velocidade da cobra
  final int targetScore; // Pontos necessários para passar
  final int rewardCoins; // Moedas ganhas ao vencer
  final Color themeColor; // Cor visual da fase

  LevelConfig({
    required this.number,
    required this.rankName,
    required this.speed,
    required this.targetScore,
    required this.rewardCoins,
    required this.themeColor,
  });
}

class LevelGenerator {
  /// Lista oficial das 25 patentes do Snake You
  static const List<String> _allRanks = [
    "Recruta",
    "Aprendiz",
    "Iniciante",
    "Praticante",
    "Bronze I",
    "Bronze II",
    "Bronze III",
    "Prata I",
    "Prata II",
    "Prata III",
    "Ouro I",
    "Ouro II",
    "Ouro III",
    "Platina I",
    "Platina II",
    "Platina III",
    "Diamante I",
    "Diamante II",
    "Diamante III",
    "Mestre I",
    "Mestre II",
    "Elite I",
    "Elite II",
    "Lenda",
    "Lendário"
  ];

  /// Gera a lista completa de 250 fases (10 por patente)
  static List<LevelConfig> generate250Levels() {
    return List.generate(250, (index) {
      final int levelNum = index + 1;

      // Calcula o índice da patente (0 a 24) baseando-se em blocos de 10 fases
      int rankIndex = (index / 10).floor();
      if (rankIndex >= _allRanks.length) rankIndex = _allRanks.length - 1;

      final String currentRank = _allRanks[rankIndex];

      // Lógica de Dificuldade Progressiva
      // Velocidade: Começa em 160 e aumenta 0.8 por fase
      final double calculatedSpeed = 160.0 + (levelNum * 0.8);

      // Meta de pontos: Começa em 30 e aumenta 15 por fase
      final int calculatedTarget = 30 + (levelNum * 15);

      // Recompensa: Base da patente + bônus de fase
      final int calculatedReward = ((rankIndex + 1) * 10) + (levelNum % 10);

      return LevelConfig(
        number: levelNum,
        rankName: currentRank,
        speed: calculatedSpeed,
        targetScore: calculatedTarget,
        rewardCoins: calculatedReward,
        themeColor: _getThemeForRank(rankIndex),
      );
    });
  }

  /// Define a cor visual da interface baseada no nível da patente
  static Color _getThemeForRank(int rankIndex) {
    if (rankIndex < 4) return Colors.green; // Iniciais
    if (rankIndex < 7) return Colors.brown; // Bronze
    if (rankIndex < 10) return Colors.grey; // Prata
    if (rankIndex < 13) return Colors.amber; // Ouro
    if (rankIndex < 16) return Colors.cyan; // Platina
    if (rankIndex < 19) return Colors.blueAccent; // Diamante
    if (rankIndex < 21) return Colors.purple; // Mestre
    if (rankIndex < 23) return Colors.deepOrange; // Elite/Lenda
    return Colors.redAccent; // Lendário
  }

  /// Retorna apenas uma fase específica pelo número
  static LevelConfig getLevel(int number) {
    final all = generate250Levels();
    if (number < 1) return all.first;
    if (number > 250) return all.last;
    return all[number - 1];
  }
}
