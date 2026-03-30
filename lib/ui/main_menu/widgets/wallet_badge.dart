import 'package:flutter/material.dart';

class WalletBadge extends StatelessWidget {
  final int coins;
  final int diamonds;

  const WalletBadge({
    super.key,
    required this.coins,
    required this.diamonds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black54,
        border: Border.all(color: const Color(0xFFFFD600).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFD600), size: 14),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: const TextStyle(
              color: Color(0xFFFFD600),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.diamond, color: Color(0xFF00E5FF), size: 14),
          const SizedBox(width: 4),
          Text(
            '$diamonds',
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
