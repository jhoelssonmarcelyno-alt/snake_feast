// lib/ui/main_menu/widgets/play_row.dart
// Linha com botão JOGAR + MULTI + recorde
import 'package:flutter/material.dart';
import 'play_button.dart';

class PlayRow extends StatelessWidget {
  final AnimationController borderCtrl;
  final AnimationController glowCtrl;
  final Animation<double> btnFade;
  final double scale;
  final int highScore;
  final VoidCallback onPlay;
  final VoidCallback onMulti;

  const PlayRow({
    super.key,
    required this.borderCtrl,
    required this.glowCtrl,
    required this.btnFade,
    required this.scale,
    required this.highScore,
    required this.onPlay,
    required this.onMulti,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: btnFade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: borderCtrl,
                builder: (_, __) => PlayButton(
                  borderProgress: borderCtrl.value,
                  onTap: onPlay,
                  scale: scale,
                ),
              ),
              SizedBox(width: 10 * scale),
              GestureDetector(
                onTap: onMulti,
                child: AnimatedBuilder(
                  animation: glowCtrl,
                  builder: (_, __) {
                    final glow = glowCtrl.value;
                    return Container(
                      width: 54 * scale,
                      height: 54 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.25),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.4 + glow * 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15 + glow * 0.15),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bluetooth_rounded,
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.7 + glow * 0.3),
                              size: 18 * scale),
                          Text('MULTI',
                              style: TextStyle(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.7 + glow * 0.3),
                                fontSize: 7 * scale,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                decoration: TextDecoration.none,
                              )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          highScore > 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text('RECORDE: $highScore',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 9 * scale,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4)],
                        )),
                  ],
                )
              : Text('TOQUE PARA COMEÇAR',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 8 * scale,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4)],
                  )),
        ],
      ),
    );
  }
}
