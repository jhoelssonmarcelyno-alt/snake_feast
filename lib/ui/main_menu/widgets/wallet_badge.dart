// lib/ui/main_menu/widgets/wallet_badge.dart
// Exibe saldo de moedas e diamantes no menu principal.
import 'package:flutter/material.dart';

class WalletBadge extends StatelessWidget {
  final int coins;
  final int diamonds;
  final Animation<double> fadeAnim;

  const WalletBadge({
    super.key,
    required this.coins,
    required this.diamonds,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 14),
          child: FadeTransition(
            opacity: fadeAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withValues(alpha: 0.55),
                border: Border.all(
                    color: const Color(0xFFFFD600).withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.monetization_on_rounded,
                    color: Color(0xFFFFD600), size: 16),
                const SizedBox(width: 5),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.diamond_rounded,
                    color: Color(0xFF00E5FF), size: 16),
                const SizedBox(width: 5),
                Text(
                  '$diamonds',
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
