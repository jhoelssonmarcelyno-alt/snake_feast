// lib/overlays/lobby_overlay.dart
// Tela de lobby para modo online (em desenvolvimento)
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../utils/constants.dart';

class LobbyOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const LobbyOverlay({super.key, required this.engine});

  @override
  State<LobbyOverlay> createState() => _LobbyOverlayState();
}

class _LobbyOverlayState extends State<LobbyOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() {
    widget.engine.overlays.remove(kOverlayLobby);
  }

  void _startSearch() {
    setState(() => _searching = true);
    // Simula busca por 2s e volta ao offline (online ainda não implementado)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _searching = false);
      _showComingSoon();
    });
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Em breve!',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none)),
        content: const Text(
            'O modo online está em desenvolvimento.\nVolte em breve!',
            style: TextStyle(
                color: Colors.white60, decoration: TextDecoration.none)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF00E5FF))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
            decorationThickness: 0),
        child: Container(
          color: Colors.black.withOpacity(0.82),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFF0D1B2A),
                    border: Border.all(
                        color: const Color(0xFF29CFFF).withOpacity(0.4),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29CFFF).withOpacity(0.12),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF29CFFF).withOpacity(0.12),
                          border: Border.all(
                              color:
                                  const Color(0xFF29CFFF).withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.wifi_rounded,
                            color: Color(0xFF29CFFF), size: 30),
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'MODO ONLINE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jogue contra outros jogadores\nao redor do mundo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                          decoration: TextDecoration.none,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Badge "em breve"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFFFFD600).withOpacity(0.12),
                          border: Border.all(
                              color:
                                  const Color(0xFFFFD600).withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.construction_rounded,
                                color: Color(0xFFFFD600), size: 14),
                            SizedBox(width: 6),
                            Text('EM DESENVOLVIMENTO',
                                style: TextStyle(
                                  color: Color(0xFFFFD600),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  decoration: TextDecoration.none,
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botão buscar partida
                      GestureDetector(
                        onTap: _searching ? null : _startSearch,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: _searching
                                ? null
                                : const LinearGradient(
                                    colors: [
                                        Color(0xFF29CFFF),
                                        Color(0xFF0099CC)
                                      ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                            color: _searching
                                ? Colors.white.withOpacity(0.08)
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_searching) ...[
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('BUSCANDO...',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      decoration: TextDecoration.none,
                                    )),
                              ] else ...[
                                const Icon(Icons.search_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                const Text('BUSCAR PARTIDA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      decoration: TextDecoration.none,
                                    )),
                              ]
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Botão PLACAR GLOBAL
                      GestureDetector(
                        onTap: () => widget.engine.overlays.add(kOverlayRanking),
                        child: Container(
                          width: double.infinity,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFFFD700).withOpacity(0.10),
                            border: Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.emoji_events_rounded,
                                  color: Color(0xFFFFD700), size: 16),
                              const SizedBox(width: 8),
                              const Text('PLACAR GLOBAL',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    decoration: TextDecoration.none,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Botão cancelar
                      GestureDetector(
                        onTap: _close,
                        child: Container(
                          width: double.infinity,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Center(
                            child: Text(
                              'VOLTAR',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
