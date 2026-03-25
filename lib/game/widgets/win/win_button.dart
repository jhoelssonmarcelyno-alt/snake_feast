import 'package:flutter/material.dart';

class WinButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: textColor),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: outlined ? Colors.transparent : color,
        foregroundColor: textColor,
        side: outlined ? BorderSide(color: color) : null,
      ),
    );
  }
}
