// lib/game/engine_leaderboard.dart
import 'dart:ui' show Color;
import 'package:flutter/material.dart'
    show TextPainter, TextSpan, TextStyle, FontWeight, TextDirection;
import 'snake_engine.dart';

extension EngineLeaderboard on SnakeEngine {
  void buildLbTitle() {
    lbTitlePainter =
        makeTextPainter('RANKING', 11, const Color(0xFF00FF88), bold: true);
  }

  void rebuildLeaderboard() {
    lbEntryPainters.clear();
    final entries = <Map<String, dynamic>>[];

    if (player.isAlive) {
      entries.add({
        'name': player.name,
        'len': player.length,
        'isPlayer': true,
        'color': player.skin.accentColor,
        'alive': true,
      });
    }

    // ── Inclui TODOS os bots, vivos ou ressurgindo ────────────
    for (final b in bots) {
      entries.add({
        'name': b.name,
        'len': b.isAlive ? b.length : 0,
        'isPlayer': false,
        'color': b.bodyColor,
        'alive': b.isAlive,
      });
    }

    entries.sort((a, b) => (b['len'] as int).compareTo(a['len'] as int));

    for (int i = 0; i < entries.length.clamp(0, 10); i++) {
      final e = entries[i];
      final ip = e['isPlayer'] as bool;
      final alive = e['alive'] as bool;
      final label = alive
          ? '${i + 1}. ${e['name']}  ${e['len']}'
          : '${i + 1}. ${e['name']}  ...';
      final color = alive
          ? e['color'] as Color
          : (e['color'] as Color).withValues(alpha: 0.35);
      lbEntryPainters.add(makeTextPainter(label, 10, color, bold: ip));
    }
  }

  TextPainter makeTextPainter(String text, double size, Color color,
      {bool bold = false}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }
}
