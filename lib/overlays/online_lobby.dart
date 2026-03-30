import 'dart:math';
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class LobbyOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const LobbyOverlay({super.key, required this.engine});

  @override
  State<LobbyOverlay> createState() => _LobbyOverlayState();
}

class _LobbyOverlayState extends State<LobbyOverlay> {
  final Random _random = Random();
  String _roomCode = '';
  bool _isCreating = false;
  bool _isJoining = false;
  final TextEditingController _roomController = TextEditingController();

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  void _createRoom() async {
    setState(() => _isCreating = true);
    try {
      // TODO: integrar com SnakeEngine para modo online
      // Por enquanto, apenas simula
      await Future.delayed(const Duration(seconds: 1));
      _roomCode = _generateRoomCode();
      setState(() {});
    } catch (e) {
      debugPrint('Erro ao criar sala: $e');
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _joinRoom() async {
    if (_roomController.text.isEmpty) return;
    setState(() => _isJoining = true);
    try {
      // TODO: integrar com SnakeEngine para modo online
      await Future.delayed(const Duration(seconds: 1));
      _roomCode = _roomController.text;
      setState(() {});
    } catch (e) {
      debugPrint('Erro ao entrar na sala: $e');
    } finally {
      setState(() => _isJoining = false);
    }
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
    );
  }

  void _close() {
    widget.engine.overlays.remove(kOverlayLobby);
  }

  void _startGame() {
    // TODO: iniciar jogo online
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final skinIndex = ScoreService.instance.selectedSkinIndex;
    final skin = kPlayerSkins[skinIndex.clamp(0, kPlayerSkins.length - 1)];
    
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: skin.accentColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: skin.accentColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.groups,
                          color: skin.accentColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'LOBBY ONLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _close,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Corpo
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_roomCode.isEmpty) ...[
                      // Criar sala
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isCreating ? null : _createRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: skin.accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCreating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'CRIAR SALA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OU',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Entrar em sala
                      TextField(
                        controller: _roomController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Código da sala',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.vpn_key,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isJoining ? null : _joinRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isJoining
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'ENTRAR NA SALA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // Sala criada
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'SALA CRIADA!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                _roomCode,
                                style: TextStyle(
                                  color: skin.accentColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Compartilhe este código com seus amigos',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'INICIAR PARTIDA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => setState(() => _roomCode = ''),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('CANCELAR'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
