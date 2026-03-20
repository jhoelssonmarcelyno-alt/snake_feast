// lib/ui/main_menu/widgets/play_button.dart
import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  final double borderProgress; // mantido por compatibilidade
  final VoidCallback onTap;
  final double scale;
  const PlayButton({
    super.key,
    required this.borderProgress,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 6.0, end: 18.0).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final w = 260.0 * s;
    final h = 64.0 * s;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            width: w + 8,
            height: h + 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40 * s),
              // Borda laranja pulsante
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9500).withOpacity(0.8),
                  blurRadius: _glow.value * 2,
                  spreadRadius: 2,
                ),
              ],
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: child,
          ),
        ),
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36 * s),
            gradient: const LinearGradient(
              colors: [Color(0xFF29CFFF), Color(0xFF0099CC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28 * s,
                  shadows: [
                    Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4)
                  ]),
              SizedBox(width: 6 * s),
              Text(
                'JOGAR',
                style: TextStyle(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                  decoration: TextDecoration.none,
                  shadows: [
                    Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
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
