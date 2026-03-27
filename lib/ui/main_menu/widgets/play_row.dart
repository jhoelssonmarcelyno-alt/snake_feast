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
    final s = scale;
    // Largura máxima = tela - padding horizontal (40px cada lado)
    final maxW = MediaQuery.of(context).size.width - 80 * s;
    // Botão bluetooth: 48*s + 8*s de espaço = 56*s
    // Botão jogar: o restante (com limite de 260*s)
    final btnW = (maxW - 56 * s).clamp(160.0 * s, 260.0 * s);

    return FadeTransition(
      opacity: btnFade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Botão JOGAR ──────────────────────────────────
              AnimatedBuilder(
                animation: borderCtrl,
                builder: (_, __) => PlayButton(
                  borderProgress: borderCtrl.value,
                  onTap: onPlay,
                  scale: s,
                  overrideWidth: btnW,
                ),
              ),
              SizedBox(width: 8 * s),
              // ── Botão Bluetooth ──────────────────────────────
              GestureDetector(
                onTap: onMulti,
                child: AnimatedBuilder(
                  animation: glowCtrl,
                  builder: (_, __) {
                    final glow = glowCtrl.value;
                    return Container(
                      width: 48 * s,
                      height: 48 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.25),
                        border: Border.all(
                          color: const Color(0xFF00E5FF)
                              .withOpacity(0.4 + glow * 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF)
                                .withOpacity(0.2 + glow * 0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.bluetooth,
                        color: const Color(0xFF00E5FF),
                        size: 18 * s,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * s),
          // ── Recorde ou "TOQUE PARA COMEÇAR" ─────────────────
          highScore > 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'RECORDE: $highScore',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 9 * s,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                )
              : Text(
                  'TOQUE PARA COMEÇAR',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 8 * s,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
        ],
      ),
    );
  }
}
