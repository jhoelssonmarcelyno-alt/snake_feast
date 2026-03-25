// lib/game/win/win_widgets.dart
import 'package:flutter/material.dart';

class WinStatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const WinStatRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 1),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 22, color: color, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class WinDivider extends StatelessWidget {
  final String label;
  const WinDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child:
              Container(height: 1, color: Colors.white.withValues(alpha: 0.08))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
      ),
      Expanded(
          child:
              Container(height: 1, color: Colors.white.withValues(alpha: 0.08))),
    ]);
  }
}

class WinButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool outlined;
  final VoidCallback onTap;

  const WinButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.outlined = false,
  });

  @override
  State<WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<WinButton> {
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
              Text(widget.label,
                  style: TextStyle(
                      color: widget.textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
