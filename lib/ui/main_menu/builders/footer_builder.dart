import 'package:flutter/material.dart';
import '../../../services/score_service.dart';
import '../widgets/play_row.dart';
import '../widgets/tips_column.dart';

Widget buildFooter({
  required Animation<double> fade,
  required AnimationController borderCtrl,
  required AnimationController glowCtrl,
  required double scale,
  required VoidCallback onPlay,
  required VoidCallback onMulti,
}) {
  return Positioned(
    left: 0,
    right: 0,
    bottom: 25,
    child: FadeTransition(
      opacity: fade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          TipsColumn(fadeAnim: fade),
        ],
      ),
    ),
  );
}
