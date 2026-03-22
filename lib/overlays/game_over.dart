// lib/overlays/game_over.dart
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';

class GameOverOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const GameOverOverlay({super.key, required this.engine});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  int get _coinsEarned => widget.engine.player.foodEaten ~/ 50;
  int get _diamondsEarned => widget.engine.player.foodEaten ~/ 5000;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goMenu() {
    widget.engine.overlays.remove(kOverlayGameOver);
    widget.engine.overlays.add(kOverlayMainMenu);
    widget.engine.pauseEngine();
  }

  @override
  Widget build(BuildContext context) {
    final coins = ScoreService.instance.coins;
    final diamonds = ScoreService.instance.diamonds;
    final hasRewards = _coinsEarned > 0 || _diamondsEarned > 0;
    final mq = MediaQuery.of(context);
    // ✅ Altura disponível descontando padding do sistema
    final availableH = mq.size.height - mq.padding.top - mq.padding.bottom;

    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),
        child: Container(
          color: Colors.black.withValues(alpha: 0.80),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: mq.size.width * 0.82,
                    // ✅ Limita altura para nunca ultrapassar a tela
                    constraints: BoxConstraints(
                      maxWidth: 420,
                      maxHeight: availableH * 0.90,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF0D1B2A),
                      border:
                          Border.all(color: const Color(0xFF1E3A5F), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    // ✅ Column com Expanded + scroll para o body
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Cabeçalho ───────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                            color: Color(0xFFBF1515),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close_rounded,
                                      color: Colors.white, size: 26),
                                  SizedBox(height: 4),
                                  Text(
                                    'GAME OVER',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 6,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                              // ✅ Botão X clicável no canto superior direito
                              Positioned(
                                top: 0,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _goMenu,
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.12),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Body com scroll ─────────────────────
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StatRow(
                                  icon: Icons.stars_rounded,
                                  iconColor: const Color(0xFF00E5FF),
                                  label: 'Score',
                                  value: '${widget.engine.player.score}',
                                  valueColor: const Color(0xFF00E5FF),
                                ),
                                const SizedBox(height: 8),
                                _StatRow(
                                  icon: Icons.linear_scale_rounded,
                                  iconColor: const Color(0xFF69F0AE),
                                  label: 'Tamanho',
                                  value: '${widget.engine.player.length} seg.',
                                  valueColor: const Color(0xFF69F0AE),
                                ),
                                const SizedBox(height: 8),
                                _StatRow(
                                  icon: Icons.restaurant_rounded,
                                  iconColor: const Color(0xFFFFAB40),
                                  label: 'Comidas',
                                  value: '${widget.engine.player.foodEaten}',
                                  valueColor: const Color(0xFFFFAB40),
                                ),
                                if (hasRewards) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white.withValues(alpha: 0.04),
                                      border: Border.all(
                                          color:
                                              Colors.white.withValues(alpha: 0.08)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'RECOMPENSAS',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withValues(alpha: 0.4),
                                            fontSize: 9,
                                            letterSpacing: 3,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (_coinsEarned > 0)
                                          _RewardChip(
                                            icon: Icons.monetization_on_rounded,
                                            color: const Color(0xFFFFD600),
                                            label: 'Moedas',
                                            value: '+$_coinsEarned',
                                          ),
                                        if (_coinsEarned > 0 &&
                                            _diamondsEarned > 0)
                                          const SizedBox(height: 6),
                                        if (_diamondsEarned > 0)
                                          _RewardChip(
                                            icon: Icons.diamond_rounded,
                                            color: const Color(0xFF00E5FF),
                                            label: 'Diamantes',
                                            value: '+$_diamondsEarned',
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _BalanceChip(
                                      icon: Icons.monetization_on_rounded,
                                      color: const Color(0xFFFFD600),
                                      value: '$coins',
                                    ),
                                    const SizedBox(width: 16),
                                    _BalanceChip(
                                      icon: Icons.diamond_rounded,
                                      color: const Color(0xFF00E5FF),
                                      value: '$diamonds',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _ActionButton(
                                  label: 'JOGAR NOVAMENTE',
                                  icon: Icons.replay_rounded,
                                  color: const Color(0xFF00E5FF),
                                  onTap: widget.engine.restartGame,
                                ),
                                const SizedBox(height: 8),
                                _ActionButton(
                                  label: 'MENU PRINCIPAL',
                                  icon: Icons.home_rounded,
                                  color: const Color(0xFF546E7A),
                                  outlined: true,
                                  onTap: _goMenu,
                                ),
                              ],
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
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final Color valueColor;
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor.withValues(alpha: 0.8), size: 14),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
              decoration: TextDecoration.none,
            )),
        const Spacer(),
        Text(value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            )),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  const _RewardChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 7),
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              decoration: TextDecoration.none,
            )),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          child: Text(value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              )),
        ),
      ],
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  const _BalanceChip({
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            )),
      ]),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.outlined = false,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 70),
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.outlined
                ? Colors.transparent
                : widget.color.withValues(alpha: _pressed ? 0.85 : 1.0),
            border: widget.outlined
                ? Border.all(color: widget.color.withValues(alpha: 0.4), width: 1.2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  color: widget.outlined ? widget.color : Colors.black,
                  size: 16),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.outlined ? widget.color : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
