// lib/game/skins/snake_skin.dart
import 'package:flutter/material.dart';
import 'skin_rarity.dart';

class SnakeSkin {
  final String id;
  final String name;
  final SkinRarity rarity;
  final int power;
  final Color bodyColor;
  final Color bodyColorDark;
  final Color accentColor;
  final bool isUnlocked;
  final double speedBonus;
  final double healthBonus;
  final int damageBonus;
  final String animalType; // NOVO: tipo de animal para desenho

  const SnakeSkin({
    required this.id,
    required this.name,
    required this.rarity,
    required this.power,
    required this.bodyColor,
    required this.bodyColorDark,
    required this.accentColor,
    this.isUnlocked = false,
    this.speedBonus = 0.0,
    this.healthBonus = 0.0,
    this.damageBonus = 0,
    this.animalType = 'snake', // padrão cobra
  });
}
