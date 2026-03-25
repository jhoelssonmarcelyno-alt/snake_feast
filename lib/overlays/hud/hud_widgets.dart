// lib/overlays/hud/hud_widgets.dart
import 'package:flutter/material.dart';

class HudCard extends StatelessWidget {
  final List<Widget> children;
  const HudCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
}

class HudStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final Color valueColor;

  const HudStat({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: iconColor, size: 10),
            const SizedBox(width: 3),
            Text(label,
                style: const TextStyle(
                  color: Color(0xFF546E7A),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  decoration: TextDecoration.none,
                )),
          ]),
          const SizedBox(height: 1),
          Text(value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1.0,
                decoration: TextDecoration.none,
              )),
        ],
      );
}
