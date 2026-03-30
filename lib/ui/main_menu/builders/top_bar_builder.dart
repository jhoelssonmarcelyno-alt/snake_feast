import 'package:flutter/material.dart';
import '../../../game/snake_engine.dart';
import '../../../utils/constants.dart';
import '../widgets/wallet_badge.dart';
import '../widgets/name_field.dart';
import '../widgets/glow_icon_button.dart';

class TopBarBuilder {
  static Widget build({
    required SnakeEngine engine,
    required bool isMuted,
    required int coins,
    required int diamonds,
    required VoidCallback onToggleMute,
    required VoidCallback onShowRank,
    required Animation<double> fadeAnim,
    required TextEditingController nameCtrl,
  }) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Lado esquerdo - Moedas e Diamantes
            WalletBadge(
              coins: coins,
              diamonds: diamonds,
            ),
            
            // Centro - Nome do jogador
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: NameField(
                  controller: nameCtrl,
                  onChanged: (name) {},
                ),
              ),
            ),
            
            // Lado direito - Botões
            Row(
              children: [
                GlowIconButton(
                  icon: isMuted ? Icons.volume_off : Icons.volume_up,
                  onTap: onToggleMute,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                GlowIconButton(
                  icon: Icons.leaderboard,
                  onTap: onShowRank,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                GlowIconButton(
                  icon: Icons.settings,
                  onTap: () {
                    engine.overlays.add(kOverlaySettings);
                  },
                  color: Colors.white70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
