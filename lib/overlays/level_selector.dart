import 'package:flutter/material.dart';
import '../services/level_service.dart';
import '../services/score_service.dart';
import '../models/level_config.dart';

class LevelSelector extends StatelessWidget {
  const LevelSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Usa a instância do Singleton que criamos no LevelService
    final List<LevelConfig> levels = LevelService.instance.allLevels;

    // 2. Pega o progresso real do jogador do ScoreService
    final int unlockedLevel = ScoreService.instance.currentLevel;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'MAPA DE FASES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.green[900],
        elevation: 10,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[900]!.withValues(alpha: 0.2), Colors.black],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          // BouncingScrollPhysics dá aquele efeito de "mola" ao chegar no fim (padrão iOS/Premium)
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];

            // A fase está liberada se o número dela for <= ao nível atual do jogador
            bool isLocked = level.number > unlockedLevel;

            return _buildLevelButton(context, level, isLocked);
          },
        ),
      ),
    );
  }

  Widget _buildLevelButton(
      BuildContext context, LevelConfig level, bool isLocked) {
    // Verifica se é uma fase de "Boss" (múltiplos de 10) para destaque visual
    final bool isBoss = level.number % 10 == 0;

    return GestureDetector(
      onTap: isLocked
          ? () => _showLockedMsg(context, level.rankName, level.number)
          : () => _startLevel(context, level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey[900]?.withValues(alpha: 0.5)
              : level.themeColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBoss
                ? Colors.amberAccent
                : (isLocked ? Colors.white10 : Colors.white30),
            width: isBoss ? 2.5 : 1,
          ),
          boxShadow: [
            if (!isLocked)
              BoxShadow(
                color: level.themeColor.withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: 1,
              )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${level.number}',
                  style: TextStyle(
                    color: isLocked ? Colors.white24 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (!isLocked)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      level.rankName.split(' ')[0].toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (isLocked)
              const Positioned(
                top: 4,
                right: 4,
                child:
                    Icon(Icons.lock_outline, color: Colors.white24, size: 12),
              ),
            if (isBoss)
              Positioned(
                bottom: 4,
                child: Icon(Icons.stars_rounded,
                    color: isLocked ? Colors.white10 : Colors.amberAccent,
                    size: 14),
              ),
          ],
        ),
      ),
    );
  }

  void _showLockedMsg(BuildContext context, String rank, int num) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Vença a fase anterior para liberar a Fase $num ($rank)!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[900],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startLevel(BuildContext context, LevelConfig level) {
    debugPrint('🚀 Snake You: Iniciando Fase ${level.number}');

    // Aqui você integra com a sua SnakeEngine
    // Exemplo: ScoreService.instance.setSelectedLevel(level.number);
    // Navigator.pushReplacementNamed(context, '/game_screen');
  }
}
