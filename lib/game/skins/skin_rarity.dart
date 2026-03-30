// lib/game/skins/skin_rarity.dart
import 'package:flutter/material.dart';

enum SkinRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythical,
}

extension SkinRarityExtension on SkinRarity {
  String get name {
    switch (this) {
      case SkinRarity.common:
        return 'COMUM';
      case SkinRarity.uncommon:
        return 'INCOMUM';
      case SkinRarity.rare:
        return 'RARA';
      case SkinRarity.epic:
        return 'ÉPICA';
      case SkinRarity.legendary:
        return 'LENDÁRIA';
      case SkinRarity.mythical:
        return 'MÍTICA';
    }
  }

  Color get color {
    switch (this) {
      case SkinRarity.common:
        return Colors.grey;
      case SkinRarity.uncommon:
        return Colors.green;
      case SkinRarity.rare:
        return Colors.blue;
      case SkinRarity.epic:
        return Colors.purple;
      case SkinRarity.legendary:
        return Colors.orange;
      case SkinRarity.mythical:
        return Colors.red;
    }
  }
}
