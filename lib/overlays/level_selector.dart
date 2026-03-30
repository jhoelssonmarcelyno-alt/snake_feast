import 'package:flutter/material.dart';
import '../services/level_service.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class LevelSelectorOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Function(int) onSelectLevel;

  const LevelSelectorOverlay({
    super.key,
    required this.onClose,
    required this.onSelectLevel,
  });

  @override
  State<LevelSelectorOverlay> createState() => _LevelSelectorOverlayState();
}

class _LevelSelectorOverlayState extends State<LevelSelectorOverlay> {
  int _selectedLevel = 0;

  @override
  void initState() {
    super.initState();
    // Pega o level atual do LevelService
    final currentLevelConfig = LevelService.instance.currentLevel;
    final currentLevelNumber = currentLevelConfig?.number ?? 1;
    _selectedLevel = (currentLevelNumber - 1).clamp(0, 0);
    if (_selectedLevel < 0) _selectedLevel = 0;
  }

  void _selectLevel(int levelIndex) {
    setState(() {
      _selectedLevel = levelIndex;
    });
    widget.onSelectLevel(levelIndex + 1);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final levels = LevelService.instance.allLevels;
    final skinIndex = ScoreService.instance.selectedSkinIndex;
    final skin = kPlayerSkins[skinIndex.clamp(0, kPlayerSkins.length - 1)];
    
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: skin.accentColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: skin.accentColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: skin.accentColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'SELECIONAR FASE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de fases
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final isUnlocked = LevelService.instance.isUnlocked(level.number);
                    final isSelected = index == _selectedLevel;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: isUnlocked
                            ? () => _selectLevel(index)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? skin.accentColor
                              : (isUnlocked ? Colors.white10 : Colors.white10),
                          foregroundColor: isSelected ? Colors.black : Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isSelected
                                ? BorderSide(color: skin.accentColor, width: 2)
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isUnlocked ? Icons.lock_open : Icons.lock,
                              color: isSelected
                                  ? Colors.black
                                  : (isUnlocked ? Colors.white70 : Colors.white38),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FASE ${level.number}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    level.rankName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.black87
                                          : Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white24
                                    : Colors.white12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${level.targetScore} pts',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Rodapé
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('FECHAR'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
