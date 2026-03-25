// lib/overlays/hud/hud_boost_button.dart
import 'package:flutter/material.dart';

class HudBoostButton extends StatelessWidget {
  final bool isPressed;
  final bool isBoosting;
  final void Function(PointerDownEvent) onDown;
  final void Function(PointerUpEvent) onUp;
  final void Function(PointerCancelEvent) onCancel;

  static const double size = 76.0;

  const HudBoostButton({
    super.key,
    required this.isPressed,
    required this.isBoosting,
    required this.onDown,
    required this.onUp,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: onDown,
      onPointerUp: onUp,
      onPointerCancel: onCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: isPressed ? size - 4 : size,
        height: isPressed ? size - 4 : size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isBoosting
              ? const Color(0xFF00E5FF).withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: isBoosting
                ? const Color(0xFF00E5FF)
                : Colors.white.withValues(alpha: 0.30),
            width: isBoosting ? 2.5 : 1.5,
          ),
          boxShadow: isBoosting
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_on_rounded,
              color: isBoosting
                  ? const Color(0xFF00E5FF)
                  : Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
            Text(
              'BOOST',
              style: TextStyle(
                color: isBoosting
                    ? const Color(0xFF00E5FF)
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
