// lib/overlays/revive_overlay.dart
// Aparece ao morrer — oferece reviver por 10 moedas (até 3x por partida)
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class ReviveOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const ReviveOverlay({super.key, required this.engine});

  @override
  State<ReviveOverlay> createState() => _ReviveOverlayState();
}

class _ReviveOverlayState extends State<ReviveOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // Contador regressivo de 10s para aceitar automaticamente
  int _seconds = 10;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 10; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _seconds = i);
      if (i == 0) _decline();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _revive() async {
    if (_busy) return;
    setState(() => _busy = true);

    final ok = await ScoreService.instance.spendCoins(10);
    if (!mounted) return;

    if (ok) {
      widget.engine.revivePlayer();
    } else {
      // sem moedas → vai pro game over
      _decline();
    }
  }

  void _decline() {
    if (!mounted) return;
    widget.engine.overlays.remove(kOverlayRevive);
    widget.engine.overlays.add(kOverlayGameOver);
  }

  @override
  Widget build(BuildContext context) {
    final coins = ScoreService.instance.coins;
    final canAfford = coins >= 10;
    final revivesLeft = widget.engine.revivesUsed;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.78),
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFF0D1B2A),
                    border: Border.all(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.4),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone coração
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2ECC71).withValues(alpha: 0.12),
                              border: Border.all(
                                  color: const Color(0xFF2ECC71)
                                      .withValues(alpha: 0.5)),
                            ),
                          ),
                          const Icon(Icons.favorite_rounded,
                              color: Color(0xFF2ECC71), size: 30),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'CONTINUAR?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reviver custa 10 moedas',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tentativas restantes: ${3 - revivesLeft}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                          decoration: TextDecoration.none,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Contador + moedas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Contador regressivo circular
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _seconds / 10.0,
                                  strokeWidth: 3,
                                  color: const Color(0xFF2ECC71),
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.1),
                                ),
                                Text(
                                  '$_seconds',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Saldo
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFFFD600).withValues(alpha: 0.1),
                              border: Border.all(
                                  color:
                                      const Color(0xFFFFD600).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.monetization_on_rounded,
                                      color: Color(0xFFFFD600), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$coins',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD600),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Botão reviver
                      GestureDetector(
                        onTap: canAfford && !_busy ? _revive : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: canAfford
                                ? const LinearGradient(
                                    colors: [
                                        Color(0xFF2ECC71),
                                        Color(0xFF27AE60)
                                      ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight)
                                : null,
                            color: canAfford
                                ? null
                                : Colors.white.withValues(alpha: 0.06),
                            boxShadow: canAfford
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2ECC71)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 16,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_rounded,
                                  color: canAfford
                                      ? Colors.white
                                      : Colors.white30,
                                  size: 18),
                              const SizedBox(width: 8),
                              Text(
                                canAfford
                                    ? 'REVIVER  -10 🪙'
                                    : 'MOEDAS INSUFICIENTES',
                                style: TextStyle(
                                  color: canAfford
                                      ? Colors.white
                                      : Colors.white30,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Botão recusar
                      GestureDetector(
                        onTap: _decline,
                        child: Container(
                          width: double.infinity,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.transparent,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Center(
                            child: Text(
                              'DESISTIR',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
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
