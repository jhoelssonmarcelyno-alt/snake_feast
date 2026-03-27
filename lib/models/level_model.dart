import 'package:flutter/material.dart';

class GameLevel {
  final int id;
  final int targetScore;
  final double speed;
  final List<Offset> obstacles; // Posições das paredes
  final Color themeColor;

  GameLevel({
    required this.id,
    required this.targetScore,
    required this.speed,
    this.obstacles = const [],
    this.themeColor = Colors.green,
  });
}
