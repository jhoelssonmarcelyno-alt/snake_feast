import 'package:flutter/material.dart';
import '../../../game/snake_engine.dart';
import '../../../utils/constants.dart';
import 'glow_icon_button.dart';

class MenuTopBar extends StatelessWidget {
  final SnakeEngine engine;
  final bool isMuted;
  final int coins;
  final int diamonds;
  final VoidCallback onToggleMute;
  final VoidCallback onShowRank;
  final Animation<double> fadeAnim;
  final TextEditingController nameCtrl;

  const MenuTopBar({
    super.key,
    required this.engine,
    required this.isMuted,
    required this.coins,
    required this.diamonds,
    required this.onToggleMute,
    required this.onShowRank,
    required this.fadeAnim,
    required this.nameCtrl,
  });

  void _showBuyDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        title: Text(
          'COMPRAR ${type == 'coins' ? 'MOEDAS' : 'DIAMANTES'}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        content: SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(
                icon: Icons.attach_money,
                color: const Color(0xFFFFD600),
                title: type == 'coins' ? '100 Moedas' : '10 Diamantes',
                price: type == 'coins' ? 'R\$ 1,99' : 'R\$ 4,99',
                onTap: () => Navigator.pop(context),
              ),
              _buildOption(
                icon: Icons.attach_money,
                color: const Color(0xFFFFD600),
                title: type == 'coins' ? '500 Moedas' : '50 Diamantes',
                price: type == 'coins' ? 'R\$ 7,99' : 'R\$ 19,99',
                onTap: () => Navigator.pop(context),
              ),
              _buildOption(
                icon: Icons.attach_money,
                color: const Color(0xFFFFD600),
                title: type == 'coins' ? '1000 Moedas' : '100 Diamantes',
                price: type == 'coins' ? 'R\$ 14,99' : 'R\$ 34,99',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR', style: TextStyle(color: Colors.white70, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required Color color,
    required String title,
    required String price,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 18),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
        trailing: Text(price, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        onTap: onTap,
        tileColor: Colors.white12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Lado esquerdo - Moedas e Diamantes
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Moedas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFFFD600).withValues(alpha: 0.12),
                    border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFFD600), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '$coins',
                        style: const TextStyle(
                          color: Color(0xFFFFD600),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      GestureDetector(
                        onTap: () => _showBuyDialog(context, 'coins'),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD600).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFFFFD600),
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Diamantes
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, color: Color(0xFF00E5FF), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '$diamonds',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      GestureDetector(
                        onTap: () => _showBuyDialog(context, 'diamonds'),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFF00E5FF),
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Centro - Nome do jogador (fixo)
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white12,
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              child: TextField(
                controller: nameCtrl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Nome',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Lado direito - Botões
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlowIconButton(
                  icon: isMuted ? Icons.volume_off : Icons.volume_up,
                  onTap: onToggleMute,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                GlowIconButton(
                  icon: Icons.leaderboard,
                  onTap: onShowRank,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
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
