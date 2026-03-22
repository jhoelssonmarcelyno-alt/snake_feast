// lib/ui/main_menu/widgets/skin_selector.dart
// Seletor de skin: preview da cobra + setas + dots + nome
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../painters/snake_preview_painter.dart';
import 'skin_arrow.dart';
import '../../../utils/constants.dart';

class SkinSelector extends StatelessWidget {
  final int selectedSkin;
  final AnimationController snakeCtrl;
  final Animation<double> cardFade;
  final Animation<Offset> cardSlide;
  final double scale;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onSelect;

  const SkinSelector({
    super.key,
    required this.selectedSkin,
    required this.snakeCtrl,
    required this.cardFade,
    required this.cardSlide,
    required this.scale,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final skin = kPlayerSkins[selectedSkin];

    return FadeTransition(
      opacity: cardFade,
      child: SlideTransition(
        position: cardSlide,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkinArrow(icon: Icons.chevron_left_rounded, onTap: onPrev, scale: scale),
                Container(
                  width: 300 * scale,
                  height: 72 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(color: skin.accentColor.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: AnimatedBuilder(
                    animation: snakeCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: SnakePreviewPainter(skin: skin, t: snakeCtrl.value * pi * 2),
                    ),
                  ),
                ),
                SkinArrow(icon: Icons.chevron_right_rounded, onTap: onNext, scale: scale),
              ],
            ),
            SizedBox(height: 6 * scale),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  skin.name,
                  key: ValueKey(skin.id),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    decoration: TextDecoration.none,
                    shadows: [Shadow(color: skin.accentColor, blurRadius: 8)],
                  ),
                ),
              ),
            ),
            SizedBox(height: 6 * scale),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(kPlayerSkins.length, (i) {
                final bool on = i == selectedSkin;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: on ? 14 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: on ? Colors.white : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: on
                          ? [BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 4)]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
