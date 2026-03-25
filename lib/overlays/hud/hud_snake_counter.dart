// lib/overlays/hud/hud_snake_counter.dart
import 'package:flutter/material.dart';

class HudSnakeCounter extends StatelessWidget {
  final int alive;
  final int total;

  const HudSnakeCounter({super.key, required this.alive, required this.total});

  @override
  Widget build(BuildContext context) {
    final double ratio = total > 0 ? alive / total : 0.0;

    final Color barColor = ratio > 0.66
        ? const Color(0xFF69FF47)
        : ratio > 0.33
            ? const Color(0xFFFFD600)
            : const Color(0xFFFF5252);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐍',
                style: TextStyle(fontSize: 10, decoration: TextDecoration.none)),
            const SizedBox(width: 4),
            const Text('COBRAS',
                style: TextStyle(
                  color: Color(0xFF546E7A),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  decoration: TextDecoration.none,
                )),
            const SizedBox(width: 6),
            Text('$alive',
                style: TextStyle(
                  color: barColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  decoration: TextDecoration.none,
                )),
            Text(' / $total',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  decoration: TextDecoration.none,
                )),
          ],
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 110,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(color: Colors.white.withValues(alpha: 0.10)),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
