// lib/game/skins/skin_factory.dart
import 'package:flutter/material.dart';
import 'snake_skin.dart';
import 'skin_rarity.dart';
import 'skin_themes.dart';

class SkinFactory {
  static List<SnakeSkin> createAllSkins() {
    final List<SnakeSkin> skins = [];

    for (int i = 1; i <= 250; i++) {
      final rarity = _getRarityByPower(i);
      final theme = SkinThemes.getThemeByPower(i);
      final variation = (i * 7) % 30;

      skins.add(SnakeSkin(
        id: 'skin_$i',
        name: '${theme.name} ${_getSuffixByPower(i)}',
        rarity: rarity,
        power: i,
        bodyColor: _adjustColor(theme.primaryColor, variation),
        bodyColorDark: _adjustColor(theme.secondaryColor, variation ~/ 2),
        accentColor: _adjustColor(theme.accentColor, variation),
        isUnlocked: i <= 10,
        speedBonus: theme.speedBonus + (i / 500),
        healthBonus: theme.healthBonus + (i / 500),
        damageBonus: theme.damageBonus + (i ~/ 50),
        animalType: theme.headType,
      ));
    }

    return skins;
  }

  static SkinRarity _getRarityByPower(int power) {
    if (power <= 50) return SkinRarity.common;
    if (power <= 100) return SkinRarity.uncommon;
    if (power <= 150) return SkinRarity.rare;
    if (power <= 200) return SkinRarity.epic;
    if (power <= 240) return SkinRarity.legendary;
    return SkinRarity.mythical;
  }

  static String _getSuffixByPower(int power) {
    if (power <= 10) return 'Filhote';
    if (power <= 20) return 'Jovem';
    if (power <= 30) return 'Adulto';
    if (power <= 40) return 'Ancião';
    if (power <= 50) return 'Elder';
    if (power <= 70) return 'Guardião';
    if (power <= 90) return 'Protetor';
    if (power <= 110) return 'Sábio';
    if (power <= 130) return 'Destruidor';
    if (power <= 150) return 'Imperador';
    if (power <= 180) return 'Divino';
    if (power <= 210) return 'Primordial';
    if (power <= 240) return 'Infinito';
    return 'Absoluto';
  }

  static Color _adjustColor(Color color, int amount) {
    final r = (color.red + amount).clamp(0, 255);
    final g = (color.green + amount).clamp(0, 255);
    final b = (color.blue + amount).clamp(0, 255);
    return Color.fromARGB(255, r, g, b);
  }

  static List<SnakeSkin> createTestSkins() {
    final List<SnakeSkin> testSkins = [];
    final testAnimals = SkinThemes.animals.take(10).toList();

    for (int i = 0; i < testAnimals.length; i++) {
      final theme = testAnimals[i];
      testSkins.add(SnakeSkin(
        id: 'test_${theme.name}',
        name: '${theme.name} Teste',
        rarity: SkinRarity.common,
        power: i + 1,
        bodyColor: theme.primaryColor,
        bodyColorDark: theme.secondaryColor,
        accentColor: theme.accentColor,
        isUnlocked: true,
        speedBonus: theme.speedBonus,
        healthBonus: theme.healthBonus,
        damageBonus: theme.damageBonus,
        animalType: theme.headType,
      ));
    }

    return testSkins;
  }
}
