import 'package:flutter/material.dart';
import '../../../services/score_service.dart';
import '../../../services/level_service.dart';
import '../../../services/audio_service.dart';
import '../../../utils/constants.dart';
import '../widgets/glow_icon_button.dart';
import '../widgets/wallet_badge.dart';

Widget buildTopBar({
  required Animation<double> fade,
  required bool isOnline,
  required Function() onToggleOnline,
  required Function() onToggleMute,
  required Function() onOpenShop,
  required Function() onOpenSettings,
  required Function() onOpenRank,
}) {
  final levels = LevelService.instance.allLevels;
  final levelData =
      levels.isNotEmpty ? levels[ScoreService.instance.currentLevel - 1] : null;

  return Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            if (levelData != null)
              GestureDetector(
                onTap: onOpenRank,
                child: FadeTransition(
                  opacity: fade,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: levelData.themeColor.withOpacity(0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(levelData.rankIcon,
                            color: levelData.themeColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "FASE ${levelData.number}: ${levelData.rankName.toUpperCase()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.white54),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    WalletBadge(
                      coins: ScoreService.instance.coins,
                      diamonds: ScoreService.instance.diamonds,
                      fadeAnim: fade,
                    ),
                    const SizedBox(width: 8),
                    _circleBtn(
                      fade: fade,
                      icon: isOnline ? Icons.wifi : Icons.wifi_off,
                      color:
                          isOnline ? const Color(0xFF29CFFF) : Colors.white30,
                      onTap: onToggleOnline,
                    ),
                    const SizedBox(width: 8),
                    _circleBtn(
                      fade: fade,
                      icon: AudioService.instance.isMuted
                          ? Icons.volume_off
                          : Icons.volume_up,
                      color: AudioService.instance.isMuted
                          ? Colors.redAccent
                          : Colors.white,
                      onTap: onToggleMute,
                    ),
                  ],
                ),
                Row(
                  children: [
                    GlowIconButton(
                      onTap: onOpenShop,
                      color: const Color(0xFFFFD600),
                      icon: Icons.store,
                    ),
                    const SizedBox(width: 8),
                    GlowIconButton(
                      onTap: onOpenSettings,
                      color: const Color(0xFF29CFFF),
                      icon: Icons.settings,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _circleBtn({
  required Animation<double> fade,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return FadeTransition(
    opacity: fade,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    ),
  );
}
