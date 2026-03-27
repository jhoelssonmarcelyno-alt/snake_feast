import 'package:flutter/material.dart' show Color, IconData, Icons, immutable;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_config.dart';

class LevelService {
  LevelService._();
  static final instance = LevelService._();

  static const String _keyUnlocked = 'unlocked_level';

  List<LevelConfig> _levels = [];
  int _unlockedUpTo = 1;

  List<LevelConfig> get allLevels => _levels;
  int get unlockedUpTo => _unlockedUpTo;

  // ── Inicialização ────────────────────────────────────────────
  Future<void> init() async {
    _levels = _buildLevels();
    final prefs = await SharedPreferences.getInstance();
    _unlockedUpTo = prefs.getInt(_keyUnlocked) ?? 1;
  }

  // ── Desbloquear próximo nível após vitória ───────────────────
  Future<void> unlockNext() async {
    if (_unlockedUpTo < _levels.length) {
      _unlockedUpTo++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUnlocked, _unlockedUpTo);
    }
  }

  bool isUnlocked(int levelNumber) => levelNumber <= _unlockedUpTo;

  LevelConfig? get currentLevel =>
      _levels.isNotEmpty ? _levels[_unlockedUpTo - 1] : null;

  // ── Geração dos 250 níveis ───────────────────────────────────
  List<LevelConfig> _buildLevels() {
    final levels = <LevelConfig>[];

    for (int i = 1; i <= 250; i++) {
      final t = (i - 1) / 249.0; // 0.0 → 1.0

      // Velocidade: 130 → 320
      final speed = 130.0 + t * 190.0;

      // Pontuação alvo: 50 → 5000 (curva quadrática)
      final targetScore = (50 + (t * t * 4950)).round();

      // Moedas de recompensa: 10 → 500
      final rewardCoins = (10 + t * 490).round();

      // Dificuldade dos bots: 0.0 → 1.0 (usado externamente)
      // Guardamos no botDifficulty do LevelConfig

      // Cor do tema (cicla por 10 paletas progressivas)
      final themeColor = _themeForLevel(i);

      // Ícone e nome do rank (muda a cada ~25 níveis)
      final rank = _rankForLevel(i);

      levels.add(LevelConfig(
        number: i,
        rankName: rank.name,
        speed: speed,
        targetScore: targetScore,
        rewardCoins: rewardCoins,
        themeColor: themeColor,
        rankIcon: rank.icon,
        botDifficulty: t, // 0.0 = fácil, 1.0 = difícil
      ));
    }

    return levels;
  }

  // ── Paleta de cores por faixa de nível ──────────────────────
  Color _themeForLevel(int level) {
    // 10 faixas de 25 níveis cada
    final band = ((level - 1) ~/ 25) % 10;
    const colors = [
      Color(0xFF2D5A2D), // 1–25   Verde floresta
      Color(0xFF1A3A5C), // 26–50  Azul oceano
      Color(0xFF5C2D1A), // 51–75  Laranja deserto
      Color(0xFF2D1A5C), // 76–100 Roxo noite
      Color(0xFF1A5C3A), // 101–125 Verde água
      Color(0xFF5C1A1A), // 126–150 Vermelho vulcão
      Color(0xFF1A4A5C), // 151–175 Ciano gelo
      Color(0xFF3A2D1A), // 176–200 Marrom terra
      Color(0xFF1A1A5C), // 201–225 Azul profundo
      Color(0xFF4A1A5C), // 226–250 Roxo espacial
    ];
    return colors[band];
  }

  // ── Rank por faixa de nível ──────────────────────────────────
  _Rank _rankForLevel(int level) {
    if (level <= 10) return _Rank('Recruta', Icons.emoji_nature);
    if (level <= 25) return _Rank('Iniciante', Icons.star_border);
    if (level <= 50) return _Rank('Aprendiz', Icons.star_half);
    if (level <= 75) return _Rank('Guerreiro', Icons.shield);
    if (level <= 100) return _Rank('Veterano', Icons.military_tech);
    if (level <= 125) return _Rank('Elite', Icons.bolt);
    if (level <= 150) return _Rank('Mestre', Icons.workspace_premium);
    if (level <= 175) return _Rank('Grão-Mestre', Icons.diamond);
    if (level <= 200) return _Rank('Lendário', Icons.auto_awesome);
    if (level <= 225) return _Rank('Mítico', Icons.whatshot);
    return _Rank('Imortal', Icons.emoji_events);
  }
}

class _Rank {
  final String name;
  final IconData icon;
  const _Rank(this.name, this.icon);
}
