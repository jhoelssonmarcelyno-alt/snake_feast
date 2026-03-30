import 'package:flutter/material.dart';
import '../../game/snake_engine.dart';
import '../../services/world_progress_service.dart';
import '../../utils/constants.dart';

class WinOverlay extends StatefulWidget {
  final SnakeEngine game;
  const WinOverlay({super.key, required this.game});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _recordVictory();
  }

  Future<void> _recordVictory() async {
    if (_isProcessing) return;
    _isProcessing = true;
    
    try {
      // Registra a vitória no mundo atual
      await WorldProgressService().recordWin(widget.game.selectedWorld);
      
      // Verifica se o próximo mundo foi desbloqueado
      final nextWorld = WorldProgressService().nextWorldToUnlock;
      final hasNext = WorldProgressService().hasNextWorld;
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Erro ao registrar vitória: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final wins = WorldProgressService().getWorldWins(widget.game.selectedWorld);
    final winsNeeded = 10;
    final progress = wins / winsNeeded;
    final nextWorld = WorldProgressService().nextWorldToUnlock;
    
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: screenSize.width * 0.8,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D1B2A), Color(0xFF1B2A3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD600).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de vitória
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD600).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFD600),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              
              // Título
              const Text(
                'VITÓRIA!',
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              
              // Mensagem
              Text(
                'Você venceu a batalha!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              // Barra de progresso
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progresso no Mundo ${widget.game.selectedWorld + 1}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$wins / $winsNeeded',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD600),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (progress >= 1.0)
                      Text(
                        '✓ Mundo ${widget.game.selectedWorld + 1} completo!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        'Faltam ${winsNeeded - wins} vitórias para desbloquear o próximo mundo',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Botão continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.game.overlays.remove('WinOverlay');
                    widget.game.overlays.add(kOverlayMainMenu);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Botão jogar novamente
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    widget.game.overlays.remove('WinOverlay');
                    widget.game.restartGame();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'JOGAR NOVAMENTE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
