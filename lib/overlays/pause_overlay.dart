// lib/overlays/pause_overlay.dart
import 'package:flutter/material.dart';
import '../game/snake_engine.dart';
import '../utils/constants.dart';

class PauseOverlay extends StatefulWidget {
  final SnakeEngine engine;
  const PauseOverlay({super.key, required this.engine});

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _resume() {
    widget.engine.overlays.remove(kOverlayPause);
    widget.engine.overlays.add(kOverlayHud);
    widget.engine.resumeEngine();
  }

  void _goMenu() {
    widget.engine.overlays.remove(kOverlayPause);
    widget.engine.overlays.add(kOverlayMainMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),
        child: Container(
          color: Colors.black.withOpacity(0.65),
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFF0D1B2A),
                    border: Border.all(
                        color: const Color(0xFF1E3A5F), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
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
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF29CFFF).withOpacity(0.12),
                          border: Border.all(
                              color: const Color(0xFF29CFFF).withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.pause_rounded,
                            color: Color(0xFF29CFFF), size: 28),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'PAUSADO',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Continuar
                      _PauseButton(
                        label: 'CONTINUAR',
                        icon: Icons.play_arrow_rounded,
                        color: const Color(0xFF2ECC71),
                        filled: true,
                        onTap: _resume,
                      ),
                      const SizedBox(height: 10),

                      // Menu principal
                      _PauseButton(
                        label: 'MENU PRINCIPAL',
                        icon: Icons.home_rounded,
                        color: const Color(0xFF546E7A),
                        filled: false,
                        onTap: _goMenu,
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

class _PauseButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _PauseButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.filled,
      required this.onTap});

  @override
  State<_PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<_PauseButton> {
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
        duration: const Duration(milliseconds: 70),
        child: Container(
          width: double.infinity,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.filled
                ? widget.color.withOpacity(_pressed ? 0.85 : 1.0)
                : widget.color.withOpacity(0.1),
            border: widget.filled
                ? null
                : Border.all(color: widget.color.withOpacity(0.4), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  color: widget.filled ? Colors.white : widget.color,
                  size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.filled ? Colors.white : widget.color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
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
