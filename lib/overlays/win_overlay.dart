import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../utils/constants.dart';

class WinOverlay extends StatelessWidget {
  final SnakeEngine game;

  const WinOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Definindo a cor dourada manualmente para evitar o erro
    const Color goldColor = Color(0xFFFFD700);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black
              .withValues(alpha: 0.85), // ✅ Corrigido para Flutter moderno
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: goldColor, width: 3), // ✅ Usando goldColor definida acima
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: goldColor, size: 80),
            const SizedBox(height: 16),
            const Text(
              'VITÓRIA REAL!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você é o último sobrevivente!',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              'PONTUAÇÃO: ${game.player.score}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Remove a tela de vitória e volta para o menu
                game.overlays.remove('WinOverlay');
                game.overlays.add(kOverlayMainMenu);
              },
              child: const Text('VOLTAR AO MENU'),
            ),
          ],
        ),
      ),
    );
  }
}
