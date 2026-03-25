// lib/game/engine_win.dart
import 'dart:async' as async;
import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'snake_engine.dart';
import '../utils/constants.dart';

// ─── Mixin de Vitória ─────────────────────────────────────────

mixin WinMixin on FlameGame {
  SnakeEngine get engine => this as SnakeEngine;

  void checkVictoryCondition() {
    if (!engine.battleActive || engine.battleEnded || !engine.player.isAlive) {
      return;
    }
    final int aliveBots = engine.bots.where((bot) => bot.isAlive).length;
    if (aliveBots == 0) {
      triggerVictory();
    }
  }

  void triggerVictory() {
    engine.battleEnded = true;
    engine.battleWinner = engine.player.name;

    _showBooyahText();
    _spawnVictoryFireworks();

    if (!engine.overlays.isActive('WinOverlay')) {
      engine.overlays.add('WinOverlay');
    }
  }

  void _showBooyahText() {
    final textPaint = TextPaint(
      style: TextStyle(
        color: const Color(0xFFFFFF00),
        fontSize: 80.0,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        shadows: [
          Shadow(
            color: const Color(0xFFFF8C00).withAlpha(200),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
    );

    final booyah = TextComponent(
      text: 'BOOYAH!',
      textRenderer: textPaint,
      position: engine.size / 2,
      anchor: Anchor.center,
    )..priority = 110;

    engine.add(booyah);

    async.Future.delayed(const Duration(seconds: 3), () {
      if (booyah.isMounted) booyah.removeFromParent();
    });
  }

  void _spawnVictoryFireworks() {
    final Random rng = Random();
    for (int i = 0; i < 15; i++) {
      async.Future.delayed(Duration(milliseconds: rng.nextInt(1500)), () {
        if (!engine.isAttached) return;
        final Vector2 position = Vector2(
          rng.nextDouble() * engine.size.x,
          rng.nextDouble() * engine.size.y,
        );
        final Color color =
            Colors.primaries[rng.nextInt(Colors.primaries.length)];
        engine.add(
          ParticleSystemComponent(
            particle: _createFireworkParticle(position, color),
          )..priority = 100,
        );
      });
    }
  }

  Particle _createFireworkParticle(Vector2 position, Color color) {
    final Random rng = Random();
    return Particle.generate(
      count: 100,
      lifespan: 2.5,
      generator: (i) {
        final Vector2 speed = Vector2(
          (rng.nextDouble() - 0.5) * 600,
          (rng.nextDouble() - 0.5) * 600,
        );
        return AcceleratedParticle(
          position: position.clone(),
          speed: speed,
          acceleration: Vector2(0, 250),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()
                ..color = color.withValues(alpha: 1.0 - particle.progress)
                ..style = PaintingStyle.fill;
              canvas.drawCircle(
                Offset.zero,
                4.0 * (1.0 - particle.progress),
                paint,
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Overlay de Vitória ───────────────────────────────────────

class WinOverlay extends StatefulWidget {
  final SnakeEngine game;
  const WinOverlay({super.key, required this.game});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goMenu() {
    widget.game.overlays.remove('WinOverlay');
    widget.game.overlays.add(kOverlayMainMenu);
    widget.game.pauseEngine();
  }

  void _playAgain() {
    widget.game.overlays.remove('WinOverlay');
    widget.game.restartGame();
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFFFD700);
    const Color bgColor = Color(0xFF0A1628);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: bgColor,
                border: Border.all(color: goldColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: goldColor.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Cabeçalho dourado ─────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(22)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFB8860B),
                          Color(0xFFFFD700),
                          Color(0xFFB8860B),
                        ],
                      ),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events,
                            color: Color(0xFF3D2000), size: 52),
                        SizedBox(height: 6),
                        Text(
                          'BOOYAH!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3D2000),
                            letterSpacing: 6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Você é o último sobrevivente!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5C3000),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Corpo ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pontuação
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: goldColor.withValues(alpha: 0.07),
                            border: Border.all(
                                color: goldColor.withValues(alpha: 0.25),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.stars_rounded,
                                  color: Color(0xFF00E5FF), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'PONTUAÇÃO',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${widget.game.player.score}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Color(0xFF00E5FF),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Botão Jogar Novamente
                        _WinButton(
                          label: 'JOGAR NOVAMENTE',
                          icon: Icons.replay_rounded,
                          color: goldColor,
                          textColor: const Color(0xFF3D2000),
                          onTap: _playAgain,
                        ),
                        const SizedBox(height: 10),

                        // Botão Menu Principal
                        _WinButton(
                          label: 'MENU PRINCIPAL',
                          icon: Icons.home_rounded,
                          color: const Color(0xFF1E3A5F),
                          textColor: Colors.white,
                          onTap: _goMenu,
                          outlined: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Botão reutilizável ────────────────────────────────────────

class _WinButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool outlined;
  final VoidCallback onTap;

  const _WinButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.outlined = false,
  });

  @override
  State<_WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<_WinButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.outlined
                ? Colors.transparent
                : widget.color.withValues(alpha: _pressed ? 0.85 : 1.0),
            border: widget.outlined
                ? Border.all(
                    color: widget.color.withValues(alpha: 0.5), width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.textColor, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
