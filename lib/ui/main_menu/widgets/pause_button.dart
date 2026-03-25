// lib/ui/main_menu/widgets/pause_button.dart
import 'package:flutter/material.dart';
// ✅ Agora voltando 2 níveis para achar as pastas corretas:
import '../../../game/snake_engine.dart';
import '../../../utils/constants.dart';

class HudPauseButton extends StatelessWidget {
  final SnakeEngine engine;

  const HudPauseButton({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Pausa o jogo e gerencia os overlays
        engine.pauseEngine();
        engine.overlays.remove(kOverlayHud);
        engine.overlays.add(kOverlayPause);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF29CFFF).withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF29CFFF).withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.pause_rounded,
          color: Color(0xFF29CFFF),
          size: 32,
        ),
      ),
    );
  }
}
