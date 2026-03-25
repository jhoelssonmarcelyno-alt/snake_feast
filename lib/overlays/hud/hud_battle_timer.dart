// lib/overlays/hud/hud_battle_timer.dart
import 'package:flutter/material.dart';

class HudBattleTimer extends StatelessWidget {
  final String timerText;
  final int phase; // 0=normal, 1=aviso, 2=perigo
  final bool inGrace;
  final AnimationController pulseCtrl;

  const HudBattleTimer({
    super.key,
    required this.timerText,
    required this.phase,
    required this.inGrace,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final Color timerColor = switch (phase) {
      1 => const Color(0xFFFFD600),
      2 => const Color(0xFFFF3D00),
      _ => const Color(0xFF00E5FF),
    };

    Widget timerWidget = Text(
      timerText,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
        height: 1.0,
        color: timerColor,
        decoration: TextDecoration.none,
        shadows: [
          Shadow(
            color: timerColor.withValues(alpha: phase == 2 ? 0.8 : 0.4),
            blurRadius: phase == 2 ? 16 : 8,
          ),
        ],
      ),
    );

    if (phase == 2) {
      timerWidget = AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, child) => Opacity(
          opacity: 0.6 + pulseCtrl.value * 0.4,
          child: child,
        ),
        child: timerWidget,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withValues(alpha: 0.35),
        border: Border.all(
          color: timerColor.withValues(alpha: phase == 2 ? 0.8 : 0.3),
          width: phase == 2 ? 1.5 : 1.0,
        ),
        boxShadow: phase >= 1
            ? [
                BoxShadow(
                  color: timerColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inGrace ? Icons.shield_rounded : Icons.compress_rounded,
            color: timerColor.withValues(alpha: 0.85),
            size: 14,
          ),
          const SizedBox(width: 6),
          timerWidget,
          if (inGrace) ...[
            const SizedBox(width: 6),
            Text(
              'GRAÇA',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: timerColor.withValues(alpha: 0.55),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
