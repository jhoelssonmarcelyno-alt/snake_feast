import 'package:flutter/material.dart';
import '../../../services/level_service.dart';

class LevelSelectorWidget extends StatelessWidget {
  final int selectedIndex;
  final Animation<double> fadeAnim;
  final double scale;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const LevelSelectorWidget({
    super.key,
    required this.selectedIndex,
    required this.fadeAnim,
    required this.scale,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final levels = LevelService.instance.allLevels;
    if (levels.isEmpty) return const SizedBox.shrink();

    final level = levels[selectedIndex];

    return FadeTransition(
      opacity: fadeAnim,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
        child: Column(
          children: [
            Text(
              'FASE ${level.number}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10 * scale,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão anterior
                GestureDetector(
                  onTap: onPrev,
                  child: Container(
                    width: 28 * scale,
                    height: 28 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      size: 18 * scale,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Nome da fase
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(
                      color: level.themeColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        level.rankIcon,
                        size: 14 * scale,
                        color: level.themeColor,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        level.rankName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Botão próximo
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    width: 28 * scale,
                    height: 28 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 18 * scale,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Meta: ${level.targetScore} pts',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 8 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
